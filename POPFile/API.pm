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

    #--------------------------------------------------------------------
    # GET /api/v1/magnet-types
    #   Returns { type: header_display_name, ... }
    #--------------------------------------------------------------------
    $r->get('/api/v1/magnet-types' => sub ($c) {
        my %types = $svc->get_magnet_types();
        $c->render(json => \%types);
    });

    #--------------------------------------------------------------------
    # GET /api/v1/magnets
    #   Returns { bucket: { type: [values] } }
    #--------------------------------------------------------------------
    $r->get('/api/v1/magnets' => sub ($c) {
        my %by_bucket;
        for my $b ($svc->get_buckets_with_magnets()) {
            for my $t ($svc->get_magnet_types_in_bucket($b)) {
                my @vals = $svc->get_magnets($b, $t);
                $by_bucket{$b}{$t} = \@vals if @vals;
            }
        }
        $c->render(json => \%by_bucket);
    });

    #--------------------------------------------------------------------
    # POST /api/v1/magnets   { bucket, type, value }
    #--------------------------------------------------------------------
    $r->post('/api/v1/magnets' => sub ($c) {
        my $body = $c->req->json // {};
        for my $k (qw(bucket type value)) {
            unless (defined $body->{$k} && $body->{$k} ne '') {
                return $c->render(status => 400,
                    json => { error => "$k required" });
            }
        }
        $svc->create_magnet($body->{bucket}, $body->{type}, $body->{value});
        $c->render(json => { ok => \1 });
    });

    #--------------------------------------------------------------------
    # DELETE /api/v1/magnets   { bucket, type, value }
    #--------------------------------------------------------------------
    $r->delete('/api/v1/magnets' => sub ($c) {
        my $body = $c->req->json // {};
        $svc->delete_magnet(
            $body->{bucket} // '', $body->{type} // '', $body->{value} // '');
        $c->render(json => { ok => \1 });
    });

    #--------------------------------------------------------------------
    # Config schema: key => [module, param]
    # Keys match the frontend's SECTIONS schema.
    #--------------------------------------------------------------------
    my %CFG = (
        mojo_ui_port => [mojo_ui => 'port'],
        mojo_ui_password => [mojo_ui => 'password'],
        mojo_ui_local => [mojo_ui => 'local'],
        mojo_ui_page_size => [mojo_ui => 'page_size'],
        mojo_ui_date_format => [mojo_ui => 'date_format'],
        mojo_ui_session_dividers => [mojo_ui => 'session_dividers'],
        mojo_ui_wordtable_format => [mojo_ui => 'wordtable_format'],
        mojo_ui_locale => [mojo_ui => 'locale'],
        pop3_port => [pop3 => 'port'],
        pop3_separator => [pop3 => 'separator'],
        pop3_local => [pop3 => 'local'],
        pop3_force_fork => [pop3 => 'force_fork'],
        pop3_toptoo => [pop3 => 'toptoo'],
        pop3_secure_server => [pop3 => 'secure_server'],
        pop3_secure_port => [pop3 => 'secure_port'],
        smtp_port => [smtp => 'port'],
        smtp_chain_server => [smtp => 'chain_server'],
        smtp_chain_port => [smtp => 'chain_port'],
        smtp_local => [smtp => 'local'],
        smtp_force_fork => [smtp => 'force_fork'],
        nntp_port => [nntp => 'port'],
        nntp_separator => [nntp => 'separator'],
        nntp_local => [nntp => 'local'],
        nntp_force_fork => [nntp => 'force_fork'],
        nntp_headtoo => [nntp => 'headtoo'],
        bayes_hostname => [bayes => 'hostname'],
        bayes_message_cutoff => [bayes => 'message_cutoff'],
        bayes_unclassified_weight => [bayes => 'unclassified_weight'],
        bayes_subject_mod_left => [bayes => 'subject_mod_left'],
        bayes_subject_mod_right => [bayes => 'subject_mod_right'],
        bayes_subject_mod_pos => [bayes => 'subject_mod_pos'],
        bayes_sqlite_tweaks => [bayes => 'sqlite_tweaks'],
        bayes_sqlite_journal_mode => [bayes => 'sqlite_journal_mode'],
        wordmangle_stemming => [wordmangle => 'stemming'],
        wordmangle_auto_detect_language => [wordmangle => 'auto_detect_language'],
        history_history_days => [history => 'history_days'],
        history_archive => [history => 'archive'],
        history_archive_dir => [history => 'archive_dir'],
        history_archive_classes => [history => 'archive_classes'],
        logger_level => [logger => 'level'],
        logger_logdir => [logger => 'logdir'],
        logger_log_to_stdout => [logger => 'log_to_stdout'],
        logger_log_sql => [logger => 'log_sql'],
        imap_enabled => [imap => 'enabled'],
        imap_hostname => [imap => 'hostname'],
        imap_port => [imap => 'port'],
        imap_login => [imap => 'login'],
        imap_password => [imap => 'password'],
        imap_use_ssl => [imap => 'use_ssl'],
        imap_update_interval => [imap => 'update_interval'],
        imap_expunge => [imap => 'expunge'],
        imap_training_mode => [imap => 'training_mode'],
        imap_training_error => [imap => 'training_error'],
        imap_uidnexts => [imap => 'uidnexts'],
        imap_uidvalidities => [imap => 'uidvalidities'],
);

    $r->get('/api/v1/i18n')->to('Locale#list_locales');
    $r->get('/api/v1/languages')->to('Locale#list_languages');
    $r->get('/api/v1/i18n/:locale')->to('Locale#get_locale');

    #--------------------------------------------------------------------
    # GET /api/v1/config  →  { key: value, ... }
    #--------------------------------------------------------------------
    $r->get('/api/v1/config' => sub ($c) {
        my %cfg;
        for my $key (keys %CFG) {
            my ($mod, $param) = $CFG{$key}->@*;
            $cfg{$key} = $self->module_config($mod, $param) // '';
        }
        $c->render(json => \%cfg);
    });

    #--------------------------------------------------------------------
    # PUT /api/v1/config  { key: value, ... }  →  persists to popfile.cfg
    #--------------------------------------------------------------------
    $r->put('/api/v1/config' => sub ($c) {
        my $body = $c->req->json // {};
        for my $key (keys $body->%*) {
            next unless exists $CFG{$key};
            my ($mod, $param) = $CFG{$key}->@*;
            $self->module_config($mod, $param, $body->{$key});
        }
        $self->configuration()->save_configuration();
        $c->render(json => { ok => \1 });
    });

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
    # GET /api/v1/status
    #   Returns health checks: IMAP connectivity, auth, watched folders,
    #   bucket→folder mapping validity
    #--------------------------------------------------------------------
    $r->get('/api/v1/status' => sub ($c) {
        require Services::IMAP::Client;
        my @checks;
        my $hostname = $self->module_config('imap', 'hostname') // '';
        my $port = $self->module_config('imap', 'port')     // '';
        my $login = $self->module_config('imap', 'login')    // '';
        unless ($hostname ne '' && $port ne '') {
            push @checks, {
                id => 'connectivity',
                label => 'IMAP Connectivity',
                status => 'warn',
                detail => 'IMAP not configured',
            };
            return $c->render(json => { checks => \@checks });
        }
        my $client = Services::IMAP::Client->new();
        $client->set_configuration($self->configuration());
        $client->set_mq($self->mq());
        $client->set_name('imap');
        unless ($client->connect()) {
            push @checks, {
                id => 'connectivity',
                label => 'IMAP Connectivity',
                status => 'error',
                detail => "Cannot reach $hostname:$port",
            };
            return $c->render(json => { checks => \@checks });
        }
        push @checks, {
            id => 'connectivity',
            label => 'IMAP Connectivity',
            status => 'ok',
            detail => "Connected to $hostname:$port",
        };
        unless ($client->login()) {
            push @checks, {
                id => 'authentication',
                label => 'IMAP Authentication',
                status => 'error',
                detail => "Login failed for $login",
            };
            return $c->render(json => { checks => \@checks });
        }
        push @checks, {
            id => 'authentication',
            label => 'IMAP Authentication',
            status => 'ok',
            detail => "Logged in as $login",
        };
        my @server_folders = $client->get_mailbox_list();
        $client->logout();
        my %on_server = map { $_ => 1 } @server_folders;
        my $watched_raw = $self->module_config('imap', 'watched_folders') // '';
        my @watched = grep { $_ ne '' } split /\Q$imap_sep\E/, $watched_raw;
        my @missing_w = grep { !$on_server{$_} } @watched;
        push @checks, {
            id => 'watched_folders',
            label => 'Watched Folders',
            status => @missing_w ? 'warn' : 'ok',
            detail => @missing_w
                ? 'Missing on server: ' . join(', ', @missing_w)
                : 'All ' . scalar(@watched) . ' watched folder(s) exist',
        };
        my $mapping_raw = $self->module_config('imap', 'bucket_folder_mappings') // '';
        my %map_hash = split /\Q$imap_sep\E/, $mapping_raw;
        my @missing_m = grep { $_ ne '' && !$on_server{$map_hash{$_}} } keys %map_hash;
        push @checks, {
            id => 'bucket_mappings',
            label => 'Bucket → Folder Mappings',
            status => @missing_m ? 'warn' : 'ok',
            detail => @missing_m
                ? 'Target folders missing: ' . join(', ', map { $map_hash{$_} } @missing_m)
                : 'All ' . scalar(keys %map_hash) . ' mapping(s) valid',
        };
        my $training_mode  = $self->module_config('imap', 'training_mode')  // 0;
        my $training_error = $self->module_config('imap', 'training_error') // '';
        if ($training_mode) {
            push @checks, {
                id => 'training_mode',
                label => 'Training Mode',
                status => 'warn',
                detail => 'Training in progress — will reset automatically when complete',
            };
        }
        elsif ($training_error ne '') {
            push @checks, {
                id => 'training_mode',
                label => 'Training Mode',
                status => 'error',
                detail => "Training failed: $training_error",
            };
        }
        $c->render(json => { checks => \@checks });
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
