package POPFile::API::Controller::IMAP;

=head1 NAME

POPFile::API::Controller::IMAP - IMAP folder configuration and diagnostic endpoints

=head1 DESCRIPTION

Handles all C</api/v1/imap/*> routes for IMAP folder management and server
diagnostics. Uses C<Services::IMAP::Client> (lazy-loaded) to test connections
and retrieve live folder lists from the IMAP server.

Services are accessed via the Mojolicious helpers registered in
L<POPFile::API/build_app>: C<popfile_api> for configuration access.

=cut

use Mojo::Base 'Mojolicious::Controller', -signatures;
use Mojo::IOLoop;
use POPFile::Features;

sub _make_test_client($self, $body) {
    require Services::IMAP::Client;
    my $api = $self->popfile_api();
    my $client = Services::IMAP::Client->new();
    $client->set_mq($api->mq());
    $client->set_name('imap');
    $client->set_test_credentials(
        hostname => $body->{hostname} // '',
        port => $body->{port} // 143,
        use_ssl => $body->{use_ssl} // 0,
        login => $body->{login} // '',
        password => $body->{password} // '',
    );
    return $client
}

sub get_folders ($self) {
    my $imap = $self->popfile_imap();
    my @watched = ();
    my @mappings = ();
    if (defined $imap) {
        try {
            @watched = $imap->watched_folders();
            my $classifier = $imap->classifier();
            if ($classifier) {
                my $session = $imap->api_session();
                for my $bucket ($classifier->get_all_buckets($session)) {
                    my $folder = $imap->folder_for_bucket($bucket);
                    push @mappings, { bucket => $bucket, folder => $folder // '' }
                        if defined $folder;
                }
            }
        }
        catch ($e) {
            $self->app->log->error("get_folders: $e");
        }
    }
    $self->render(json => { watched => \@watched, mappings => \@mappings });
}

sub update_folders ($self) {
    my $imap = $self->popfile_imap();
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless defined $imap;
    my $body = $self->req->json // {};
    if (defined $body->{watched}) {
        my @w = grep { defined $_ && $_ ne '' } $body->{watched}->@*;
        $imap->watched_folders(@w);
    }
    if (defined $body->{mappings}) {
        for my $m ($body->{mappings}->@*) {
            next()
                unless $m->{bucket} && $m->{folder};
            $imap->folder_for_bucket($m->{bucket}, $m->{folder});
        }
    }
    $self->render(json => { ok => \1 });
}

sub get_server_folders ($self) {
    require Services::IMAP::Client;
    my $api = $self->popfile_api();
    my $client = Services::IMAP::Client->new();
    $client->set_mq($api->mq());
    $client->set_name('imap');
    unless ($client->connect()) {
        return $self->render(status => 503, json => { error => 'connect failed' });
    }
    unless ($client->login()) {
        return $self->render(status => 503, json => { error => 'login failed' });
    }
    my @folders = $client->get_mailbox_list();
    $client->logout();
    $self->render(json => \@folders);
}

sub test_connection ($self) {
    my $body = $self->req->json // {};
    my $client = $self->_make_test_client($body);
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
        my $err;
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
        return $self->render(json => { ok => \0, error => $err });
    }
    $self->render(json => { ok => \1 });
}

sub _touch($path) {
    open my $fh, '>', $path or return 0;
    close $fh;
    return 1
}

sub trigger_training ($self) {
    require POPFile::ConfigFile;
    my $api = $self->popfile_api();
    my $body = $self->req->json // {};
    my @buckets = ref $body->{buckets} eq 'ARRAY' ? $body->{buckets}->@* : ();
    my $all = $body->{all} || !@buckets;
    my $path = POPFile::Config->resolve_path();
    my $data = POPFile::ConfigFile->new()->load($path);
    $data->{imap}{training_error} = '';
    POPFile::ConfigFile->new()->save($path, $data);
    my @queued;
    if ($all) {
        my $flag = $api->get_user_path('popfile.train');
        return $self->render(status => 500, json => { error => 'cannot create flag' })
            unless defined $flag && _touch($flag);
        push @queued, '*';
    } else {
        for my $bucket (grep { /^[a-z0-9_-]+$/ } @buckets) {
            my $flag = $api->get_user_path("popfile.train.$bucket");
            next()
                unless defined $flag && _touch($flag);
            push @queued, $bucket;
        }
    }
    $self->render(json => { ok => \1, queued => \@queued });
}

sub training_status ($self) {
    my $api = $self->popfile_api();
    my $pattern = $api->get_user_path('popfile.train*', 0);
    my @flags = defined $pattern ? glob($pattern) : ();
    my @pending = map {
        /popfile\.train\.(.+)$/ ? $1 : '*'
    } @flags;
    $self->render(json => { pending => \@pending });
}

sub rescan_folder ($self) {
    my $imap = $self->popfile_imap();
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless defined $imap;
    my $body = $self->req->json // {};
    my $folder = $body->{folder} // '';
    return $self->render(status => 400, json => { error => 'folder required' })
        unless $folder;
    $imap->request_folder_rescan($folder);
    $self->render(json => { queued => \1, folder => $folder });
}

sub verify_folder_placement ($self) {
    my $imap = $self->popfile_imap;
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless $imap;
    my $svc = $self->popfile_svc;
    my $hist = $svc->history_obj();
    my $qid = $hist->queries()->start();
    $hist->set_query($qid, 'unclassified', '', '-inserted', 1);
    my $total = $hist->queries()->session_count($qid);
    my @rows = $hist->queries()->rows($qid, 1, $total);
    $hist->queries()->stop($qid);
    $self->_verify_batched(
        rows => \@rows,
        hist => $hist,
        imap => $imap,
        total => $total,
    );
}

my $VERIFY_BATCH_SIZE = 25;

sub _verify_batched ($self, %args) {
    my $rows = $args{rows};
    my $hist = $args{hist};
    my $imap = $args{imap};
    my $total = $args{total};
    my $processed = 0;
    $self->render_later;
    my $next;
    $next = sub {
        my $count = 0;
        while ($count < $VERIFY_BATCH_SIZE && $rows->@*) {
            my $row = shift $rows->@*;
            $count++;
            next()
                unless defined $row;
            my $slot = $row->[0];
            my $hash = $row->[6];
            my $bucket = $row->[8];
            next()
                unless $hash && $bucket;
            my $file = $hist->get_slot_file($slot);
            next()
                unless $file;
            my $mid = $self->_extract_mid($file);
            unless (defined $mid) {
                $processed++;
                next();
            }
            $imap->cache_message_id($hash, $mid);
            $hist->set_message_id($slot, $mid);
            $imap->request_folder_move($hash, $bucket);
            $processed++;
        }
        if ($rows->@*) {
            Mojo::IOLoop->timer(0 => $next);
        } else {
            $self->render(json => { processed => $processed + 0, total => $total + 0 });
        }
    };
    Mojo::IOLoop->timer(0 => $next);
}

sub _extract_mid ($self, $file) {
    return
        unless $file && -f $file;
    open my $fh, '<:raw', $file
        or return;
    while (my $line = <$fh>) {
        last()
            if $line =~ /^\r?\n$/;
        if ($line =~ /^message-id:\s*(.+)/is) {
            (my $mid = $1) =~ s/\r?\n//;
            $mid =~ s/^<|>$//g;
            close $fh;
            return $mid
        }
    }
    close $fh;
    return
}

sub _imap_sep ($self) {
    return '-->'
}

sub verify_folder_mismatches ($self) {
    my $imap = $self->popfile_imap;
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless $imap;
    my $folder_name = $self->param('folder_name');
    return $self->render(status => 400, json => { error => 'folder_name required' })
        unless $folder_name;
    my $svc = $self->popfile_svc;
    my $hist = $svc->history_obj();
    my $qid = $hist->queries()->start();
    $hist->set_query($qid, 'unclassified', '', '-inserted', 1);
    my $total = $hist->queries()->session_count($qid);
    return $self->render(json => { folder => $folder_name, messages => [], total => 0 })
        unless $total;
    my @rows = $hist->queries()->rows($qid, 1, $total);
    $hist->queries()->stop($qid);
    my @messages;
    for my $row (@rows) {
        next()
            unless defined $row;
        my $bucket = $row->[8];
        next()
            unless $bucket;
        my $target_folder = $imap->folder_for_bucket($bucket);
        next()
            unless defined $target_folder;
        next()
            if $target_folder eq $folder_name;
        push @messages, {
            slot => $row->[0] + 0,
            hash => $row->[6],
            mid => $row->[13],
            bucket => $bucket,
            target_folder => $target_folder,
            subject => $row->[4],
            from => $row->[1],
            date => $row->[5],
        };
    }
    $self->render(json => { folder => $folder_name, messages => \@messages, total => scalar @messages });
}

sub move_messages ($self) {
    my $imap = $self->popfile_imap;
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless $imap;
    my $body = $self->req->json // {};
    my $moves = $body->{moves} // [];
    return $self->render(status => 400, json => { error => 'moves required' })
        unless ref $moves eq 'ARRAY' && $moves->@*;
    my $hist = $self->popfile_svc->history_obj();
    my $queued = 0;
    for my $move ($moves->@*) {
        my $hash = $move->{hash};
        my $bucket = $move->{bucket};
        my $mid = $move->{mid};
        next()
            unless $hash && $bucket;
        if ($mid) {
            $imap->cache_message_id($hash, $mid);
        }
        $imap->request_folder_move($hash, $bucket);
        $queued++;
    }
    try { $imap->flush_moves() } catch($e) {};
    $self->render(json => { queued => $queued + 0 });
}

sub reclassify_preview ($self) {
    my $imap = $self->popfile_imap();
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless defined $imap;
    my $body = $self->req->json // {};
    my $folder = $body->{folder} // '';
    return $self->render(status => 400, json => { error => 'folder required' })
        unless $folder;
    my $limit = $body->{limit} // 200;
    my $result = $imap->preview_reclassification($folder, $limit);
    $self->render(json => $result);
}

sub move_queue ($self) {
    my $imap = $self->popfile_imap();
    return $self->render(status => 503, json => { error => 'IMAP not available' })
        unless defined $imap;
    my $direct = $imap->pending_direct_moves();
    my $passive = $imap->pending_folder_moves();
    my @direct_list;
    push @direct_list, { hash => $_, target_bucket => $direct->{$_}{target_bucket}, mid => $direct->{$_}{mid} }
        for keys %$direct;
    my @passive_list = map { { hash => $_, target_bucket => $passive->{$_} } } keys %$passive;
    $self->render(json => {
        direct_moves => \@direct_list,
        passive_moves => \@passive_list,
    });
}

1;
