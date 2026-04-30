# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::API;

=head1 NAME

POPFile::API - Mojolicious-based HTTP server for the POPFile web UI

=head1 DESCRIPTION

Provides the POPFile web interface as a Mojolicious application.  The server
runs in-process on C<Mojo::IOLoop> (started by T3).

The application exposes a REST API at C</api/v1/*> consumed by the Svelte
single-page application, and serves the built Svelte bundle from the
C<public/> directory (configurable via the C<static_dir> config key).

=cut

use Object::Pad;
use utf8;
use POPFile::Features;

use Scalar::Util qw(looks_like_number);
use Data::Page;

class POPFile::API :isa(POPFile::Module);

field $service = undef;
field $imap_service = undef;
field $loader_ref = undef;
field $daemon_ref = undef;

BUILD {
    $self->set_name('api');
}

=head2 initialize

Registers configuration defaults: C<port> (8080), C<static_dir> (public),
and C<open_browser> (1).  Set C<port> to 0 to let the OS pick a free port
at startup.  Set C<open_browser> to 0 to suppress opening a browser when
the server is ready (config key: C<open_browser>).

=cut

method initialize() {
    $self->config(port => 0);
    $self->config(password => '');
    $self->config(static_dir => 'public');
    $self->config(local => 1);
    $self->config(page_size => 25);
    $self->config(word_page_size => 50);
    $self->config(session_dividers => 1);
    $self->config(wordtable_format => '');
    $self->config(locale => '');
    $self->config(open_browser => 1);
    return 1
}

=head2 start

Registers the Mojo HTTP daemon on the IOLoop. Does not start the loop — T3
starts it. Returns 1 on success.

=cut

method _find_free_port() {
    require IO::Socket::INET;
    my %socket_args = (
        Listen => 1,
        Proto => 'tcp',
        LocalPort => 0,
        ReuseAddr => 1 );
    $socket_args{LocalAddr} = '127.0.0.1'
        if $self->config('local');
    my $sock = IO::Socket::INET->new(
        %socket_args );
    my $port = $sock->sockport();
    $sock->close();
    return $port
}

method start() {
    require Mojo::Server::Daemon;
    my $port = $self->config('port');
    my $port_file = $self->configuration()->get_user_path('popfile.port');
    if ($port == 0) {
        if (-e $port_file && open my $fh, '<', $port_file) {
            chomp(my $saved = <$fh>);
            close $fh;
            $port = $saved + 0
                if $saved =~ /^\d+$/ && $saved > 0;
        }
        $port = $self->_find_free_port()
            if $port == 0;
        $self->config('port', $port);
        if (open my $fh, '>', $port_file) {
            print $fh $port;
            close $fh;
        }
    }
    my $app = $self->build_app($service, undef);
    my $host = $self->config('local')
        ? '127.0.0.1'
        : '*';
    my $daemon = Mojo::Server::Daemon->new(
        app => $app,
        listen => ["http://$host:$port"] );
    $daemon->silent(1);
    $daemon->start();
    $daemon_ref = $daemon;
    $self->log_msg(WARN => "POPFile::API: listening on port $port");
    if ($self->config('open_browser') && !$ENV{HARNESS_ACTIVE}) {
        require Browser::Open;
        Browser::Open::open_browser("http://localhost:$port/");
    }
    return 1
}

=head2 daemon

Returns the in-process L<Mojo::Server::Daemon> instance, or C<undef> before
C<start()> is called.

=cut

method daemon() { $daemon_ref }

=head2 url

Returns the base URL of the running web interface (e.g.
C<http://localhost:8080/>), or an empty string before C<start()> is called.

=cut

method url() {
    return '' unless defined $daemon_ref;
    return 'http://localhost:' . $self->config('port') . '/'
}

=head2 stop

Stops the in-process daemon.

=cut

method stop() {
    if (defined $daemon_ref) {
        $daemon_ref->stop();
        $daemon_ref = undef;
    }
}

=head2 service

No-op stub kept for Loader compatibility. Returns 1.

=cut

method service() { return 1 }

=head2 set_service

Injects the C<Services::Classifier> facade used by the child for REST calls.

=cut

method set_service ($svc = undef) {
    $service = $svc;
}

method set_imap ($svc = undef) {
    $imap_service = $svc;
}

method set_loader ($loader = undef) {
    $loader_ref = $loader;
}


=head2 build_app

my $app = $self->build_app($svc, $session);

Constructs and returns the L<Mojolicious> application.  Called inside the
forked child.  C<$svc> is the L<Services::Classifier> instance (may be
C<undef> in tests); C<$session> is a pre-obtained Bayes session key used
by all request handlers.

=cut

method build_app ($svc, $session = undef) {
    require Mojolicious;
    require Mojo::Path;

    my $static = $self->get_root_path($self->config('static_dir'));
    my $app = Mojolicious->new();
    $app->log->level('warn');

    # Serve the built Svelte bundle as static files
    push $app->static->paths->@*, $static;

    # Fall back to index.html for any non-API path (SPA routing)
    $app->hook(before_dispatch => sub ($c) {
        my $path = $c->req->url->path->to_string;
        return if $path =~ m{^/api/};
        if ($path eq '/favicon.ico') {
            $c->req->url->path(Mojo::Path->new('/favicon.png'));
            return;
        }
        return if $path =~ m{\.\w+$};   # has an extension → real asset
        $c->req->url->path(Mojo::Path->new('/index.html'));
    });

    # API authentication — when password is set, require X-POPFile-Token header
    $app->hook(before_dispatch => sub ($c) {
        my $path = $c->req->url->path->to_string;
        return unless $path =~ m{^/api/};
        my $password = $self->config('password') // '';
        return if $password eq '';
        my $token = $c->req->headers->header('X-POPFile-Token') // '';
        return if $token eq $password;
        $c->render(status => 401, json => { error => 'Unauthorized' });
    });

    my $r = $app->routes;
    push $r->namespaces->@*, 'POPFile::API::Controller';
    my $languages_dir = $self->get_root_path('languages');
    $app->helper(popfile_api => sub ($c) { $self });
    $app->helper(popfile_svc => sub ($c) { $svc });
    $app->helper(popfile_session => sub ($c) {
        defined $svc && $svc->can('session') ? $svc->session() : ($session // '') });
    $app->helper(popfile_history => sub ($c) { defined $svc ? $svc->history_obj() : undef });
    $app->helper(popfile_imap => sub ($c) { $imap_service });
    $app->helper(popfile_loader => sub ($c) { $loader_ref });
    $app->helper(popfile_lang_dir => sub ($c) { $languages_dir });

    $r->get('/api/v1/buckets')->to('corpus#list_buckets');
    $r->post('/api/v1/buckets')->to('corpus#create_bucket');
    $r->delete('/api/v1/buckets/:name')->to('corpus#delete_bucket');
    $r->put('/api/v1/buckets/:name/rename')->to('corpus#rename_bucket');
    $r->delete('/api/v1/buckets/:name/words')->to('corpus#clear_bucket_words');
    $r->put('/api/v1/buckets/:name/params')->to('corpus#update_bucket_params');
    $r->get('/api/v1/buckets/:name/words')->to('corpus#get_bucket_words');
    $r->get('/api/v1/buckets/:name')->to('corpus#get_bucket');
    $r->get('/api/v1/corpus/:bucket/words')->to('corpus#list_bucket_words_with_accuracy');
    $r->delete('/api/v1/corpus/:bucket/word/:word')->to('corpus#remove_bucket_word');
    $r->post('/api/v1/corpus/:bucket/word/:word/move')->to('corpus#move_bucket_word');

    $r->get('/api/v1/stopwords')->to('corpus#list_stopwords');
    $r->post('/api/v1/stopwords')->to('corpus#create_stopword');
    $r->delete('/api/v1/stopwords/:word')->to('corpus#delete_stopword');
    $r->get('/api/v1/stopword-candidates')->to('corpus#list_stopword_candidates');
    $r->get('/api/v1/words/search')->to('corpus#search_words');

    $r->get('/api/v1/history')->to('history#list_history');
    $r->post('/api/v1/history/reclassify-unclassified')->to('history#reclassify_unclassified');
    $r->post('/api/v1/history/bulk-reclassify')->to('history#bulk_reclassify');
    $r->post('/api/v1/history/:slot/reclassify')->to('history#reclassify_item');
    $r->get('/api/v1/history/:slot')->to('history#get_history_item');

    $r->get('/api/v1/magnet-types')->to('magnets#list_magnet_types');
    $r->get('/api/v1/magnets')->to('magnets#list_magnets');
    $r->post('/api/v1/magnets')->to('magnets#create_magnet');
    $r->delete('/api/v1/magnets')->to('magnets#delete_magnet');

    $r->get('/api/v1/i18n')->to('Locale#list_locales');
    $r->get('/api/v1/languages')->to('Locale#list_languages');
    $r->get('/api/v1/i18n/:locale')->to('Locale#get_locale');

    $r->get('/api/v1/health')->to('Health#get_health');

    $r->get('/api/v1/config')->to('Config#get_config');
    $r->put('/api/v1/config')->to('Config#update_config');
    $r->get('/api/v1/status')->to('Config#get_status');

    $r->get('/api/v1/imap/folders')->to('IMAP#get_folders');
    $r->put('/api/v1/imap/folders')->to('IMAP#update_folders');
    $r->get('/api/v1/imap/server-folders')->to('IMAP#get_server_folders');
    $r->post('/api/v1/imap/test-connection')->to('IMAP#test_connection');
    $r->post('/api/v1/imap/train')->to('IMAP#trigger_training');
    $r->get('/api/v1/imap/train')->to('IMAP#training_status');
    $r->post('/api/v1/imap/rescan')->to('IMAP#rescan_folder');

    return $app
}


1;
