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

use Path::Tiny;
use POPFile::Role::Config;
use Scalar::Util qw(looks_like_number);
use Data::Page;

class POPFile::API :isa(POPFile::Module) :does(POPFile::Role::Config);

field $classifier_service = undef;
field $imap_service = undef;
field $loader_ref = undef;
field $activity_module = undef;
field $daemon_ref = undef;
field $port = 0;

BUILD {
    $self->set_name('api');
}

=head2 initialize

Registers configuration defaults: C<port> (7070), C<static_dir> (public),
and C<open_browser> (1).  Set C<port> to 0 to let the OS pick a free port
at startup.  Set C<open_browser> to 0 to suppress opening a browser when
the server is ready (config key: C<open_browser>).

=cut

method initialize() {
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
        if $self->config()->get('local');
    my $sock = IO::Socket::INET->new(
        %socket_args );
    my $port = $sock->sockport();
    $sock->close();
    return $port
}

method start() {
    require Mojo::Server::Daemon;
    my $resolved = $self->config()->get('port');
    $resolved = $self->_find_free_port()
        if $resolved == 0;
    $port = $resolved;
    my $base_path = $self->config()->get('base_path');
    my $app = $self->build_app($classifier_service, undef, $base_path);
    my $host = $self->config()->get('local')
        ? '127.0.0.1'
        : '*';
    my $daemon = Mojo::Server::Daemon->new(
        app => $app,
        listen => ["http://$host:$resolved"] );
    $daemon->silent(1);
    $daemon->start();
    $daemon_ref = $daemon;
    $self->log_msg(WARN => "POPFile::API: listening on port $resolved");
    if (($self->config()->get('open_browser')) && !$ENV{HARNESS_ACTIVE}) {
        require Browser::Open;
        my $url = "http://localhost:$resolved$base_path/";
        Browser::Open::open_browser($url)
            if $url =~ /^https?:\/\/localhost(?::\d+)?\/?$/;
    }
    return 1
}

=head2 daemon

Returns the in-process L<Mojo::Server::Daemon> instance, or C<undef> before
C<start()> is called.

=cut

method daemon() { return $daemon_ref }

=head2 url

