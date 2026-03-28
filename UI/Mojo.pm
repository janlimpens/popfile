package UI::Mojo;

#----------------------------------------------------------------------------
#
# Mojolicious-based HTTP server providing:
#   - REST API at /api/v1/*  (consumed by the Svelte SPA)
#   - Static files from public/ (the built Svelte bundle)
#
# The server runs in a forked child process so it does not block POPFile's
# service() event loop.  The child creates its own session key and opens
# its own SQLite connection (clone of parent's) so there is no sharing of
# in-process state with the parent.
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#----------------------------------------------------------------------------

use Object::Pad;
use locale;

use POSIX ':sys_wait_h';
use Scalar::Util qw(looks_like_number);

class UI::Mojo :isa(POPFile::Module) {
    field $service = undef;
    field $child_pid = undef;

    BUILD {
        $self->set_name('mojo_ui');
    }

=head2 initialize

Registers configuration defaults: C<port> (8080) and C<static_dir> (public).

=cut

    method initialize {
        $self->config('port',             8080 );
        $self->config('static_dir',       'public' );
        $self->config('password',         '' );
        $self->config('local',            1 );
        $self->config('page_size',        25 );
        $self->config('date_format',      '' );
        $self->config('session_dividers', 1 );
        $self->config('wordtable_format', '' );
        return 1;
    }

=head2 start

Forks a child process running the Mojolicious daemon. Returns 1 on success.

=cut

    method start {
        my $pid = fork();
        if ( !defined $pid ) {
            $self->log_msg(0, "UI::Mojo: fork failed: $!" );
            return 0;
        }
        if ( $pid == 0 ) {
            # --- child ---
            eval { $self->run_server() };
            $self->log_msg(0, "UI::Mojo child error: $@" ) if $@;
            exit 0;
        }
        # --- parent ---
        $child_pid = $pid;
        $self->log_msg(0, "UI::Mojo: started on port " . $self->config('port') . " (pid $pid)" );
        return 1;
    }

=head2 stop

Sends SIGTERM to the child process and waits for it to exit.

=cut

    method stop {
        if ( defined $child_pid ) {
            kill 'TERM', $child_pid;
            waitpid( $child_pid, 0 );
            $child_pid = undef;
        }
    }

=head2 service

Checks whether the child process is still alive; logs a warning if it exited
unexpectedly. Returns 1.

=cut

    method service {
        if ( defined $child_pid ) {
            my $gone = waitpid( $child_pid, WNOHANG );
            if ( $gone == $child_pid ) {
                $self->log_msg(0, "UI::Mojo child exited unexpectedly" );
                $child_pid = undef;
            }
        }
        return 1;
    }

=head2 set_service

Injects the C<Services::Classifier> facade used by the child for REST calls.

=cut

    method set_service ( $svc = undef ) {
        $service = $svc;
    }


