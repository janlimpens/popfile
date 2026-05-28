# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use feature 'try';
no warnings 'experimental::try';
use Fcntl ();
use Mojo::IOLoop;
use Encode ();
use Services::IMAP::Client;
use Services::IMAP::Folder;
use POPFile::Role::DBConnect;
use POPFile::Role::Config;

class Services::IMAP
    :isa(POPFile::Module)
    :does(POPFile::Role::DBConnect)
    :does(POPFile::Role::Config);


=head1 NAME

Services::IMAP — IMAP monitoring service that classifies and sorts mail

=head1 DESCRIPTION

C<Services::IMAP> polls one or more IMAP folders at a configurable interval,
classifies new messages with the Bayes engine, and moves them to the
bucket-mapped output folder.  It also supports reclassification: when a
message already in the history appears in an output folder it has not been
seen in before, the service treats that as a user correction and retrains.

A one-time bulk training mode (C<training_mode>) iterates over all output
folders and feeds their contents to the classifier without moving anything.

The service is disabled by default (C<enabled = 0>) and requires
C<hostname>, C<login>, and C<password> to be configured before it will
connect.

=head1 METHODS

=cut

use constant REAPPEARED_UNKNOWN_BUCKET => 'unknown';

field $classifier :reader :writer(set_classifier) = 0;
field $history :reader :writer(set_history) = 0;
field $activity :reader :writer(set_activity) = undef;
field %folders;
field @mailboxes;
field $folder_change_flag :reader = 0;
field %hash_values;
field %pending_folder_moves;
field $api_session = '';
field $imap_error = '';
field $last_update = 0;
field $timer_id = undef;
field $imap_worker = undef;
field $poll_trigger = undef;
field @pending_train_flags;
field @pending_train_buckets;
field %_uid_next_override;
field %hash_to_mid;
field %pending_direct_moves;
field $training_mode :reader = 0;
field $training_error :reader = '';
field $poll_result_received = 0;
field $poll_running = 0;

use Cpanel::JSON::XS ();

my $cfg_separator = "-->";

BUILD {
    $self->set_name('imap');
}


=head2 initialize()

Registers all IMAP configuration parameters with their defaults: C<hostname>,
C<port> (143), C<login>, C<password>, C<update_interval> (20 s), C<expunge>,
C<use_ssl>, C<watched_folders>,
C<enabled> (0), C<training_mode> (0).  Returns 1.

=cut