Returns the base URL of the running web interface (e.g.
C<http://localhost:7070/>), or an empty string before C<start()> is called.

=cut

method url() {
    return ''
        unless defined $daemon_ref;
    return sprintf('http://localhost:%d/', $port)
}

=head2 stop

Stops the in-process daemon.

=cut

method stop() {
    if (defined $daemon_ref) {
        $daemon_ref->stop();
        $daemon_ref = undef;
    }
    return
}

=head2 service

No-op stub kept for Loader compatibility. Returns 1.

=cut

method service() { return 1 }

=head2 set_classifier_service

Injects the C<Services::Classifier> facade used by the child for REST calls.

=cut

method set_classifier_service ($svc = undef) {
    return $classifier_service = $svc
}

method set_imap ($svc = undef) {
    return $imap_service = $svc
}

method set_loader ($loader = undef) {
    return $loader_ref = $loader
}

method set_activity ($mod = undef) {
    return $activity_module = $mod
}


=head2 build_app

my $app = $self->build_app($svc, $session);

Constructs and returns the L<Mojolicious> application.  Called inside the
forked child.  C<$svc> is the L<Services::Classifier> instance (may be
C<undef> in tests); C<$session> is a pre-obtained Bayes session key used
by all request handlers.

=cut

method build_app ($svc, $session = undef, $base_path = '') {
    require Mojolicious;
    require Mojo::Path;

    my $static = $self->get_root_path($self->config()->get('static_dir'));
    require Cwd;
    $static = Cwd::realpath($static) // $static;
    my $app = Mojolicious->new();
    $app->max_request_size(10_000_000);
    $app->log()->level('warn');

    if ($base_path) {
        $base_path =~ s{/+$}{};
        $app->hook(before_dispatch => sub ($c) {
            my $path = $c->req()->url()->path()->to_string();
            return
                unless $path =~ s{^\Q$base_path\E}{};
            $path ||= '/';
            $c->req()->url()->path()->parse($path);
            $c->req()->url()->base()->path($base_path . '/');
            return
                unless $path eq '/';
            my $html = path($static, 'index.html')->slurp_utf8();
            $html =~ s{<head>}{<head><base href="$base_path/">};
            $c->render(text => $html, format => 'html');
        });
    }

    $app->hook(after_dispatch => sub ($c) {
        $c->res()->headers()->header('X-Content-Type-Options' => 'nosniff');
        $c->res()->headers()->header('X-Frame-Options' => 'DENY');
        $c->res()->headers()->header('Referrer-Policy' => 'no-referrer');
        $c->res()->headers()->header('Permissions-Policy' => 'interest-cohort=()');
    });

    push $app->static()->paths->@*, $static;

    my %rate_limit;
    $app->hook(before_dispatch => sub ($c) {
        return unless $c->req()->url()->path()->to_string() =~ m{^/api/};
        my $ip = $c->tx()->remote_address() // '127.0.0.1';
        my $now = time();
        my $window = $rate_limit{$ip} // [0, $now];
        if ($now - $window->[1] > 1) {
            $window = [1, $now];
            $rate_limit{$ip} = $window;
        }
        elsif (++$window->[0] > 60) {
            $c->render(status => 429, json => { error => 'Too many requests' });
            return;
        }
    });

    $app->hook(before_dispatch => sub ($c) {
        my $path = $c->req()->url()->path()->to_string();
        return
            unless $path =~ m{^/api/};
        my $password = $self->config()->get('password') // '';
        return
            if $password eq '';
        my $local = $self->config()->get('local') // 1;
        return
            if $local && $c->req()->method() eq 'GET';
        return
            if $local && $c->req()->method() eq 'HEAD';
        my $token = $c->req()->headers()->header('X-POPFile-Token') // '';
        return
            if $token eq $password;
        $c->render(
            status => 403,
            json => { error => 'Forbidden' });
        return();
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
    $app->helper(popfile_activity => sub ($c) { $activity_module });

    my $api = $r->under('/api/v1');
    $api->get('/buckets')->to('corpus#list_buckets');
    $api->post('/buckets')->to('corpus#create_bucket');
    $api->get('/buckets/:id')->to('corpus#get_bucket');
    $api->delete('/buckets/:id')->to('corpus#delete_bucket');
    $api->put('/buckets/:id/rename')->to('corpus#rename_bucket');
    $api->get('/buckets/:id/words')->to('corpus#get_bucket_words');
    $api->get('/buckets/:id/words/accuracy')->to('corpus#list_bucket_words_with_accuracy');
    $api->delete('/buckets/:id/words')->to('corpus#clear_bucket_words');
    $api->put('/buckets/:id/params')->to('corpus#update_bucket_params');
    $api->delete('/buckets/:id/word_id/:word_id')->to('corpus#remove_bucket_word');
    $api->post('/buckets/:id/word_id/:word_id/move')->to('corpus#move_bucket_word');

    $api->get('/stopwords')->to('corpus#list_stopwords');
    $api->get('/stopword-candidates')->to('corpus#list_stopword_candidates');
    $api->get('/words/search')->to('corpus#search_words');

    $api->get('/history')->to('history#list_history');
    $api->post('/history/reclassify-unclassified')->to('history#reclassify_unclassified');
    $api->post('/history/bulk-reclassify')->to('history#bulk_reclassify');
    $api->post('/history/:slot/reclassify')->to('history#reclassify_item');
    $api->get('/history/:slot')->to('history#get_history_item');

    $api->get('/magnet-types')->to('magnets#list_magnet_types');
    $api->get('/magnets')->to('magnets#list_magnets');
    $api->post('/magnets')->to('magnets#create_magnet');
    $api->delete('/magnets')->to('magnets#delete_magnet');

    $api->get('/i18n')->to('Locale#list_locales');
    $api->get('/languages')->to('Locale#list_languages');
    $api->get('/i18n/:locale')->to('Locale#get_locale');

    $api->get('/health')->to('Health#get_health');

    $api->get('/config')->to('Config#get_config');
    $api->put('/config')->to('Config#update_config');
    $api->post('/restart')->to('Config#restart');
    $api->get('/status')->to('Config#get_status');
    $api->get('/timezones')->to('Config#get_timezones');

    $api->get('/imap/folders')->to('IMAP#get_folders');
    $api->put('/imap/folders')->to('IMAP#update_folders');
    $api->get('/imap/server-folders')->to('IMAP#get_server_folders');
    $api->post('/imap/test-connection')->to('IMAP#test_connection');
    $api->post('/imap/train')->to('IMAP#trigger_training');
    $api->get('/imap/train')->to('IMAP#training_status');
    $api->post('/imap/rescan')->to('IMAP#rescan_folder');
    $api->post('/imap/verify-folders')->to('IMAP#verify_folder_placement');
    $api->get('/imap/verify-folders/*folder_name')->to('IMAP#verify_folder_mismatches');
    $api->post('/imap/move-messages')->to('IMAP#move_messages');
    $api->post('/imap/reclassify-preview')->to('IMAP#reclassify_preview');
    $api->get('/imap/move-queue')->to('IMAP#move_queue');
    $api->get('/imap/move-queue/count')->to('IMAP#move_queue_count');
    $api->post('/imap/move-queue/clear')->to('IMAP#move_queue_clear');

    $api->get('/activity')->to('activity#recent');
    $api->get('/activity/stream')->to('activity#stream');

    $api->get('/logs/tail')->to('logs#tail');
    $api->get('/logs/download')->to('logs#download');

    $r->get('/')->to('UI#index');

    return $app
}


1;