    #========================================================================
    # PRIVATE: child process — build Mojolicious app and run daemon
    #========================================================================
    method run_server {
        require Mojolicious;
        require Mojo::Server::Daemon;

        my $svc    = $service;
        my $port   = $self->config('port' );
        my $static = $self->get_root_path($self->config('static_dir' ) );

        # Reset DB connections inherited from the parent (force lazy re-clone)
        if ( defined $svc ) {
            my $history = $svc->history_obj();
            $history->forked() if defined $history;

            my $bayes = $svc->bayes();
            if ( defined $bayes ) {
                # Bayes::forked reinitialises the DB handle and prepared stmts
                $bayes->forked( undef );
            }
        }

        # Obtain a fresh session for this child process
        my $session = '';
        if ( defined $svc && defined $svc->bayes() ) {
            $session = $svc->bayes()->get_session_key( 'admin', '' );
        }

        my $app = Mojolicious->new();
        $app->log->level('warn');

        # Serve the built Svelte bundle as static files
        push @{ $app->static->paths }, $static;

        # Fall back to index.html for any non-API path (SPA routing)
        $app->hook( before_dispatch => sub ($c) {
            my $path = $c->req->url->path->to_string;
            return if $path =~ m{^/api/};
            return if $path =~ m{\.\w+$};   # has an extension → real asset
            $c->req->url->path( Mojo::Path->new('/index.html') );
        });

        my $r = $app->routes;

        #--------------------------------------------------------------------
        # GET /api/v1/buckets
        #   Returns [{name, pseudo, word_count, color}, ...]
        #--------------------------------------------------------------------
        $r->get( '/api/v1/buckets' => sub ($c) {
            my @result;
            for my $b ( $svc->get_all_buckets() ) {
                push @result, {
                    name       => $b,
                    pseudo     => $svc->is_pseudo_bucket($b) ? \1 : \0,
                    word_count => $svc->get_bucket_word_count($b) + 0,
                    color      => $svc->get_bucket_color($b) // '#666666',
                };
            }
            $c->render( json => \@result );
        });

        #--------------------------------------------------------------------
        # POST /api/v1/buckets   { name }
        #--------------------------------------------------------------------
        $r->post( '/api/v1/buckets' => sub ($c) {
            my $body = $c->req->json // {};
            my $name = $body->{name} // '';
            if ( $name eq '' ) {
                return $c->render( status => 400, json => { error => 'name required' } );
            }
            $svc->create_bucket( $name );
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # DELETE /api/v1/buckets/:name
        #--------------------------------------------------------------------
        $r->delete( '/api/v1/buckets/:name' => sub ($c) {
            $svc->delete_bucket( $c->param('name') );
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/buckets/:name/rename   { new_name }
        #--------------------------------------------------------------------
        $r->put( '/api/v1/buckets/:name/rename' => sub ($c) {
            my $body = $c->req->json // {};
            my $new  = $body->{new_name} // '';
            if ( $new eq '' ) {
                return $c->render( status => 400, json => { error => 'new_name required' } );
            }
            $svc->rename_bucket( $c->param('name'), $new );
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # DELETE /api/v1/buckets/:name/words  — clear all words
        #--------------------------------------------------------------------
        $r->delete( '/api/v1/buckets/:name/words' => sub ($c) {
            $svc->clear_bucket( $c->param('name') );
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/buckets/:name/params   { color }
        #--------------------------------------------------------------------
        $r->put( '/api/v1/buckets/:name/params' => sub ($c) {
            my $body  = $c->req->json // {};
            my $bname = $c->param('name');
            if ( defined $body->{color} ) {
                $svc->set_bucket_color( $bname, $body->{color} );
            }
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # GET /api/v1/buckets/:name/words?prefix=…
        #   Returns [{word, count}, ...]
        #--------------------------------------------------------------------
        $r->get( '/api/v1/buckets/:name/words' => sub ($c) {
            my $prefix = $c->param('prefix') // '';
            my @words  = $svc->get_bucket_word_list( $c->param('name'), $prefix );
            my @result = map { { word => $_->[0], count => $_->[1] + 0 } } @words;
            $c->render( json => \@result );
        });

        #--------------------------------------------------------------------
        # GET /api/v1/history?page=1&per_page=25&search=…
        #   Returns { items: [...], total: N }
        #--------------------------------------------------------------------
        $r->get( '/api/v1/history' => sub ($c) {
            my $page     = ( $c->param('page')     // 1  ) + 0;
            my $per_page = ( $c->param('per_page') // 25 ) + 0;
            my $search   = $c->param('search') // '';
            $page     = 1  if $page     < 1;
            $per_page = 25 if $per_page < 1 || $per_page > 200;

            my $hist  = $svc->history_obj();
            my $qid   = $hist->start_query();
            $hist->set_query( $qid, '', $search, '-inserted', 0 );
            my $total = $hist->get_query_size( $qid );
            my $start = ( $page - 1 ) * $per_page + 1;
            my @rows  = $hist->get_query_rows( $qid, $start, $per_page );
            $hist->stop_query( $qid );

            my @items;
            for my $row ( @rows ) {
                next unless defined $row;
                # fields: id(0) from(1) to(2) cc(3) subject(4) date(5)
                #         hash(6) inserted(7) bucket_name(8) usedtobe(9)
                #         bucket_id(10) magnet(11) size(12)
                push @items, {
                    slot    => $row->[0] + 0,
                    from    => $row->[1] // '',
                    to      => $row->[2] // '',
                    subject => $row->[4] // '',
                    date    => $row->[5] // '',
                    bucket  => $row->[8] // '',
                    color   => $svc->get_bucket_color( $row->[8] // '' ) // '#666666',
                    magnet  => $row->[11] // '',
                };
            }
            $c->render( json => { items => \@items, total => $total + 0 } );
        });

        #--------------------------------------------------------------------
        # POST /api/v1/history/:slot/reclassify   { bucket }
        #--------------------------------------------------------------------
        $r->post( '/api/v1/history/:slot/reclassify' => sub ($c) {
            my $slot   = $c->param('slot');
            my $body   = $c->req->json // {};
            my $bucket = $body->{bucket} // '';
            if ( $bucket eq '' || $slot !~ /^\d+$/ ) {
                return $c->render( status => 400, json => { error => 'invalid params' } );
            }

            my $hist = $svc->history_obj();

            # Update the classification record in History
            $hist->change_slot_classification( $slot, $bucket, $session, 0 );

            # Retrain: remove from old bucket, add to new
            my @fields = $hist->get_slot_fields( $slot );
            if ( @fields ) {
                my $file       = $hist->get_slot_file( $slot );
                my $old_bucket = $fields[8];
                if ( defined $old_bucket && $old_bucket ne $bucket ) {
                    $svc->remove_message_from_bucket( $old_bucket, $file );
                    $svc->add_message_to_bucket( $bucket, $file );
                }
            }

            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # GET /api/v1/magnet-types
        #   Returns { type: header_display_name, ... }
        #--------------------------------------------------------------------
        $r->get( '/api/v1/magnet-types' => sub ($c) {
            my %types = $svc->get_magnet_types();
            $c->render( json => \%types );
        });

        #--------------------------------------------------------------------
        # GET /api/v1/magnets
        #   Returns { bucket: { type: [values] } }
        #--------------------------------------------------------------------
        $r->get( '/api/v1/magnets' => sub ($c) {
            my %by_bucket;
            for my $b ( $svc->get_buckets_with_magnets() ) {
                for my $t ( $svc->get_magnet_types_in_bucket($b) ) {
                    my @vals = $svc->get_magnets( $b, $t );
                    $by_bucket{$b}{$t} = \@vals if @vals;
                }
            }
            $c->render( json => \%by_bucket );
        });

        #--------------------------------------------------------------------
        # POST /api/v1/magnets   { bucket, type, value }
        #--------------------------------------------------------------------
        $r->post( '/api/v1/magnets' => sub ($c) {
            my $body = $c->req->json // {};
            for my $k (qw(bucket type value)) {
                unless ( defined $body->{$k} && $body->{$k} ne '' ) {
                    return $c->render( status => 400,
                        json => { error => "$k required" } );
                }
            }
            $svc->create_magnet( $body->{bucket}, $body->{type}, $body->{value} );
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # DELETE /api/v1/magnets   { bucket, type, value }
        #--------------------------------------------------------------------
        $r->delete( '/api/v1/magnets' => sub ($c) {
            my $body = $c->req->json // {};
            $svc->delete_magnet(
                $body->{bucket} // '', $body->{type} // '', $body->{value} // '' );
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # Config schema: key => [module, param]
        # Keys match the frontend's SECTIONS schema.
        #--------------------------------------------------------------------
        my %CFG = (
            mojo_ui_port             => [mojo_ui => 'port'],
            mojo_ui_password         => [mojo_ui => 'password'],
            mojo_ui_local            => [mojo_ui => 'local'],
            mojo_ui_page_size        => [mojo_ui => 'page_size'],
            mojo_ui_date_format      => [mojo_ui => 'date_format'],
            mojo_ui_session_dividers => [mojo_ui => 'session_dividers'],
            mojo_ui_wordtable_format => [mojo_ui => 'wordtable_format'],
            pop3_port                => [pop3    => 'port'],
            pop3_separator           => [pop3    => 'separator'],
            pop3_local               => [pop3    => 'local'],
            pop3_force_fork          => [pop3    => 'force_fork'],
            pop3_toptoo              => [pop3    => 'toptoo'],
            pop3_secure_server       => [pop3    => 'secure_server'],
            pop3_secure_port         => [pop3    => 'secure_port'],
            smtp_port                => [smtp    => 'port'],
            smtp_chain_server        => [smtp    => 'chain_server'],
            smtp_chain_port          => [smtp    => 'chain_port'],
            smtp_local               => [smtp    => 'local'],
            smtp_force_fork          => [smtp    => 'force_fork'],
            nntp_port                => [nntp    => 'port'],
            nntp_separator           => [nntp    => 'separator'],
            nntp_local               => [nntp    => 'local'],
            nntp_force_fork          => [nntp    => 'force_fork'],
            nntp_headtoo             => [nntp    => 'headtoo'],
            bayes_hostname           => [bayes   => 'hostname'],
            bayes_message_cutoff     => [bayes   => 'message_cutoff'],
            bayes_unclassified_weight => [bayes  => 'unclassified_weight'],
            bayes_subject_mod_left   => [bayes   => 'subject_mod_left'],
            bayes_subject_mod_right  => [bayes   => 'subject_mod_right'],
            bayes_subject_mod_pos    => [bayes   => 'subject_mod_pos'],
            bayes_sqlite_tweaks      => [bayes   => 'sqlite_tweaks'],
            bayes_sqlite_journal_mode    => [bayes       => 'sqlite_journal_mode'],
            wordmangle_stemming          => [wordmangle  => 'stemming'],
            wordmangle_auto_detect_language => [wordmangle => 'auto_detect_language'],
            history_history_days     => [history => 'history_days'],
            history_archive          => [history => 'archive'],
            history_archive_dir      => [history => 'archive_dir'],
            history_archive_classes  => [history => 'archive_classes'],
            logger_level             => [logger  => 'level'],
            logger_logdir            => [logger  => 'logdir'],
            imap_enabled             => [imap    => 'enabled'],
            imap_hostname            => [imap    => 'hostname'],
            imap_port                => [imap    => 'port'],
            imap_login               => [imap    => 'login'],
            imap_password            => [imap    => 'password'],
            imap_use_ssl             => [imap    => 'use_ssl'],
            imap_update_interval     => [imap    => 'update_interval'],
            imap_expunge             => [imap    => 'expunge'],
            imap_training_mode       => [imap    => 'training_mode'],
        );

        #--------------------------------------------------------------------
        # GET /api/v1/config  →  { key: value, ... }
        #--------------------------------------------------------------------
        $r->get( '/api/v1/config' => sub ($c) {
            my %cfg;
            for my $key ( keys %CFG ) {
                my ( $mod, $param ) = @{ $CFG{$key} };
                $cfg{$key} = $self->module_config( $mod, $param ) // '';
            }
            $c->render( json => \%cfg );
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/config  { key: value, ... }  →  persists to popfile.cfg
        #--------------------------------------------------------------------
        $r->put( '/api/v1/config' => sub ($c) {
            my $body = $c->req->json // {};
            for my $key ( keys %{$body} ) {
                next unless exists $CFG{$key};
                my ( $mod, $param ) = @{ $CFG{$key} };
                $self->module_config( $mod, $param, $body->{$key} );
            }
            $self->configuration()->save_configuration();
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # GET /api/v1/imap/folders
        #   Returns { watched: [...], mappings: [{bucket, folder}, ...] }
        #--------------------------------------------------------------------
        my $imap_sep = '-->';
        $r->get( '/api/v1/imap/folders' => sub ($c) {
            my $watched_raw  = $self->module_config('imap', 'watched_folders')       // '';
            my $mapping_raw  = $self->module_config('imap', 'bucket_folder_mappings') // '';

            my @watched  = grep { $_ ne '' } split /\Q$imap_sep\E/, $watched_raw;
            my %map_hash = split /\Q$imap_sep\E/, $mapping_raw;
            my @mappings = map { { bucket => $_, folder => $map_hash{$_} } }
                           grep { $_ ne '' } keys %map_hash;

            $c->render( json => { watched => \@watched, mappings => \@mappings } );
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/imap/folders
        #   Body: { watched: [...], mappings: [{bucket, folder}, ...] }
        #--------------------------------------------------------------------
        $r->put( '/api/v1/imap/folders' => sub ($c) {
            my $body = $c->req->json // {};

            if ( defined $body->{watched} ) {
                my @w   = grep { defined $_ && $_ ne '' } @{ $body->{watched} };
                my $raw = join( $imap_sep, @w ) . ( @w ? $imap_sep : '' );
                $self->module_config('imap', 'watched_folders', $raw);
            }

            if ( defined $body->{mappings} ) {
                my $raw = '';
                for my $m ( @{ $body->{mappings} } ) {
                    next unless defined $m->{bucket} && $m->{bucket} ne ''
                             && defined $m->{folder} && $m->{folder} ne '';
                    $raw .= "$m->{bucket}$imap_sep$m->{folder}$imap_sep";
                }
                $self->module_config('imap', 'bucket_folder_mappings', $raw);
            }

            $self->configuration()->save_configuration();
            $c->render( json => { ok => \1 } );
        });

        #--------------------------------------------------------------------
        # GET /api/v1/imap/server-folders
        #   Connects to the IMAP server and returns the live folder list
        #--------------------------------------------------------------------
        $r->get( '/api/v1/imap/server-folders' => sub ($c) {
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
        # Start the daemon
        #--------------------------------------------------------------------
        my $daemon = Mojo::Server::Daemon->new(
            app    => $app,
            listen => [ "http://*:$port" ],
        );
        $daemon->run();
    }

} # end class UI::Mojo

1;