method initialize() {
    $last_update = time - ($self->config->get('update_interval') // 300);
    return 1
}

=head2 start() (first - old POD)

=head2 folders()

Returns the current C<%folders> map as a hashref.  Keys are folder names,
values are hashes with C<watched>, C<output>, and C<imap> keys.

=cut

method folders() { \%folders }

=head2 mailboxes()

Returns the current C<@mailboxes> list from the last C<get_mailbox_list()> call.

=cut

method mailboxes() { \@mailboxes }

=head2 pending_folder_moves()

Returns the current C<%pending_folder_moves> as a hashref (hash → target bucket).

=cut

method pending_folder_moves() { \%pending_folder_moves }

=head2 start()

Registers a recurring C<Mojo::IOLoop> timer that calls C<poll()> every
C<update_interval> seconds.  Returns 1.

=cut

method start() {
    try {
        $self->_ensure_folder_tables();
        $self->_migrate_folder_config();
    }
    catch ($e) {
        $self->log_msg(WARN => "IMAP folder table setup skipped: $e")
            unless $e =~ /unable to open/i;
    }
    pipe(my $child_reader, my $parent_writer);
    $parent_writer->autoflush(1);
    $imap_worker = Mojo::IOLoop->subprocess(
        sub ($subprocess) {
            $self->_imap_worker_loop($subprocess, $child_reader);
        },
        sub {
            $self->log_msg(WARN => "IMAP worker exited unexpectedly");
            $imap_worker = undef;
        }
    );
    $imap_worker->on(progress => sub {
        my ($sp, %raw) = @_;
        return
            if $raw{type} && $raw{type} eq 'poll_result'
            && $self->_handle_poll_result(\%raw);
        $self->_handle_activity_progress(\%raw);
    });
    $poll_trigger = $parent_writer;
    my $interval = $self->config->get('update_interval');
    $timer_id = Mojo::IOLoop->recurring($interval => sub { $self->poll() });
    if ($self->config->get('enabled') && defined $activity) {
        my $host = $self->config->get('hostname') || 'not configured';
        my $port = $self->config->get('port') || 143;
        my $ssl = $self->config->get('use_ssl') ? ' (SSL)' : '';
        $activity->add_event({
            level => 'info',
            module => 'imap',
            task => 'IMAP Service',
            message => "Service started, polling $host:$port$ssl every ${interval}s",
        });
    }
    return 1
}

=head2 stop()

Removes the recurring IOLoop timer and disconnects all open IMAP connections
via C<disconnect_folders()>.

=cut

method stop() {
    Mojo::IOLoop->remove($timer_id) if defined $timer_id;
    $timer_id = undef;
    if ($poll_trigger) {
        syswrite($poll_trigger, "quit\n");
    }
    $poll_trigger = undef;
    $imap_worker = undef;
}

=head2 service()

No-op; polling is driven by the C<Mojo::IOLoop> recurring timer registered in
C<start()>.  Returns 1.

=cut

method service() {
    return 1
}

=head2 poll()

Invoked by the recurring IOLoop timer.  Skips if IMAP is disabled and
C<training_mode> is off, or if a previous poll is still running (C<$poll_running>
guard).  Launches a C<Mojo::IOLoop-E<gt>subprocess> that runs all IMAP I/O and
Bayes DB writes without blocking the IOLoop.  The result callback writes
C<uid_nexts> config, clears C<training_mode> if training completed, and posts
C<IMAP_DONE> to the MQ.

=cut

method poll() {
    return
        if $poll_running;
    $poll_running = 1;
    my @flags = $self->_find_train_flags();
    if (@flags) {
        @pending_train_flags = @flags;
        @pending_train_buckets = ();
        for my $flag (@flags) {
            push @pending_train_buckets, $1
                if $flag =~ /popfile\.train\.(.+)$/;
        }
        $training_mode = 1;
    }
    return
        if $self->config->get('enabled') == 0
        && $self->training_mode == 0;
    return
        unless defined $poll_trigger;
    my $msg = Cpanel::JSON::XS->new->encode({
        cmd => 'poll',
        training_mode => $training_mode,
        train_buckets => \@pending_train_buckets,
        pending_folder_moves => \%pending_folder_moves,
        pending_direct_moves => \%pending_direct_moves,
        uid_next_overrides => \%_uid_next_override,
        folder_change_flag => $folder_change_flag,
    });
    my $data = $msg . "\n";
    my $written = 0;
    while ($written < length($data)) {
        my $n = syswrite($poll_trigger, $data, length($data) - $written, $written);
        unless (defined $n) {
            $self->log_msg(WARN => "IMAP poll trigger failed: $!");
            return;
        }
        $written += $n;
    }
}

method _find_train_flags() {
    my $pattern = $self->get_user_path('popfile.train*', 0);
    return defined $pattern ? glob($pattern) : ()
}

method _handle_poll_result($result) {
    return
        unless defined $result;
    if ($result->{error}) {
        $self->log_msg(WARN => $result->{error});
        if (($result->{training_done} // 0) == -1) {
            $training_error = $result->{error};
            $training_mode = 0;
        }
    }
    if ($result->{training_done}) {
        unlink @pending_train_flags;
        @pending_train_flags = ();
        @pending_train_buckets = ();
        $training_mode = 0;
    }
    delete $pending_direct_moves{$_}
        for $result->{direct_moved_hashes}->@*;
    delete $pending_folder_moves{$_}
        for $result->{moved_hashes}->@*;
    delete $_uid_next_override{$_}
        for $result->{consumed_uid_overrides}->@*;
    $self->mq()->post('IMAP_DONE', $result->{trained} // 0);
    if ($classifier && $classifier->can('db_update_cache')) {
        $classifier->db_update_cache($self->api_session());
    }
    $poll_running = 0;
    $poll_result_received = 1;
    return 1
}

method _handle_activity_progress($raw) {
    my $activity = $self->activity();
    return
        unless defined $activity && ref $activity;
    return
        unless $raw->{type} && $raw->{type} eq 'activity';
    my %event = $raw->%*;
    delete $event{type};
    if (defined $event{message}) {
        utf8::decode($event{message})
            or $event{message} = Encode::decode('iso-8859-1', $event{message});
    }
    if (defined $event{task}) {
        utf8::decode($event{task})
            or $event{task} = Encode::decode('iso-8859-1', $event{task});
    }
    $activity->add_event(\%event);
}

method _imap_worker_loop($subprocess, $reader) {
    while (1) {
        my $line = <$reader>;
        last
            unless defined $line;
        $line =~ s/\s+$//;
        last
            if $line eq 'quit';
        my $msg;
        try {
            $msg = Cpanel::JSON::XS->new->decode($line);
        }
        catch ($e) {
            $self->log_msg(WARN => "IMAP worker: bad message: $e");
            next();        }
        next
            unless $msg->{cmd} && $msg->{cmd} eq 'poll';
        $training_mode = $msg->{training_mode};
        @pending_train_buckets = $msg->{train_buckets}->@*
            if ref $msg->{train_buckets} eq 'ARRAY';
        %pending_folder_moves = $msg->{pending_folder_moves}->%*
            if ref $msg->{pending_folder_moves} eq 'HASH';
        %pending_direct_moves = $msg->{pending_direct_moves}->%*
            if ref $msg->{pending_direct_moves} eq 'HASH';
        %_uid_next_override = $msg->{uid_next_overrides}->%*
            if ref $msg->{uid_next_overrides} eq 'HASH';
        %hash_to_mid = ();
        $folder_change_flag = $msg->{folder_change_flag} // 0;
        @mailboxes = ()
            if $folder_change_flag;
        my $result = $self->_run_poll_work($subprocess);
        $subprocess->progress(type => 'poll_result', $result->%*);
    }
}

=head2 poll_sync($timeout)

Blocks the caller until the current IMAP poll cycle completes or C<$timeout>
seconds elapse (default 30).  Starts the IOLoop if it is not already running.
Returns 1 if the poll completed, 0 on timeout.

=cut

method poll_sync ($timeout = 30) {
    $poll_result_received = 0;
    $self->poll();
    return 1
        unless defined $imap_worker;
    if (Mojo::IOLoop->is_running()) {
        my $deadline = time() + $timeout;
        while (!$poll_result_received && time() < $deadline) {
            Mojo::IOLoop->one_tick();
        }
        return $poll_result_received ? 1 : 0
    }
    my $deadline = time() + $timeout;
    my $sync_timer = Mojo::IOLoop->recurring(0.1 => sub {
        return
            if !$poll_result_received && time() < $deadline;
        Mojo::IOLoop->stop();
    });
    Mojo::IOLoop->start();
    Mojo::IOLoop->remove($sync_timer)
        if defined $sync_timer;
    return $poll_result_received ? 1 : 0
}

method _run_poll_work($subprocess = undef) {
    my $result = {};
    $result->{trained} = 0;
    $result->{training_done} = 0;
    $result->{error} = undef;
    $result->{moved_hashes} = [];
    $result->{direct_moved_hashes} = [];
    $result->{hash_to_mid} = {};
    $result->{consumed_uid_overrides} = [];
    my $local_id = 0;
    my $emit = sub ($level, $task, $message, $parent_local_id = undef) {
        return
            unless defined $subprocess;
        $local_id++;
        my $ok_task = utf8::decode($task)
            || do { $task = Encode::decode('iso-8859-1', $task); 1 };
        my $ok_msg = utf8::decode($message)
            || do { $message = Encode::decode('iso-8859-1', $message); 1 };
        $subprocess->progress(
            type => 'activity',
            level => $level,
            module => 'imap',
            task => $task,
            message => $message,
            local_id => $local_id,
            defined $parent_local_id ? (parent_local_id => $parent_local_id) : ());
        return $local_id
    };
    my $dbh;
    try {
        $dbh = POPFile::Database->instance()->get_handle();
    }
    catch ($e) {
        $self->log_msg(WARN => "Could not open uid state DB: $e");
    }
    try {
        local $SIG{PIPE} = 'IGNORE';
        local $SIG{__DIE__};
        if ($self->training_mode) {
            $result->{trained} = $self->train_on_archive();
            $result->{training_done} = 1;
        }
        else {
            my ($nexts, $validities) = defined $dbh
                ? $self->_load_uid_state($dbh)
                : ({}, {});
            $result->{consumed_uid_overrides} = [keys %_uid_next_override];
            if ($dbh) {
                try {
                    my $rows = $dbh->selectall_arrayref(
                        'SELECT hash, mid FROM history WHERE mid IS NOT NULL',
                        { Slice => {} });
                    $hash_to_mid{$_->{hash}} = $_->{mid} for $rows->@*;
                }
                catch ($e) {
                    $self->log_msg(DEBUG => "history preload skipped: $e");
                }
            }
            if (!%folders || $folder_change_flag == 1) {
                $self->build_folder_list();
            }
            my $connect_local_id;
            if ($subprocess) {
                my $count = scalar keys %folders;
                $connect_local_id = $emit->('info', 'IMAP Connect', "Connecting to $count folder(s)...");
            }
            $self->connect_server(nexts => $nexts, validities => $validities);
            if ($subprocess && defined $connect_local_id) {
                my $count = scalar grep { exists $folders{$_}{imap} } keys %folders;
                $emit->('info', 'IMAP Connect', "Connected $count folder(s)", $connect_local_id);
            }
            %hash_values = ();
            $self->_drain_direct_moves($result);
            my %pending_before = %pending_folder_moves;
            my $poll_local_id;
            if ($subprocess) {
                my @f = sort grep { exists $folders{$_}{imap} } keys %folders;
                $poll_local_id = $emit->('info', 'IMAP Poll', 'Checking ' . join(', ', @f));
            }
            my $changes = 0;
            for my $folder (keys %folders) {
                next()
                    unless exists $folders{$folder}{imap};
                $changes += $self->scan_folder($folder, $emit, $poll_local_id) // 0;
            }
            if ($subprocess && defined $poll_local_id) {
                $emit->('info', 'IMAP Poll', $changes ? "$changes message(s) processed" : 'No changes', $poll_local_id);
            }
            $result->{moved_hashes} = [grep { !exists $pending_folder_moves{$_} } keys %pending_before];
            my ($any_imap) =
                map { $_->{imap} }
                grep { defined $_->{imap} }
                values %folders;
            $self->_save_uid_state($dbh, $any_imap)
                if defined $dbh && defined $any_imap;
        }
    }
    catch ($err) {
        for my $folder (keys %folders) {
            delete $folders{$folder}{imap}
                if exists $folders{$folder}{imap}
                && !$folders{$folder}{imap}->connected();
        }
        my $msg = $err =~ /^POPFILE-IMAP-EXCEPTION: (.+\)\))/s
            ? $1
            : "Unexpected IMAP error: $err";
        $result->{error} = $msg;
        $emit->('error', 'IMAP Error', $msg)
            if defined $subprocess;
        if ($self->training_mode) {
            $result->{training_done} = -1;
        }
    }
    return $result
}

=head2 api_session()

Returns (and lazily acquires) the admin Bayes session key used for all
classifier calls.

=cut

method api_session() {
    $api_session = $classifier->get_session_key('admin', '') unless $api_session;
    return $api_session
}

=head2 _ensure_folder_tables()

Creates the C<imap_watched_folders> and C<imap_folder_mappings> tables
if they do not exist yet.

=cut

method _ensure_folder_tables() {
    my $dbh = POPFile::Database->instance()->get_handle();
    $dbh->do('CREATE TABLE IF NOT EXISTS imap_folder_state (
        id integer primary key,
        folder varchar(255) unique not null,
        uid_next integer,
        uid_validity integer)');
    $dbh->do('CREATE TABLE IF NOT EXISTS imap_watched_folders (
        id integer primary key,
        userid integer not null,
        folder_name varchar(255) not null,
        unique(userid, folder_name))');
    $dbh->do('CREATE TABLE IF NOT EXISTS imap_folder_mappings (
        id integer primary key,
        userid integer not null,
        bucket_name varchar(255) not null,
        folder_name varchar(255) not null,
        unique(userid, bucket_name))');
}

=head2 _migrate_folder_config()

Migrates legacy C<watched_folders> config strings to the new
database table.  Idempotent: does nothing if the DB table already
contains data or the config key is not present.

=cut

method _migrate_folder_config() {
    my $dbh = POPFile::Database->instance()->get_handle();
    my $userid = 1;
    my $existing = $dbh->selectrow_array(
        'SELECT count(*) FROM imap_watched_folders WHERE userid = ?',
        undef, $userid);
    return
        if $existing;
    my $sep = '-->';
    my $watched_raw = $self->config->get('watched_folders');
    if ($watched_raw) {
        my @folders = grep { $_ ne '' } split /$sep/, $watched_raw;
        if (@folders) {
            my $sth = $dbh->prepare(
                'INSERT INTO imap_watched_folders (userid, folder_name) VALUES (?, ?)');
            $sth->execute($userid, $_)
                for @folders;
        }
    }
    my $still_empty = $dbh->selectrow_array(
        'SELECT count(*) FROM imap_watched_folders WHERE userid = ?',
        undef, $userid);
    $dbh->do(
        'INSERT INTO imap_watched_folders (userid, folder_name) VALUES (?, ?)',
        undef, $userid, 'INBOX')
        unless $still_empty;
}

=head2 _load_uid_state($dbh)

Reads all rows from C<imap_folder_state> and returns two hash-refs:
C<\%uid_nexts> and C<\%uid_validities>, keyed by folder name.

=cut

method _load_uid_state($dbh) {
    my (%nexts, %validities);
    my $rows = $dbh->selectall_arrayref(
        'SELECT folder, uid_next, uid_validity FROM imap_folder_state',
        { Slice => {} });
    for my $row ($rows->@*) {
        $nexts{$row->{folder}} = $row->{uid_next}
            if defined $row->{uid_next};
        $validities{$row->{folder}} = $row->{uid_validity}
            if defined $row->{uid_validity};
    }
    for my $folder (keys %_uid_next_override) {
        $nexts{$folder} = $_uid_next_override{$folder};
    }
    return \%nexts, \%validities
}

=head2 _save_uid_state($dbh, $imap)

Reads uid_next and uid_validity from C<$imap> (a L<Services::IMAP::Client>)
and upserts them into C<imap_folder_state>.

=cut

method _save_uid_state($dbh, $imap) {
    my $nexts = $imap->uid_nexts();
    my $validities = $imap->uid_validities();
    for my $folder (keys %$nexts) {
        $dbh->do(
            'INSERT OR REPLACE INTO imap_folder_state (folder, uid_next, uid_validity) VALUES (?,?,?)',
            undef, $folder, $nexts->{$folder}, $validities->{$folder});
    }
    %_uid_next_override = ();
}

=head2 _drain_direct_moves($result)

For each entry in C<%pending_direct_moves> (queued by C<request_folder_move>
when the C<Message-Id> is cached), searches all connected IMAP folders via
C<UID SEARCH HEADER Message-ID> and moves the message to its destination
folder.  Successfully moved hashes are appended to
C<$result-E<gt>{direct_moved_hashes}>.  Messages that cannot be found in any
connected folder are left in C<%pending_direct_moves> for the next poll.

=cut

method _drain_direct_moves ($result) {
    return
        unless %pending_direct_moves;
    for my $hash (keys %pending_direct_moves) {
        my $entry = $pending_direct_moves{$hash};
        my $destination = $self->folder_for_bucket($entry->{target_bucket});
        next()
            unless defined $destination;
        for my $folder (keys %folders) {
            next()
                unless exists $folders{$folder}{imap};
            my $imap = $folders{$folder}{imap};
            my @uids = $imap->search_header_in_folder($folder, 'Message-ID', $entry->{mid});
            next()
                unless @uids;
            if ($destination ne $folder) {
                $self->log_msg(WARN => "Direct move: UID $uids[0] from $folder to $destination.");
                $imap->move_message($uids[0], $destination);
                $imap->expunge() if $self->config->get('expunge');
            }
            push $result->{direct_moved_hashes}->@*, $hash;
            last();
        }
    }
}

=head2 _reset_uid_next($folder)

Registers an override that forces the next poll to scan C<$folder> from the
beginning (uid_next = 1).  Used when a UI reclassification request arrives
for a message that may be below the current C<uid_next> watermark.

=cut

method _reset_uid_next($folder) {
    $self->log_msg(INFO => "Scheduling uid_next reset for folder $folder to force re-scan.");
    $_uid_next_override{$folder} = 1;
}

=head2 new_imap_client()

Creates, configures, and connects a new L<Services::IMAP::Client> instance,
pre-seeding it with uid state loaded from the database.  Returns the
connected client on success, or C<undef> and sets C<$imap_error> on failure.

=cut

method new_imap_client(%args) {
    my $client = Services::IMAP::Client->new();
    $client->set_mq($self->mq());
    $client->set_name($self->name());
    if (defined $args{nexts}) {
        $client->load_uid_state(nexts => $args{nexts}, validities => $args{validities});
    }
    if ($client->connect()) {
        if ($client->login()) {
            return $client
        }
        $self->log_msg(WARN => "Could not LOGIN.");
        $imap_error = 'NO_LOGIN';
    }
    else {
        $self->log_msg(WARN => "Could not CONNECT to server.");
        $imap_error = 'NO_CONNECT';
    }
    return
}

=head2 build_folder_list()

Rebuilds the C<%folders> map from watched folders and bucket-to-folder
mappings.  Resets C<$folder_change_flag>.

=cut

method build_folder_list() {
    $self->log_msg(DEBUG => "Building list of serviced folders.");
    %folders = ();
    for my $folder ($self->watched_folders()) {
        $folders{$folder}{watched} = 1;
        $folders{$folder}{_folder} = Services::IMAP::Folder->new(
            name => $folder, watched => 1);
    }
    for my $bucket ($classifier->get_all_buckets($self->api_session())) {
        my $folder = $self->folder_for_bucket($bucket);
        if ($folder) {
            $folders{$folder}{output} = $bucket;
            $folders{$folder}{_folder} //= Services::IMAP::Folder->new(name => $folder);
            $folders{$folder}{_folder}->set_output_bucket($bucket);
        }
    }
    $folder_change_flag = 0;
}

=head2 connect_server(%uid_state)

Opens IMAP connections for all folders in C<%folders> that do not yet have
one.  For each folder it verifies (or creates) the folder on the server,
retrieves C<UIDVALIDITY> and C<UIDNEXT>, and persists those values via the
client.  C<%uid_state> may contain C<nexts> and C<validities> hash-refs for
pre-loading uid state into the client.  Dies with a C<POPFILE-IMAP-EXCEPTION>
if a connection cannot be established.

=cut

method connect_server(%uid_state) {
    my $imap;
    for my $folder (keys %folders) {
        next()
            if exists $folders{$folder}{imap}
            && $folders{$folder}{imap}->connected();
        next()
            if exists $folders{$folder}{output}
            && !exists $folders{$folder}{watched}
            && $classifier->is_pseudo_bucket($self->api_session(), $folders{$folder}{output});
        unless ($imap) {
            $imap = $self->_find_alive_client();
            unless ($imap) {
                $imap = $self->new_imap_client(%uid_state)
                    or die sprintf(
                        'POPFILE-IMAP-EXCEPTION: Could not connect: %s (%s (%d)))',
                        $imap_error, __FILE__, __LINE__);
            }
        }
        @mailboxes = $imap->get_mailbox_list() unless @mailboxes;
        my $info = $imap->status($folder);
        my $uidnext = $info->{UIDNEXT};
        my $uidvalidity = $info->{UIDVALIDITY};
        unless (defined $uidvalidity && defined $uidnext) {
            $self->log_msg(INFO => "Folder $folder does not exist, creating it.");
            $imap->create_folder($folder);
            my $info2 = $imap->status($folder);
            $uidnext = $info2->{UIDNEXT};
            $uidvalidity = $info2->{UIDVALIDITY};
            unless (defined $uidvalidity && defined $uidnext) {
                $self->log_msg(WARN => "Could not create or STATUS folder $folder, skipping.");
                delete $folders{$folder};
                next();            }
        }
        $folders{$folder}{imap} = $imap;
        if ($imap->uid_validity($folder)) {
            if ($imap->check_uid_validity($folder, $uidvalidity)) {
                unless ($imap->uid_next($folder)) {
                    $self->log_msg(WARN => "Detected invalid UIDNEXT configuration value for folder $folder. Some new messages might have been skipped.");
                    $imap->uid_next($folder, $uidnext);
                }
            }
            else {
                $self->log_msg(WARN => "Changed UIDVALIDITY for folder $folder. Some new messages might have been skipped.");
                $imap->uid_validity($folder, $uidvalidity);
                $imap->uid_next($folder, $uidnext);
            }
        }
        else {
            $self->log_msg(WARN => "First connect to folder $folder — starting from UID 1.");
            $imap->uid_validity($folder, $uidvalidity);
            $imap->uid_next($folder, 1);
        }
    }
}

=head2 disconnect_folders()

Logs out of every open IMAP connection and clears C<%folders>.

=cut

method _find_alive_client() {
    for my $folder (keys %folders) {
        return $folders{$folder}{imap}
            if exists $folders{$folder}{imap}
            && $folders{$folder}{imap}->connected();
    }
    return
}

=head2 disconnect_folders()

Logs out of every open IMAP connection and clears C<%folders>.

=cut

method disconnect_folders() {
    $self->log_msg(INFO => "Trying to disconnect all connections.");
    for my $folder (keys %folders) {
        my $imap = $folders{$folder}{imap};
        if ($imap && $imap->connected()) {
            try { $imap->logout() } catch ($e) {}
        }
    }
    %folders = ();
}

=head2 request_folder_move($hash, $target_bucket, $source_bucket)

Queues a folder move for the message identified by C<$hash>.  If the
C<Message-ID> for the hash is already cached in C<%hash_to_mid> (either from
the current session or loaded from C<history.mid> at poll startup), a direct
IMAP move is queued via C<%pending_direct_moves>.  Otherwise the hash is added
to C<%pending_folder_moves> as a passive fallback (no C<uid_next> reset —
messages with no cached C<Message-ID> are pre-v5 data with no automatic
IMAP move guarantee).

=cut

method request_folder_move ($hash, $target_bucket, $source_bucket = undef) {
    if (exists $hash_to_mid{$hash}) {
        $self->log_msg(INFO => "Direct move queued for hash $hash to $target_bucket.");
        $pending_direct_moves{$hash} = { mid => $hash_to_mid{$hash}, target_bucket => $target_bucket };
        return
    }
    $self->log_msg(INFO => "No Message-ID cached for hash $hash; queuing folder move with uid_next reset.");
    $pending_folder_moves{$hash} = $target_bucket;
    my $source_folder = defined $source_bucket
        ? $self->folder_for_bucket($source_bucket)
        : undef;
    $self->_reset_uid_next($source_folder)
        if $source_folder;
}

=head2 cache_message_id($hash, $mid)

Caches a Message-ID for C<$hash> in the in-memory C<%hash_to_mid> map so that
a subsequent C<request_folder_move> for the same hash takes the direct-move
path instead of the uid_next-reset fallback.  Called by the API controller
when a reclassification request is received and the local message file
contains a C<Message-ID> header.

=cut

method cache_message_id ($hash, $mid) {
    $self->log_msg(INFO => "Message-ID cached for hash $hash.");
    $hash_to_mid{$hash} = $mid
}

=head2 request_folder_rescan($folder)

Schedules a full rescan of C<$folder> on the next poll cycle by resetting
its C<uid_next> watermark to 1.  All messages in the folder will be
classified (or reclassified) on the next poll.  Returns the folder name, or
C<undef> if C<$folder> is empty.

=cut

method request_folder_rescan ($folder) {
    return
        unless $folder;
    $self->_reset_uid_next($folder);
    return $folder
}

=head2 scan_folder($folder)

Scans one IMAP folder for new messages (UIDs ≥ stored C<UIDNEXT>).  For each
new message: deduplicates by hash, classifies watched-folder messages with
C<classify_message()>, and reclassifies output-folder messages with
C<reclassify_message()>.  Calls C<EXPUNGE> afterwards if any messages were
moved and C<expunge> is configured.

=cut

method scan_folder ($folder, $emit_parent = undef, $parent_local_id = undef) {
    my $local_seq = 0;
    my $emit = defined $emit_parent
        ? sub ($level, $task, $msg, $override_parent = undef) {
            $local_seq++;
            return $emit_parent->($level, $task, $msg, $override_parent // $parent_local_id);
        }
        : sub {};
    my $in_subprocess = defined $emit_parent;
    my $emit_batch = $in_subprocess
        ? sub {}
        : $emit;
    my $is_watched = exists $folders{$folder}{watched} ? 1 : 0;
    my $is_output = exists $folders{$folder}{output}  ? $folders{$folder}{output} : '';
    $self->log_msg(DEBUG => "Looking for new messages in folder $folder.");
    $emit->('info', 'Scan', $folder);
    my $imap = $folders{$folder}{imap};
    $imap->noop();
    my $moved_message = 0;
    my $reclassified = 0;
    my $trained = 0;
    my @uids = $imap->get_new_message_list_unselected($folder);
    for my $msg (@uids) {
        $self->log_msg(INFO => "Found new message in folder $folder (UID: $msg)");
        my ($hash, $mid, $subject) = $self->get_hash($folder, $msg);
        my $subject_str = $subject ? " ($subject)" : '';
        my $found_id = $emit_batch->('info', 'Found', "UID $msg in $folder$subject_str");
        $hash_to_mid{$hash} = $mid if $hash && $mid;
        $imap->uid_next($folder, $msg + 1);
        unless ($hash) {
            $self->log_msg(WARN => "Skipping message $msg.");
            $emit_batch->('warn', 'Skipped', "UID $msg — could not hash");
            next();
        }
        if (exists $pending_folder_moves{$hash}) {
            my $target_bucket = delete $pending_folder_moves{$hash};
            my $destination = $self->folder_for_bucket($target_bucket);
            if ($destination && $destination ne $folder) {
                $self->log_msg(WARN => "UI reclassification: moving message $msg to $destination.");
                $imap->move_message($msg, $destination);
                $moved_message++;
                $emit_batch->('info', 'Reclassified', "UID $msg → $destination (UI)");
            }
            next();        }
        if (exists $hash_values{$hash}) {
            my $destination = $hash_values{$hash};
            if ($destination ne $folder) {
                $self->log_msg(WARN => "Found duplicate hash value: $hash. Moving the message to $destination.");
                $imap->move_message($msg, $destination);
                $moved_message++;
            }
            else {
                $self->log_msg(WARN => "Found duplicate hash value: $hash. Ignoring duplicate in folder $folder.");
            }
            next();        }
        if ($is_watched && $self->can_classify($hash)) {
            my $result = $self->classify_message($msg, $hash, $folder, $mid);
            unless (defined $result) {
                $self->log_msg(WARN => "classify_message failed for UID $msg in $folder — message left in place.");
                $emit_batch->('error', 'Classify failed', "UID $msg in $folder");
                next();            }
            $moved_message++ if $result ne '';
            $hash_values{$hash} = $result ne '' ? $result : $folder;
            $emit_batch->('info', 'Classified', "UID $msg → " . ($result || $folder));
            next();        }
        if ($is_watched && ref $history && $history->can('get_slot_from_hash')) {
            my $slot = $history->get_slot_from_hash($hash);
            if ($slot ne '') {
                my $old_bucket = REAPPEARED_UNKNOWN_BUCKET;
                if ($history->can('get_history_item')) {
                    my $info = $history->get_history_item($slot);
                    $old_bucket = $info->{bucket} // REAPPEARED_UNKNOWN_BUCKET;
                }
                if ($history->can('touch_slot')) {
                    $history->touch_slot($slot);
                }
                my $destination = $self->folder_for_bucket($old_bucket);
                if ($destination && $destination ne $folder) {
                    $imap->move_message($msg, $destination);
                    $moved_message++;
                    $emit_batch->('info', 'Reappeared', "UID $msg → $destination$subject_str", $found_id);
                }
                else {
                    $emit_batch->('info', 'Reappeared', "UID $msg was previously $old_bucket$subject_str", $found_id);
                }
            }
            next();        }
        if (my $bucket = $is_output) {
            if (my $old_bucket = $self->can_reclassify($hash, $bucket)) {
                $self->reclassify_message($folder, $msg, $old_bucket, $hash);
                $reclassified++;
                $emit_batch->('info', 'Reclassified', "UID $msg: $old_bucket → $bucket");
            }
            elsif ($self->training_mode
                && (!ref $history || $history->get_slot_from_hash($hash) eq '')) {
                $self->insert_message_into_bucket($folder, $msg, $bucket);
                $trained++;
                $emit_batch->('info', 'Trained', "UID $msg → $bucket");
            }
            else {
                $self->log_msg(INFO => "Skipping message $msg in output folder $folder (not in history, training mode off).");
                $emit_batch->('info', 'Skipped', "UID $msg — output folder, not in history, training off");
            }
            next();        }
        $self->log_msg(DEBUG => "Ignoring message $msg");
    }
    $imap->expunge()
        if $moved_message && $self->config->get('expunge');
    my @summary_parts;
    push @summary_parts, "$moved_message moved"
        if $moved_message;
    push @summary_parts, "$reclassified reclassified"
        if $reclassified;
    push @summary_parts, "$trained trained"
        if $trained;
    my $summary = @summary_parts
        ? join(', ', @summary_parts)
        : scalar(@uids) . ' checked, no action';
    $emit->('info', 'Scan done', "$folder: $summary");
    return $moved_message
}

=head2 classify_message($msg, $hash, $folder, $mid)

Fetches the header and (if needed) body of IMAP message C<$msg>, runs the
classifier, and moves the message to the appropriate output folder.  If
C<$mid> (the C<Message-ID> header value) is provided, it is stored in the
history record so that future reclassification requests can use direct IMAP
moves instead of folder rescans.  Returns the destination folder name on
success (empty string if not moved), or C<undef> on error.

=cut

method classify_message ($msg, $hash, $folder, $mid = undef) {
    my $file = $self->get_user_path('imap.tmp');
    my $pseudo_mailer;
    unless (sysopen($pseudo_mailer, $file, Fcntl::O_RDWR() | Fcntl::O_CREAT() | Fcntl::O_TRUNC())) {
        $self->log_msg(WARN => "Unable to open temporary file $file. Nothing done to message $msg. ($!)");
        return
    }
    binmode $pseudo_mailer;
    my $imap = $folders{$folder}{imap};
    my $moved_a_msg = '';
    PART: for my $part (qw/ HEADER TEXT /) {
        my ($ok, @lines) = $imap->fetch_message_part($msg, $part);
        unless ($ok) {
            $self->log_msg(WARN => "Could not fetch the $part part of message $msg.");
            return
        }
        syswrite $pseudo_mailer, $_ for @lines;
        my ($class, $slot, $magnet_used);
        if ($part eq 'HEADER') {
            sysseek $pseudo_mailer, 0, 0;
            ($class, $slot, $magnet_used) = $classifier->classify_and_modify(
                $self->api_session(), $pseudo_mailer, undef, 1, '', undef, 0, undef);
            if ($magnet_used) {
                $self->log_msg(WARN => "Message with slot $slot was classified as $class using a magnet.");
                syswrite $pseudo_mailer, "\nThis message was classified based on a magnet.\nThe body of the message was not retrieved from the server.\n";
            }
            else {
                next PART;
            }
        }
        sysseek $pseudo_mailer, 0, 0;
        ($class, $slot, $magnet_used) = $classifier->classify_and_modify(
            $self->api_session(), $pseudo_mailer, undef, 0, '', undef, 0, undef);
        $self->_flush_history();
        $history->set_message_id($slot, $mid)
            if $mid && $slot;
        close $pseudo_mailer;
        unlink $file;
        if ($magnet_used || $part eq 'TEXT') {
            my $destination = $self->folder_for_bucket($class);
            if ($destination) {
                if ($folder ne $destination) {
                    $imap->move_message($msg, $destination);
                    $moved_a_msg = $destination;
                }
            }
            else {
                $self->log_msg(WARN => "Message cannot be moved because output folder for bucket $class is not defined.");
            }
            $self->log_msg(WARN => "Message was classified as $class.");
            last PART;
        }
    }
    return $moved_a_msg
}

=head2 insert_message_into_bucket($folder, $msg, $bucket)

Fetches the full message C<$msg> from C<$folder> and trains the classifier
directly into C<$bucket>.  Used when a message has no history entry (e.g. the
user moved it into an output folder via their mail client).  Returns 1 on
success, C<undef> on error.

=cut

method insert_message_into_bucket ($folder, $msg, $bucket) {
    my $imap = $folders{$folder}{imap};
    my ($ok, @lines) = $imap->fetch_message_part($msg, '');
    unless ($ok) {
        $self->log_msg(WARN => "Could not fetch message $msg!");
        return
    }
    my $file = $self->get_user_path('imap.tmp');
    unless (open my $TMP, '>', $file) {
        $self->log_msg(WARN => "Cannot open temp file $file");
        return
    }
    else {
        print $TMP $_ for @lines;
        close $TMP;
    }
    $classifier->add_message_to_bucket($self->api_session(), $bucket, $file);
    $self->log_msg(WARN => "Trained message with UID $msg into bucket $bucket.");
    unlink $file;
    return 1
}

method _flush_history() {
    if (ref $self->mq()) {
        $self->mq()->service();
    }
    else {
        $self->log_msg(WARN => '_flush_history: mq is not an object, skipping service()');
    }
    $history->commit_history() if ref $history;
}

=head2 reclassify_message($folder, $msg, $old_bucket, $hash)

Fetches the full message C<$msg> from C<$folder>, trains the classifier from
C<$old_bucket> to the output bucket associated with C<$folder>, and updates
the history record.  Returns 1 on success, C<undef> on error.

=cut

method reclassify_message ($folder, $msg, $old_bucket, $hash) {
    my $new_bucket = $folders{$folder}{output};
    my $imap = $folders{$folder}{imap};
    my ($ok, @lines) = $imap->fetch_message_part($msg, '');
    unless ($ok) {
        $self->log_msg(WARN => "Could not fetch message $msg!");
        return
    }
    my $file = $self->get_user_path('imap.tmp');
    unless (open my $TMP, '>', $file) {
        $self->log_msg(WARN => "Cannot open temp file $file");
        return
    }
    else {
        print $TMP $_ for @lines;
        close $TMP;
    }
    my $slot = $history->get_slot_from_hash($hash);
    $classifier->add_message_to_bucket($self->api_session(), $new_bucket, $file);
    $classifier->reclassified($self->api_session(), $old_bucket, $new_bucket, 0);
    $history->change_slot_classification($slot, $new_bucket, $self->api_session(), 0);
    $self->log_msg(WARN => "Reclassified the message with UID $msg from bucket $old_bucket to bucket $new_bucket.");
    unlink $file;
    return 1
}

=head2 get_hash($folder, $msg)

Fetches selected header fields (C<Message-Id>, C<Date>, C<Subject>,
C<Received>) for C<$msg> and returns C<($hash, $mid)> — the history hash
computed by C<< POPFile::History->get_message_hash() >> and the raw
C<Message-Id> header value.  Returns an empty list on failure.

=cut

method get_hash ($folder, $msg) {
    my $imap = $folders{$folder}{imap};
    my ($ok, @lines) = $imap->fetch_message_part(
        $msg, "HEADER.FIELDS (Message-id Date Subject Received)");
    unless ($ok) {
        $self->log_msg(WARN => "Could not FETCH the header fields of message $msg!");
        return
    }
    my (%header, $last);
    for (@lines) {
        s/[\r\n]//g;
        last()
            if /^$/;
        if (/^([^ \t]+):[ \t]*(.*)$/) {
            $last = lc $1;
            push $header{$last}->@*, $2;
        } elsif ($last) {
            $header{$last}[-1] .= $_;
        }
    }
    my $mid = $header{'message-id'}[0];
    my $date = $header{'date'}[0];
    my $subject = $header{'subject'}[0];
    my $received = $header{'received'}[0];
    my $hash = $history->get_message_hash($mid, $date, $subject, $received);
    $self->log_msg(DEBUG => sprintf('Hashed message: %s.', $subject // 'undef'));
    $self->log_msg(DEBUG => "Message $msg has hash value $hash");
    return ($hash, $mid, $subject)
}

=head2 can_classify($hash)

Returns 1 if the message identified by C<$hash> has not yet been seen in
history (i.e. it is safe to classify it fresh), C<undef> otherwise.

=cut

method can_classify ($hash) {
    my $slot = $history->get_slot_from_hash($hash);
    if ($slot ne '') {
        $self->log_msg(DEBUG => "Message was already classified (slot $slot).");
        return
    }
    $self->log_msg(DEBUG => "The message is not yet in history.");
    return 1
}

=head2 can_reclassify($hash, $new_bucket)

Checks whether the message identified by C<$hash> is eligible for
reclassification into C<$new_bucket>.  Returns the current bucket name if
reclassification is allowed, C<undef> if the message is unknown, already
reclassified, magnetized, already in C<$new_bucket>, or C<$new_bucket> is a
pseudo-bucket.

=cut

method can_reclassify ($hash, $new_bucket) {
    my $slot = $history->get_slot_from_hash($hash);
    unless ($slot ne '') {
        $self->log_msg(DEBUG => "Message not in history; will train directly.");
        return
    }
    my ($id, $from, $to, $cc, $subject, $date, undef, $inserted,
        $bucket, $reclassified, undef, $magnetized) = $history->get_slot_fields($slot);
    $self->log_msg(DEBUG => "get_slot_fields: slot=$slot bucket=$bucket reclassified=$reclassified magnetized=$magnetized");
    if ($magnetized) {
        $self->log_msg(DEBUG => "The message was classified using a magnet and cannot be reclassified.");
        return
    }
    if ($reclassified) {
        $self->log_msg(DEBUG => "The message was already reclassified.");
        return
    }
    if ($new_bucket eq $bucket) {
        $self->log_msg(DEBUG => "Will not reclassify to same bucket ($new_bucket).");
        return
    }
    if ($classifier->is_pseudo_bucket($self->api_session(), $new_bucket)) {
        $self->log_msg(DEBUG => "Will not reclassify to pseudo-bucket ($new_bucket)");
        return
    }
    return $bucket
}

=head2 folder_for_bucket($bucket, $folder)

Get/set the IMAP folder mapped to C<$bucket>.  With only C<$bucket>, returns
the mapped folder name or C<undef>.  With both arguments, stores the new
mapping in the C<imap_folder_mappings> database table.

=cut

method folder_for_bucket ($bucket, $folder = undef) {
    my $dbh = POPFile::Database->instance()->get_handle();
    my $userid = 1;
    if ($folder) {
        $dbh->do(
            'INSERT INTO imap_folder_mappings (userid, bucket_name, folder_name)
             VALUES (?, ?, ?)
             ON CONFLICT(userid, bucket_name) DO UPDATE SET folder_name = excluded.folder_name',
            undef, $userid, $bucket, $folder);
        return
    }
    my ($result) = $dbh->selectrow_array(
        'SELECT folder_name FROM imap_folder_mappings WHERE userid = ? AND bucket_name = ?',
        undef, $userid, $bucket);
    return $result
}

=head2 watched_folders(@new_folders)

Get/set the list of watched IMAP folders.  With no arguments, returns the
current list.  With a list of folder names, replaces the stored list in
the C<imap_watched_folders> database table.

=cut

method watched_folders (@new_folders) {
    my $dbh = POPFile::Database->instance()->get_handle();
    my $userid = 1;
    if (@new_folders) {
        $dbh->do('DELETE FROM imap_watched_folders WHERE userid = ?', undef, $userid);
        my $sth = $dbh->prepare(
            'INSERT INTO imap_watched_folders (userid, folder_name) VALUES (?, ?)');
        $sth->execute($userid, $_) for @new_folders;
        return
    }
    my $rows = $dbh->selectcol_arrayref(
        'SELECT folder_name FROM imap_watched_folders WHERE userid = ? ORDER BY id',
        undef, $userid);
    return $rows ? $rows->@* : ()
}

=head2 folder_mappings()

Returns a hash mapping bucket names to IMAP folder names.

=cut

method folder_mappings() {
    my $dbh = POPFile::Database->instance()->get_handle();
    my $rows = $dbh->selectall_arrayref(
        'SELECT bucket_name, folder_name FROM imap_folder_mappings WHERE userid = 1',
        { Slice => {} }) // [];
    return map { $_->{bucket_name} => $_->{folder_name} } $rows->@*
}

=head2 train_on_archive()

Bulk-trains the classifier from all output folders (skipping C<INBOX> and
pseudo-buckets).  Iterates every message in each output folder and calls
C<< Classifier::Bayes->add_message_to_bucket() >> for new messages (UIDs >=
stored uid_next).  Returns the number of trained messages.  C<training_mode>
is cleared by the parent callback in C<poll()>.

=cut

method train_on_archive() {
    $training_error = '';
    $self->log_msg(WARN => "Training on existing archive.");
    %folders = ();
    $self->build_folder_list();
    for my $folder (keys %folders) {
        delete $folders{$folder} if exists $folders{$folder}{watched};
    }
    unless (%folders) {
        $self->log_msg(WARN => "No output folders configured; nothing to train on.");
        %folders = ();
        return 0
    }
    $self->connect_server();
    my $limit = $self->config->get('training_limit') || 0;
    my $batch_size = $limit > 0 ? $limit : 50;
    my $total_msgs = 0;
    my $total_folders = 0;
    my %only = map { $_ => 1 } @pending_train_buckets;
    for my $folder (keys %folders) {
        my $bucket = $folders{$folder}{output};
        next()
            if %only && !$only{$bucket};
        next()
            if $classifier->is_pseudo_bucket($self->api_session(), $bucket);
        next()
            if $folder eq 'INBOX';
        my $imap = $folders{$folder}{imap};
        $imap->uid_next($folder, 1);
        my @uids = $imap->get_new_message_list_unselected($folder);
        @uids = @uids[0 .. $limit - 1] if $limit > 0 && @uids > $limit;
        $self->log_msg(WARN => sprintf(
            'Training on %d messages in folder %s to bucket %s%s.',
            scalar(@uids), $folder, $bucket,
            $limit > 0 ? " (limit: $limit)" : ''));
        $total_folders++;
        while (@uids) {
            my @batch = splice @uids, 0, $batch_size;
            my @texts;
            for my $msg (@batch) {
                my ($ok, @lines) = $imap->fetch_message_part($msg, '');
                $imap->uid_next($folder, $msg + 1);
                unless ($ok) {
                    $self->log_msg(WARN => "Could not fetch message $msg!");
                    next();                }
                push @texts, join('', @lines);
            }
            next()
                unless @texts;
            $self->log_msg(WARN => "Training batch of " . scalar(@texts) . " messages in folder $folder to bucket $bucket.");
            $classifier->train_messages_batch($self->api_session(), $bucket, \@texts);
            $total_msgs += scalar @texts;
        }
    }
    $self->log_msg(WARN => "Training complete: $total_msgs messages trained across $total_folders folders.");
    %folders = ();
    return $total_msgs
}

1;
