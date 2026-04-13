# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::API;

=head1 NAME

POPFile::API - Mojolicious-based HTTP server for the POPFile web UI

=head1 DESCRIPTION

Provides the POPFile web interface as a Mojolicious application.  The server
runs in a forked child process so that it does not block POPFile's
C<service()> event loop.  The child opens its own database connection and
session key; no in-process state is shared with the parent.

The application exposes a REST API at C</api/v1/*> consumed by the Svelte
single-page application, and serves the built Svelte bundle from the
C<public/> directory (configurable via the C<static_dir> config key).

=cut

use Object::Pad;
use utf8;
use POPFile::Features;

use POSIX ':sys_wait_h';
use Scalar::Util qw(looks_like_number);
use Data::Page;

class POPFile::API :isa(POPFile::Module);

field $service = undef;
field $child_pid = undef;

BUILD {
    $self->set_name('mojo_ui');
}

=head2 initialize

Registers configuration defaults: C<port> (8080), C<static_dir> (public),
and C<open_browser> (0).  Set C<port> to 0 to let the OS pick a free port
at startup.  Set C<open_browser> to 1 to open the UI in the default browser
once the server is ready (config key: C<open_browser>).

=cut

method initialize() {
    # todo: $self->set_default($key => $val) when a value isn't there
    $self->config(port => 0); #8080);
    $self->config(static_dir => 'public');
    # $self->config(password => '');
    $self->config(local => 1);
    $self->config(page_size => 25);
    $self->config(date_format => '');
    $self->config(session_dividers => 1);
    $self->config(wordtable_format => '');
    $self->config(locale => '');
    $self->config(open_browser => 0);
    return 1
}

=head2 start

Forks a child process running the Mojolicious daemon. Returns 1 on success.

=cut

method _find_free_port() {
    require IO::Socket::INET;
    my $sock = IO::Socket::INET->new(
        Listen => 1,
        Proto => 'tcp',
        LocalAddr => '0.0.0.0',
        LocalPort => 0,
        ReuseAddr => 1 );
    my $port = $sock->sockport();
    $sock->close();
    return $port
}

method start() {
    my $port = $self->config('port');
    if ($port == 0) {
        $port = $self->_find_free_port();
        $self->config('port', $port);
    }
    my $pid = fork();
    if (!defined $pid) {
        $self->log_msg(0, "POPFile::API: fork failed: $!");
        return 0;
    }
    if ($pid == 0) {
        try { $self->run_server() }
        catch ($e) { $self->log_msg(0, "POPFile::API child error: $e") }
        exit 0;
    }
    $child_pid = $pid;
    $self->log_msg(0, "POPFile::API: started on port $port (pid $pid)");
    return 1
}

=head2 stop

Sends SIGTERM to the child process and waits for it to exit.

=cut

method stop() {
    if (defined $child_pid) {
        kill 'TERM', $child_pid;
        waitpid($child_pid, 0);
        $child_pid = undef;
    }
}

=head2 service

Checks whether the child process is still alive; logs a warning if it exited
unexpectedly. Returns 1.

=cut

method service() {
    if (defined $child_pid) {
        my $gone = waitpid($child_pid, WNOHANG);
        if ($gone == $child_pid) {
            $self->log_msg(0, "POPFile::API child exited unexpectedly");
            $child_pid = undef;
        }
    }
    return 1;
}

=head2 set_service

Injects the C<Services::Classifier> facade used by the child for REST calls.

=cut

method set_service ($svc = undef) {
    $service = $svc;
}


=head2 build_app

my $app = $self->build_app($svc, $session);

Constructs and returns the L<Mojolicious> application.  Called inside the
forked child.  C<$svc> is the L<Services::Classifier> instance (may be
C<undef> in tests); C<$session> is a pre-obtained Bayes session key used
by all request handlers.

=cut

method build_app ($svc, $session) {
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
        return if $path =~ m{\.\w+$};   # has an extension → real asset
        $c->req->url->path(Mojo::Path->new('/index.html'));
    });

    my $r = $app->routes;
    push $r->namespaces->@*, 'POPFile::API::Controller';
    my $languages_dir = $self->get_root_path('languages');
    $app->helper(popfile_api => sub ($c) { $self });
    $app->helper(popfile_svc => sub ($c) { $svc });
    $app->helper(popfile_session => sub ($c) { $session });
    $app->helper(popfile_history => sub ($c) { defined $svc ? $svc->history_obj() : undef });
    $app->helper(popfile_lang_dir => sub ($c) { $languages_dir });

    $r->get('/api/v1/buckets')->to('corpus#list_buckets');
    $r->post('/api/v1/buckets')->to('corpus#create_bucket');
    $r->delete('/api/v1/buckets/:name')->to('corpus#delete_bucket');
    $r->put('/api/v1/buckets/:name/rename')->to('corpus#rename_bucket');
    $r->delete('/api/v1/buckets/:name/words')->to('corpus#clear_bucket_words');
    $r->put('/api/v1/buckets/:name/params')->to('corpus#update_bucket_params');
    $r->get('/api/v1/buckets/:name/words')->to('corpus#get_bucket_words');
    $r->get('/api/v1/buckets/:name')->to('corpus#get_bucket');
    $r->get('/api/v1/stopwords')->to('corpus#list_stopwords');
    $r->post('/api/v1/stopwords')->to('corpus#create_stopword');
    $r->delete('/api/v1/stopwords/:word')->to('corpus#delete_stopword');
    $r->get('/api/v1/stopword-candidates')->to('corpus#list_stopword_candidates');

    $r->get('/api/v1/history')->to('history#list_history');
    $r->post('/api/v1/history/reclassify-unclassified')->to('history#reclassify_unclassified');
    $r->post('/api/v1/history/bulk-reclassify')->to('history#bulk_reclassify');
    $r->post('/api/v1/history/:slot/reclassify')->to('history#reclassify_item');
    $r->get('/api/v1/history/:slot')->to('history#get_history_item');

    $r->get('/api/v1/magnet-types')->to('magnets#list_magnet_types');
    $r->get('/api/v1/magnets')->to('magnets#list_magnets');
    $r->post('/api/v1/magnets')->to('magnets#create_magnet');
    $r->delete('/api/v1/magnets')->to('magnets#delete_magnet');

    #--------------------------------------------------------------------
    # Config schema: key => [module, param]
    # Keys match the frontend's SECTIONS schema.
    #--------------------------------------------------------------------
    $r->get('/api/v1/i18n')->to('Locale#list_locales');
    $r->get('/api/v1/languages')->to('Locale#list_languages');
    $r->get('/api/v1/i18n/:locale')->to('Locale#get_locale');

    $r->get('/api/v1/config')->to('Config#get_config');
    $r->put('/api/v1/config')->to('Config#update_config');
    $r->get('/api/v1/status')->to('Config#get_status');

    #--------------------------------------------------------------------
    # GET /api/v1/imap/folders
    #   Returns { watched: [...], mappings: [{bucket, folder}, ...] }
    #--------------------------------------------------------------------
    my $imap_sep = '-->';
    $r->get('/api/v1/imap/folders' => sub ($c) {
        my $watched_raw = $self->module_config('imap', 'watched_folders')       // '';
        my $mapping_raw = $self->module_config('imap', 'bucket_folder_mappings') // '';

        my @watched = grep { $_ ne '' } split /\Q$imap_sep\E/, $watched_raw;
        my %map_hash = split /\Q$imap_sep\E/, $mapping_raw;
        my @mappings = map { { bucket => $_, folder => $map_hash{$_} } }
                        grep { $_ ne '' } keys %map_hash;

        $c->render(json => { watched => \@watched, mappings => \@mappings });
    });

    #--------------------------------------------------------------------
    # PUT /api/v1/imap/folders
    #   Body: { watched: [...], mappings: [{bucket, folder}, ...] }
    #--------------------------------------------------------------------
    $r->put('/api/v1/imap/folders' => sub ($c) {
        my $body = $c->req->json // {};

        if (defined $body->{watched}) {
            my @w = grep { defined $_ && $_ ne '' } $body->{watched}->@*;
            my $raw = join($imap_sep, @w) . (@w ? $imap_sep : '');
            $self->module_config('imap', 'watched_folders', $raw);
        }

        if (defined $body->{mappings}) {
            my $raw = '';
            for my $m ($body->{mappings}->@*) {
                next unless defined $m->{bucket} && $m->{bucket} ne ''
                            && defined $m->{folder} && $m->{folder} ne '';
                $raw .= "$m->{bucket}$imap_sep$m->{folder}$imap_sep";
            }
            $self->module_config('imap', 'bucket_folder_mappings', $raw);
        }

        $self->configuration()->save_configuration();
        $c->render(json => { ok => \1 });
    });

    #--------------------------------------------------------------------
    # GET /api/v1/imap/server-folders
    #   Connects to the IMAP server and returns the live folder list
    #--------------------------------------------------------------------
    $r->get('/api/v1/imap/server-folders' => sub ($c) {
        require Services::IMAP::Client;
        my $client = Services::IMAP::Client->new();
        $client->set_configuration($self->configuration());
        $client->set_mq($self->mq());
        $client->set_name('imap');
        unless ($client->connect()) {
            return $c->render(status => 503, json => { error => 'connect failed' });
        }
        unless ($client->login()) {
            return $c->render(status => 503, json => { error => 'login failed' });
        }
        my @folders = $client->get_mailbox_list();
        $client->logout();
        $c->render(json => \@folders);
    });

    #--------------------------------------------------------------------
    # POST /api/v1/imap/test-connection
    #   Body: { hostname, port, login, password, use_ssl }
    #   Returns { ok: true } or { ok: false, error: "..." }
    #--------------------------------------------------------------------
    $r->post('/api/v1/imap/test-connection' => sub ($c) {
        require Services::IMAP::Client;
        my $body = $c->req->json // {};
        my $client = Services::IMAP::Client->new();
        $client->set_configuration($self->configuration());
        $client->set_mq($self->mq());
        $client->set_name('imap');
        $client->config('hostname', $body->{hostname} // '');
        $client->config('port',     $body->{port}     // 143);
        $client->config('login',    $body->{login}    // '');
        $client->config('password', $body->{password} // '');
        $client->config('use_ssl',  $body->{use_ssl}  // 0);
        my $err = '';
        try {
            unless ($client->connect()) {
                die 'connect';
            }
            unless ($client->login()) {
                die 'login';
            }
            $client->logout();
        }
        catch ($e) {
            if ($e =~ /^connect/) {
                $err = 'Could not connect to server';
            }
            elsif ($e =~ /^login/) {
                $err = 'Login failed';
            }
            elsif ($e =~ /POPFILE-IMAP-EXCEPTION: (.+?) \(/) {
                $err = $1;
            }
            else {
                $err = 'Connection test failed';
            }
            return $c->render(json => { ok => \0, error => $err });
        }
        $c->render(json => { ok => \1 });
    });

    return $app
}

=head2 run_server

$self->run_server();

Entry point for the forked child process.  Notifies the history and Bayes
modules that they are running in a fork, then calls L</build_app> and starts
the L<Mojo::Server::Daemon> on the configured port.  Does not return while
the server is running.

=cut

method run_server() {
    $ENV{MOJO_NO_SOCKS} = 1;
    require Mojo::Server::Daemon;

    my $svc = $service;
    my $port = $self->config('port');

    if (defined $svc) {
        my $history = $svc->history_obj();
        $history->forked() if defined $history;
        my $bayes = $svc->bayes();
        $bayes->forked(undef) if defined $bayes;
    }

    my $session = '';
    if (defined $svc && defined $svc->bayes()) {
        $session = $svc->bayes()->get_session_key('admin', '');
    }

    my $app = $self->build_app($svc, $session);

    my $daemon = Mojo::Server::Daemon->new(
        app => $app,
        listen => ["http://*:$port"],
);
    $daemon->start();

    my $loop = $daemon->ioloop;
    $SIG{INT}  = sub { $loop->stop() };
    $SIG{TERM} = sub { $loop->stop() };

    if ($self->config('open_browser')) {
        require Browser::Open;
        Browser::Open::open_browser("http://localhost:$port/");
    }

    $loop->start();
}


1;
