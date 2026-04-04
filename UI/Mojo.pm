# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
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

=head1 NAME

UI::Mojo - Mojolicious-based HTTP server for the POPFile web UI

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
use locale;

use POSIX ':sys_wait_h';
use Scalar::Util qw(looks_like_number);

class UI::Mojo :isa(POPFile::Module);

field $service = undef;
    field $child_pid = undef;

    BUILD {
        $self->set_name('mojo_ui');
    }

=head2 initialize

Registers configuration defaults: C<port> (8080), C<static_dir> (public),
and C<open_browser> (0).  Set C<port> to 0 to let the OS pick a free port
at startup.  Set C<open_browser> to 1 to open the UI in the default browser
once the server is ready (config key: C<mojo_ui_open_browser>).

=cut

    method initialize() {
        $self->config('port', 8080);
        $self->config('static_dir', 'public');
        $self->config('password', '');
        $self->config('local', 1);
        $self->config('page_size', 25);
        $self->config('date_format', '');
        $self->config('session_dividers', 1);
        $self->config('wordtable_format', '');
        $self->config('locale', '');
        $self->config('open_browser', 0);
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
            ReuseAddr => 1,
);
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
            $self->log_msg(0, "UI::Mojo: fork failed: $!");
            return 0;
        }
        if ($pid == 0) {
            eval { $self->run_server() };
            $self->log_msg(0, "UI::Mojo child error: $@") if $@;
            exit 0;
        }
        $child_pid = $pid;
        $self->log_msg(0, "UI::Mojo: started on port $port (pid $pid)");
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
                $self->log_msg(0, "UI::Mojo child exited unexpectedly");
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

        #--------------------------------------------------------------------
        # GET /api/v1/buckets
        #   Returns [{name, pseudo, word_count, color}, ...]
        #--------------------------------------------------------------------
        $r->get('/api/v1/buckets' => sub ($c) {
            my @result;
            for my $b ($svc->get_all_buckets()) {
                push @result, {
                    name => $b,
                    pseudo => $svc->is_pseudo_bucket($b) ? \1 : \0,
                    word_count => $svc->get_bucket_word_count($b) + 0,
                    color => $svc->get_bucket_color($b) // '#666666',
                };
            }
            $c->render(json => \@result);
        });

        #--------------------------------------------------------------------
        # POST /api/v1/buckets   { name, color? }
        #--------------------------------------------------------------------
        $r->post('/api/v1/buckets' => sub ($c) {
            my $body = $c->req->json // {};
            my $name = $body->{name} // '';
            my $color = $body->{color} // '';
            return $c->render(status => 400, json => { error => 'name required' })
                if $name eq '';
            return $c->render(status => 422, json => { error => 'invalid name: use lowercase letters, digits, - and _ only' })
                if $name =~ /[^a-z\-_0-9]/;
            my $ok = $svc->create_bucket($name);
            return $c->render(status => 409, json => { error => 'bucket already exists' })
                unless $ok;
            $svc->set_bucket_color($name, $color)
                if $color =~ /^#[0-9a-fA-F]{6}$/;
            $c->render(json => { ok => \1 });
        });

        #--------------------------------------------------------------------
        # DELETE /api/v1/buckets/:name
        #--------------------------------------------------------------------
        $r->delete('/api/v1/buckets/:name' => sub ($c) {
            $svc->delete_bucket($c->param('name'));
            $c->render(json => { ok => \1 });
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/buckets/:name/rename   { new_name }
        #--------------------------------------------------------------------
        $r->put('/api/v1/buckets/:name/rename' => sub ($c) {
            my $body = $c->req->json // {};
            my $new = $body->{new_name} // '';
            if ($new eq '') {
                return $c->render(status => 400, json => { error => 'new_name required' });
            }
            $svc->rename_bucket($c->param('name'), $new);
            $c->render(json => { ok => \1 });
        });

        #--------------------------------------------------------------------
        # DELETE /api/v1/buckets/:name/words  — clear all words
        #--------------------------------------------------------------------
        $r->delete('/api/v1/buckets/:name/words' => sub ($c) {
            $svc->clear_bucket($c->param('name'));
            $c->render(json => { ok => \1 });
        });

        #--------------------------------------------------------------------
        # PUT /api/v1/buckets/:name/params   { color }
        #--------------------------------------------------------------------
        $r->put('/api/v1/buckets/:name/params' => sub ($c) {
            my $body = $c->req->json // {};
            my $bname = $c->param('name');
            if (defined $body->{color}) {
                $svc->set_bucket_color($bname, $body->{color});
            }
            $c->render(json => { ok => \1 });
        });

        #--------------------------------------------------------------------
        # GET /api/v1/buckets/:name/words?prefix=…
        #   Returns [{word, count}, ...]
        #--------------------------------------------------------------------
        $r->get('/api/v1/buckets/:name/words' => sub ($c) {
            my $prefix = $c->param('prefix') // '';
            my @words = $svc->get_bucket_word_list($c->param('name'), $prefix);
            my @result = map { { word => $_->[0], count => $_->[1] + 0 } } @words;
            $c->render(json => \@result);
        });

        #--------------------------------------------------------------------
        # GET /api/v1/buckets/:name
        #   Returns { name, color, word_count, pseudo, fpcount, fncount }
        #--------------------------------------------------------------------
        $r->get('/api/v1/buckets/:name' => sub ($c) {
            my $name = $c->param('name');
            unless ($svc->is_bucket($name) || $svc->is_pseudo_bucket($name)) {
                return $c->render(status => 404, json => { error => 'not found' });
            }
            $c->render(json => {
                name => $name,
                color => $svc->get_bucket_color($name) // '#666666',
                word_count => $svc->get_bucket_word_count($name) + 0,
                pseudo => $svc->is_pseudo_bucket($name) ? \1 : \0,
                fpcount => ($svc->get_bucket_parameter($name, 'fpcount') // 0) + 0,
                fncount => ($svc->get_bucket_parameter($name, 'fncount') // 0) + 0,
            });
        });

        #--------------------------------------------------------------------
        # GET /api/v1/history?page=1&per_page=25&search=…
        #   Returns { items: [...], total: N }
        #--------------------------------------------------------------------
        $r->get('/api/v1/history' => sub ($c) {
            my $page = ($c->param('page')     // 1) + 0;
            my $per_page = ($c->param('per_page') // 25) + 0;
            my $search = $c->param('search') // '';
            $page = 1  if $page     < 1;
            $per_page = 25 if $per_page < 1 || $per_page > 200;

            my $hist = $svc->history_obj();
            my $qid = $hist->start_query();
            $hist->set_query($qid, '', $search, '-inserted', 0);
            my $total = $hist->get_query_size($qid);
            my $start = ($page - 1) * $per_page + 1;
            my @rows = $hist->get_query_rows($qid, $start, $per_page);
            $hist->stop_query($qid);

            my @items;
            for my $row (@rows) {
                next unless defined $row;
                # fields: id(0) from(1) to(2) cc(3) subject(4) date(5)
                #         hash(6) inserted(7) bucket_name(8) usedtobe(9)
                #         bucket_id(10) magnet(11) size(12)
                push @items, {
                    slot => $row->[0] + 0,
                    from => $row->[1] // '',
                    to => $row->[2] // '',
                    subject => $row->[4] // '',
                    date => $row->[5] // '',
                    bucket => $row->[8] // '',
                    color => $svc->get_bucket_color($row->[8] // '') // '#666666',
                    magnet => $row->[11] // '',
                };
            }
            $c->render(json => { items => \@items, total => $total + 0 });
        });

        my $do_reclassify = sub ($slot, $bucket) {
            my %known = map { $_ => 1 } $svc->get_all_buckets();
            return { error => 'unknown bucket' }
                unless $known{$bucket};
            my $hist = $svc->history_obj();
            my @fields = $hist->get_slot_fields($slot);
            return { error => 'invalid slot' }
                unless @fields;
            my $old_bucket = $fields[8];
            $hist->change_slot_classification($slot, $bucket, $session, 0);
            return {}
                unless defined $old_bucket && $old_bucket ne $bucket;
            my $file = $hist->get_slot_file($slot);
            $svc->remove_message_from_bucket($old_bucket, $file);
            $svc->add_message_to_bucket($bucket, $file);
            return {}
        };

        #--------------------------------------------------------------------
        # POST /api/v1/history/reclassify-unclassified
        #--------------------------------------------------------------------
        $r->post('/api/v1/history/reclassify-unclassified' => sub ($c) {
            my $hist = $svc->history_obj();
            my $qid = $hist->start_query();
            $hist->set_query($qid, 'unclassified', '', '-inserted', 0);
            my $total = $hist->get_query_size($qid);
            my @rows = $hist->get_query_rows($qid, 1, $total);
            $hist->stop_query($qid);
            my $updated = 0;
            for my $row (@rows) {
                next unless defined $row;
                my $slot = $row->[0];
                my $file = $hist->get_slot_file($slot);
                next unless defined $file;
                my $new_bucket = $svc->classify($file);
                next unless defined $new_bucket && $new_bucket ne 'unclassified';
                $hist->change_slot_classification($slot, $new_bucket, $session, 0);
                $updated++;
            }
            $c->render(json => { updated => $updated + 0, total => $total + 0 });
        });

        #--------------------------------------------------------------------
        # POST /api/v1/history/bulk-reclassify   { slots: [...], bucket }
        #--------------------------------------------------------------------
        $r->post('/api/v1/history/bulk-reclassify' => sub ($c) {
            my $body = $c->req->json // {};
            my $bucket = $body->{bucket} // '';
            my $slots = $body->{slots} // [];
            if ($bucket eq '' || ref $slots ne 'ARRAY' || !$slots->@*) {
                return $c->render(status => 400, json => { error => 'invalid params' });
            }
            my %known = map { $_ => 1 } $svc->get_all_buckets();
            unless ($known{$bucket}) {
                return $c->render(status => 422, json => { error => 'unknown bucket' });
            }
            my @valid_slots = grep { /^\d+$/ } $slots->@*;
            my $updated = 0;
            for my $slot (@valid_slots) {
                my $result = $do_reclassify->($slot, $bucket);
                $updated++
                    unless $result->{error};
            }
            $c->render(json => { updated => $updated + 0 });
        });

        #--------------------------------------------------------------------
        # POST /api/v1/history/:slot/reclassify   { bucket }
        #--------------------------------------------------------------------
        $r->post('/api/v1/history/:slot/reclassify' => sub ($c) {
            my $slot = $c->param('slot');
            my $body = $c->req->json // {};
            my $bucket = $body->{bucket} // '';
            if ($bucket eq '' || $slot !~ /^\d+$/) {
                return $c->render(status => 400, json => { error => 'invalid params' });
            }
            my $result = $do_reclassify->($slot, $bucket);
            if ($result->{error}) {
                return $c->render(status => 422, json => { error => $result->{error} });
            }
            $c->render(json => { ok => \1 });
        });

        #--------------------------------------------------------------------
        # GET /api/v1/history/:slot
        #   Returns message body and per-word bucket colors for highlighting.
        #--------------------------------------------------------------------
        $r->get('/api/v1/history/:slot' => sub ($c) {
            my $slot = $c->param('slot');
            return $c->render(status => 400, json => { error => 'invalid slot' })
                unless $slot =~ /^\d+$/;

            my $hist = $svc->history_obj();
            my $file = $hist->get_slot_file($slot);
            return $c->render(status => 404, json => { error => 'not found' })
                unless defined $file && -f $file;

            open my $fh, '<', $file
                or return $c->render(status => 500, json => { error => 'cannot read' });

            my $in_headers = 1;
            my $body = '';
            while (<$fh>) {
                s/[\r\n]//g;
                if ($in_headers) {
                    $in_headers = 0 if $_ eq '';
                    next;
                }
                $body .= "$_\n";
            }
            close $fh;

            my %orig_for;
            for my $raw (split /\W+/, $body) {
                next if $raw eq '';
                my $mangled = $svc->mangle_word($raw);
                next if $mangled eq '' || exists $orig_for{$mangled};
                $orig_for{$mangled} = lc $raw;
            }

            my %mangled_colors = $svc->get_word_colors(keys %orig_for);
            my %word_colors;
            for my $mangled (keys %mangled_colors) {
                $word_colors{ $orig_for{$mangled} } = $mangled_colors{$mangled};
            }

            $c->render(json => { body => $body, word_colors => \%word_colors });
        });

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
            imap_uidnexts => [imap => 'uidnexts'],
            imap_uidvalidities => [imap => 'uidvalidities'],
);

        my $languages_dir = $self->get_root_path('languages');

        #--------------------------------------------------------------------
        # GET /api/v1/i18n
        #   Returns [{name, code, direction}, ...] for each available locale
        #--------------------------------------------------------------------
        $r->get('/api/v1/i18n' => sub ($c) {
            my @locales;
            for my $file (sort glob "$languages_dir/*.msg") {
                my $name = $file;
                $name =~ s|.*/||;
                $name =~ s|\.msg$||;
                my ($code, $dir) = ('en', 'ltr');
                open my $fh, '<:encoding(UTF-8)', $file or next;
                while (my $line = <$fh>) {
                    chomp $line;
                    next if $line =~ /^#/ || $line !~ /\S/;
                    if ($line =~ /^LanguageCode\s+(\S+)/) { $code = $1 }
                    if ($line =~ /^LanguageDirection\s+(\S+)/) { $dir = $1 }
                    last if $code ne 'en' || $dir ne 'ltr';
                }
                close $fh;
                push @locales, { name => $name, code => $code, direction => $dir };
            }
            $c->render(json => \@locales);
        });

        #--------------------------------------------------------------------
        # GET /api/v1/i18n/:locale
        #   Returns { key => value, ... } for the given locale .msg file
        #--------------------------------------------------------------------
        $r->get('/api/v1/i18n/:locale' => sub ($c) {
            my $name = $c->param('locale');
            $name =~ s/[^A-Za-z0-9_\-]//g;
            my $file = "$languages_dir/$name.msg";
            return $c->render(status => 404, json => { error => 'locale not found' })
                unless -f $file;
            my %strings;
            open my $fh, '<:encoding(UTF-8)', $file or
                return $c->render(status => 500, json => { error => 'read error' });
            while (my $line = <$fh>) {
                chomp $line;
                next if $line =~ /^#/ || $line !~ /\S/;
                if ($line =~ /^(\S+)\s+(.+)/) {
                    $strings{$1} = $2;
                }
            }
            close $fh;
            $c->render(json => \%strings);
        });

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
            eval {
                unless ($client->connect()) {
                    die 'connect';
                }
                unless ($client->login()) {
                    die 'login';
                }
                $client->logout();
            };
            if ($@) {
                if ($@ =~ /^connect/) {
                    $err = 'Could not connect to server';
                }
                elsif ($@ =~ /^login/) {
                    $err = 'Login failed';
                }
                elsif ($@ =~ /POPFILE-IMAP-EXCEPTION: (.+?) \(/) {
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

        if ($self->config('open_browser')) {
            require Browser::Open;
            Browser::Open::open_browser("http://localhost:$port/");
        }

        $daemon->ioloop->start();
    }


1;
