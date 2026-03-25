# POPFILE LOADABLE MODULE
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

    field $service   = undef;
    field $child_pid = undef;

    BUILD {
        $self->set_name('mojo_ui');
    }

=head2 initialize

Registers configuration defaults: C<port> (8080) and C<static_dir> (public).

=cut

    method initialize {
        $self->config_( 'port',       8080 );
        $self->config_( 'static_dir', 'public' );
        return 1;
    }

=head2 start

Forks a child process running the Mojolicious daemon. Returns 1 on success.

=cut

    method start {
        my $pid = fork();
        if ( !defined $pid ) {
            $self->log_( 0, "UI::Mojo: fork failed: $!" );
            return 0;
        }
        if ( $pid == 0 ) {
            # --- child ---
            eval { $self->run_server() };
            $self->log_( 0, "UI::Mojo child error: $@" ) if $@;
            exit 0;
        }
        # --- parent ---
        $child_pid = $pid;
        $self->log_( 0, "UI::Mojo: started on port " . $self->config_('port') . " (pid $pid)" );
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
                $self->log_( 0, "UI::Mojo child exited unexpectedly" );
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
        my $port   = $self->config_( 'port' );
        my $static = $self->get_root_path_( $self->config_( 'static_dir' ) );

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
        # GET /api/v1/config
        #   Returns the subset of POPFile config params the UI cares about
        #--------------------------------------------------------------------
        my @config_keys = qw( html_port html_password bayes_hostname logger_level );
        $r->get( '/api/v1/config' => sub ($c) {
            my %cfg;
            for my $key ( @config_keys ) {
                # config keys are module__param formatted; try global first
                my $val = $self->global_config_( $key );
                $cfg{$key} = $val // '';
            }
            $c->render( json => \%cfg );
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/config   { key: value, ... }
        #--------------------------------------------------------------------
        $r->put( '/api/v1/config' => sub ($c) {
            my $body = $c->req->json // {};
            my %allowed = map { $_ => 1 } @config_keys;
            for my $key ( keys %{$body} ) {
                next unless $allowed{$key};
                $self->global_config_( $key, $body->{$key} );
            }
            $c->render( json => { ok => \1 } );
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
