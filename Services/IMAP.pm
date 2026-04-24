# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use Fcntl ();
use feature 'try';
no warnings 'experimental::try';
use Mojo::IOLoop;
use Services::IMAP::Client;

class Services::IMAP :isa(POPFile::Module);

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

field $classifier :writer(set_classifier) = 0;
field $history :writer(set_history) = 0;
field %folders;
field @mailboxes;
field $folder_change_flag = 0;
field %hash_values;
field %pending_folder_moves;
field $api_session = '';
field $imap_error = '';
field $last_update = 0;
field $timer_id = undef;
field $poll_running = 0;
field $poll_started_at = 0;
field @pending_train_flags;
field @pending_train_buckets;
field %_uid_next_override;

my $cfg_separator = "-->";

BUILD {
    $self->set_name('imap');
}

=head2 initialize()

Registers all IMAP configuration parameters with their defaults: C<hostname>,
C<port> (143), C<login>, C<password>, C<update_interval> (20 s), C<expunge>,
C<use_ssl>, C<watched_folders>, C<bucket_folder_mappings>,
C<enabled> (0), C<training_mode> (0).  Returns 1.

=cut

method initialize() {
    $self->config('hostname', '');
    $self->config('port', 143);
    $self->config('login', '');
    $self->config('password', '');
    $self->config('update_interval', 20);
    $self->config('expunge', 0);
    $self->config('use_ssl', 0);
    $self->config('watched_folders', 'INBOX');
    $self->config('bucket_folder_mappings', '');
    $self->config('enabled', 0);
    $self->config('training_mode', 0);
    $self->config('training_error', '');
    $self->config('training_limit', 0);
    $last_update = time - $self->config('update_interval');
    return 1
}

=head2 start()

Registers a recurring C<Mojo::IOLoop> timer that calls C<poll()> every
C<update_interval> seconds.  Returns 1.

=cut

method start() {
    my $interval = $self->config('update_interval');
    $timer_id = Mojo::IOLoop->recurring($interval => sub { $self->poll() });
    return 1
}

=head2 stop()

Removes the recurring IOLoop timer and disconnects all open IMAP connections
via C<disconnect_folders()>.

=cut

method stop() {
    Mojo::IOLoop->remove($timer_id) if defined $timer_id;
    $timer_id = undef;
    $self->disconnect_folders();
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

method _find_train_flags() {
    my $pattern = $self->get_user_path('popfile.train*', 0);
    return defined $pattern ? glob($pattern) : ()
}

method _now()      { time() }
method _poll_age() { $self->_now() - $poll_started_at }

method poll() {
    my @flags = $self->_find_train_flags();
    if (@flags && !$poll_running) {
        @pending_train_flags = @flags;
        @pending_train_buckets = ();
        for my $flag (@flags) {
            push @pending_train_buckets, $1
                if $flag =~ /popfile\.train\.(.+)$/;
        }
        $self->config('training_mode', 1);
    }
    return if $self->config('enabled') == 0
           && $self->config('training_mode') == 0;
    if ($poll_running) {
        my $age = $self->_poll_age();
        my $limit = $self->config('update_interval') * 3;
        if ($age > $limit) {
            $self->log_msg(0, "IMAP poll watchdog: subprocess hung for ${age}s, resetting.");
            $poll_running = 0;
        }
        else {
            $self->log_msg(1, "IMAP poll skipped: previous poll still running (${age}s).");
            return;
        }
    }
    $poll_started_at = $self->_now();
    $poll_running = 1;
    Mojo::IOLoop->subprocess(
        sub { $self->_run_poll_work() },
        sub ($loop, $err, $result) {
            $poll_running = 0;
            if ($err || !ref $result) {
                $self->log_msg(0, "IMAP subprocess error: " . ($err // 'no result'));
                return;
            }
            if ($result->{error}) {
                $self->log_msg(0, $result->{error});
                if ($result->{training_done} == -1) {
                    $self->config('training_error', $result->{error});
                    $self->config('training_mode', 0);
                }
            }
            if ($result->{training_done}) {
                unlink @pending_train_flags;
                @pending_train_flags = ();
                @pending_train_buckets = ();
                $self->config('training_mode', 0);
            }
            $self->mq()->post('IMAP_DONE', $result->{trained} // 0);
        }
    );
}

method _run_poll_work() {
    my $result = { trained => 0, training_done => 0, error => undef };
    my $dbh;
    try {
        $dbh = $self->_open_uid_db();
    }
    catch ($e) {
        $self->log_msg(0, "Could not open uid state DB: $e");
    }
    try {
        local $SIG{PIPE} = 'IGNORE';
        local $SIG{__DIE__};
        if ($self->config('training_mode') == 1) {
            $result->{trained} = $self->train_on_archive();
            $result->{training_done} = 1;
        }
        else {
            my ($nexts, $validities) = defined $dbh
                ? $self->_load_uid_state($dbh)
                : ({}, {});
            if (!%folders || $folder_change_flag == 1) {
                $self->build_folder_list();
            }
            $self->connect_server(nexts => $nexts, validities => $validities);
            %hash_values = ();
            for my $folder (keys %folders) {
                next unless exists $folders{$folder}{imap};
                $self->scan_folder($folder);
            }
            my ($any_imap) = map { $_->{imap} }
                grep { defined $_->{imap} } values %folders;
            $self->_save_uid_state($dbh, $any_imap)
                if defined $dbh && defined $any_imap;
        }
    }
    catch ($err) {
        $self->disconnect_folders();
        my $msg = $err =~ /^POPFILE-IMAP-EXCEPTION: (.+\)\))/s
            ? $1
            : "Unexpected IMAP error: $err";
        $result->{error} = $msg;
        if ($self->config('training_mode') == 1) {
            $result->{training_done} = -1;
        }
    }
    $dbh->disconnect() if defined $dbh;
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

=head2 _db_path()

Returns the full filesystem path of the POPFile SQLite database.

=cut

method _db_path() {
    $self->get_user_path($self->module_config('bayes', 'database'))
}

=head2 _open_uid_db()

Opens a fresh, self-contained DBI connection to the SQLite database for
reading and writing C<imap_folder_state>.  The caller is responsible for
calling C<disconnect()> when done.  Safe to call in forked subprocesses.

=cut

method _open_uid_db() {
    require DBI;
    return DBI->connect(
        'dbi:SQLite:dbname=' . $self->_db_path(), '', '',
        { RaiseError => 1, PrintError => 0, AutoCommit => 1 })
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

=head2 _reset_uid_next($folder)

Registers an override that forces the next poll to scan C<$folder> from the
beginning (uid_next = 1).  Used when a UI reclassification request arrives
for a message that may be below the current C<uid_next> watermark.

=cut

method _reset_uid_next($folder) {
    $self->log_msg(1, "Scheduling uid_next reset for folder $folder to force re-scan.");
    $_uid_next_override{$folder} = 1;
}

=head2 new_imap_client()

Creates, configures, and connects a new L<Services::IMAP::Client> instance,
pre-seeding it with uid state loaded from the database.  Returns the
connected client on success, or C<undef> and sets C<$imap_error> on failure.

=cut

method new_imap_client(%args) {
    my $client = Services::IMAP::Client->new();
    $client->set_configuration($self->configuration());
    $client->set_mq($self->mq());
    $client->set_name($self->name());
    if (defined $args{nexts}) {
        $client->load_uid_state(nexts => $args{nexts}, validities => $args{validities});
    }
    if ($client->connect()) {
        if ($client->login()) {
            return $client
        }
        $self->log_msg(0, "Could not LOGIN.");
        $imap_error = 'NO_LOGIN';
    }
    else {
        $self->log_msg(0, "Could not CONNECT to server.");
        $imap_error = 'NO_CONNECT';
    }
    return
}

=head2 build_folder_list()

Rebuilds the C<%folders> map from watched folders and bucket-to-folder
mappings.  Resets C<$folder_change_flag>.

=cut

method build_folder_list() {
    $self->log_msg(1, "Building list of serviced folders.");
    %folders = ();
    for my $folder ($self->watched_folders()) {
        $folders{$folder}{watched} = 1;
    }
    for my $bucket ($classifier->get_all_buckets($self->api_session())) {
        my $folder = $self->folder_for_bucket($bucket);
        $folders{$folder}{output} = $bucket if defined $folder;
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
        next if exists $folders{$folder}{imap};
        if (exists $folders{$folder}{output}
             && !exists $folders{$folder}{watched}
             && $classifier->is_pseudo_bucket($self->api_session(), $folders{$folder}{output})) {
            next;
        }
        unless (defined $imap) {
            $imap = $self->new_imap_client(%uid_state)
                or die "POPFILE-IMAP-EXCEPTION: Could not connect: $imap_error " . __FILE__ . '(' . __LINE__ . '))';
        }
        @mailboxes = $imap->get_mailbox_list() unless @mailboxes;
        my $info = $imap->status($folder);
        my $uidnext = $info->{UIDNEXT};
        my $uidvalidity = $info->{UIDVALIDITY};
        unless (defined $uidvalidity && defined $uidnext) {
            $self->log_msg(1, "Folder $folder does not exist, creating it.");
            $imap->create_folder($folder);
            my $info2 = $imap->status($folder);
            $uidnext = $info2->{UIDNEXT};
            $uidvalidity = $info2->{UIDVALIDITY};
            unless (defined $uidvalidity && defined $uidnext) {
                $self->log_msg(0, "Could not create or STATUS folder $folder, skipping.");
                delete $folders{$folder};
                next;
            }
        }
        $folders{$folder}{imap} = $imap;
        if (defined $imap->uid_validity($folder)) {
            if ($imap->check_uidvalidity($folder, $uidvalidity)) {
                unless (defined $imap->uid_next($folder)) {
                    $self->log_msg(0, "Detected invalid UIDNEXT configuration value for folder $folder. Some new messages might have been skipped.");
                    $imap->uid_next($folder, $uidnext);
                }
            }
            else {
                $self->log_msg(0, "Changed UIDVALIDITY for folder $folder. Some new messages might have been skipped.");
                $imap->uid_validity($folder, $uidvalidity);
                $imap->uid_next($folder, $uidnext);
            }
        }
        else {
            $self->log_msg(0, "Storing UIDVALIDITY for folder $folder.");
            $imap->uid_validity($folder, $uidvalidity);
            $imap->uid_next($folder, $uidnext);
        }
    }
}

=head2 disconnect_folders()

Logs out of every open IMAP connection and clears C<%folders>.

=cut

method disconnect_folders() {
    $self->log_msg(1, "Trying to disconnect all connections.");
    for my $folder (keys %folders) {
        my $imap = $folders{$folder}{imap};
        if (defined $imap && $imap->connected()) {
            try { $imap->logout() } catch ($e) {}
        }
    }
    %folders = ();
}

=head2 request_folder_move($hash, $target_bucket)

Queues a folder move for the message identified by C<$hash>.  Also resets
C<uid_next> for the message's current folder so the next poll re-scans from
the beginning of that folder and can find the message regardless of where
C<uid_next> currently stands.

=cut

method request_folder_move ($hash, $target_bucket) {
    $pending_folder_moves{$hash} = $target_bucket;
    $self->_reset_uid_next($_) for $self->watched_folders();
    return unless ref $history;
    my $slot = $history->get_slot_from_hash($hash);
    return if $slot eq '';
    my @fields = $history->get_slot_fields($slot);
    my $current_bucket = $fields[8];
    my $current_folder = defined $current_bucket
        ? $self->folder_for_bucket($current_bucket)
        : undef;
    $self->_reset_uid_next($current_folder)
        if defined $current_folder;
}

=head2 scan_folder($folder)

Scans one IMAP folder for new messages (UIDs ≥ stored C<UIDNEXT>).  For each
new message: deduplicates by hash, classifies watched-folder messages with
C<classify_message()>, and reclassifies output-folder messages with
C<reclassify_message()>.  Calls C<EXPUNGE> afterwards if any messages were
moved and C<expunge> is configured.

=cut

method scan_folder ($folder) {
    my $is_watched = exists $folders{$folder}{watched} ? 1 : 0;
    my $is_output = exists $folders{$folder}{output}  ? $folders{$folder}{output} : '';
    $self->log_msg(1, "Looking for new messages in folder $folder.");
    my $imap = $folders{$folder}{imap};
    $imap->noop();
    my $moved_message = 0;
    my @uids = $imap->get_new_message_list_unselected($folder);
    for my $msg (@uids) {
        $self->log_msg(1, "Found new message in folder $folder (UID: $msg)");
        my $hash = $self->get_hash($folder, $msg);
        $imap->uid_next($folder, $msg + 1);
        unless (defined $hash) {
            $self->log_msg(0, "Skipping message $msg.");
            next;
        }
        if (exists $pending_folder_moves{$hash}) {
            my $target_bucket = delete $pending_folder_moves{$hash};
            my $destination = $self->folder_for_bucket($target_bucket);
            if (defined $destination && $destination ne $folder) {
                $self->log_msg(0, "UI reclassification: moving message $msg to $destination.");
                $imap->move_message($msg, $destination);
                $moved_message++;
            }
            next;
        }
        if (exists $hash_values{$hash}) {
            my $destination = $hash_values{$hash};
            if ($destination ne $folder) {
                $self->log_msg(0, "Found duplicate hash value: $hash. Moving the message to $destination.");
                $imap->move_message($msg, $destination);
                $moved_message++;
            }
            else {
                $self->log_msg(0, "Found duplicate hash value: $hash. Ignoring duplicate in folder $folder.");
            }
            next;
        }
        if ($is_watched && $self->can_classify($hash)) {
            my $result = $self->classify_message($msg, $hash, $folder);
            unless (defined $result) {
                $self->log_msg(0, "classify_message failed for UID $msg in $folder — message left in place.");
                next;
            }
            $moved_message++ if $result ne '';
            $hash_values{$hash} = $result ne '' ? $result : $folder;
            next;
        }
        if (my $bucket = $is_output) {
            if (my $old_bucket = $self->can_reclassify($hash, $bucket)) {
                $self->reclassify_message($folder, $msg, $old_bucket, $hash);
            }
            elsif (!ref $history || $history->get_slot_from_hash($hash) eq '') {
                $self->insert_message_into_bucket($folder, $msg, $bucket);
            }
            next;
        }
        $self->log_msg(1, "Ignoring message $msg");
    }
    $imap->expunge() if $moved_message && $self->config('expunge');
}

=head2 classify_message($msg, $hash, $folder)

Fetches the header and (if needed) body of IMAP message C<$msg>, runs the
classifier, and moves the message to the appropriate output folder.  Returns
the destination folder name on success (empty string if not moved), or
C<undef> on error.

=cut

method classify_message ($msg, $hash, $folder) {
    my $file = $self->get_user_path('imap.tmp');
    my $pseudo_mailer;
    unless (sysopen($pseudo_mailer, $file, Fcntl::O_RDWR() | Fcntl::O_CREAT())) {
        $self->log_msg(0, "Unable to open temporary file $file. Nothing done to message $msg. ($!)");
        return
    }
    binmode $pseudo_mailer;
    my $imap = $folders{$folder}{imap};
    my $moved_a_msg = '';
    PART: for my $part (qw/ HEADER TEXT /) {
        my ($ok, @lines) = $imap->fetch_message_part($msg, $part);
        unless ($ok) {
            $self->log_msg(0, "Could not fetch the $part part of message $msg.");
            return
        }
        syswrite $pseudo_mailer, $_ for @lines;
        my ($class, $slot, $magnet_used);
        if ($part eq 'HEADER') {
            sysseek $pseudo_mailer, 0, 0;
            ($class, $slot, $magnet_used) = $classifier->classify_and_modify(
                $self->api_session(), $pseudo_mailer, undef, 1, '', undef, 0, undef);
            if ($magnet_used) {
                $self->log_msg(0, "Message with slot $slot was classified as $class using a magnet.");
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
        close $pseudo_mailer;
        unlink $file;
        if ($magnet_used || $part eq 'TEXT') {
            my $destination = $self->folder_for_bucket($class);
            if (defined $destination) {
                if ($folder ne $destination) {
                    $imap->move_message($msg, $destination);
                    $moved_a_msg = $destination;
                }
            }
            else {
                $self->log_msg(0, "Message cannot be moved because output folder for bucket $class is not defined.");
            }
            $self->log_msg(0, "Message was classified as $class.");
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
        $self->log_msg(0, "Could not fetch message $msg!");
        return
    }
    my $file = $self->get_user_path('imap.tmp');
    unless (open my $TMP, '>', $file) {
        $self->log_msg(0, "Cannot open temp file $file");
        return
    }
    else {
        print $TMP $_ for @lines;
        close $TMP;
    }
    $classifier->add_message_to_bucket($self->api_session(), $bucket, $file);
    $self->log_msg(0, "Trained message with UID $msg into bucket $bucket.");
    unlink $file;
    return 1
}

method _flush_history() {
    $self->mq()->service();
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
        $self->log_msg(0, "Could not fetch message $msg!");
        return
    }
    my $file = $self->get_user_path('imap.tmp');
    unless (open my $TMP, '>', $file) {
        $self->log_msg(0, "Cannot open temp file $file");
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
    $self->log_msg(0, "Reclassified the message with UID $msg from bucket $old_bucket to bucket $new_bucket.");
    unlink $file;
    return 1
}

=head2 get_hash($folder, $msg)

Fetches selected header fields (C<Message-Id>, C<Date>, C<Subject>,
C<Received>) for C<$msg> and returns the history hash computed by
C<< POPFile::History->get_message_hash() >>.  Returns C<undef> on failure.

=cut

method get_hash ($folder, $msg) {
    my $imap = $folders{$folder}{imap};
    my ($ok, @lines) = $imap->fetch_message_part(
        $msg, "HEADER.FIELDS (Message-id Date Subject Received)");
    unless ($ok) {
        $self->log_msg(0, "Could not FETCH the header fields of message $msg!");
        return
    }
    my (%header, $last);
    for (@lines) {
        s/[\r\n]//g;
        last if /^$/;
        if (/^([^ \t]+):[ \t]*(.*)$/) {
            $last = lc $1;
            push $header{$last}->@*, $2;
        }
        elsif (defined $last) {
            $header{$last}[-1] .= $_;
        }
    }
    my $mid = $header{'message-id'}[0];
    my $date = $header{'date'}[0];
    my $subject = $header{'subject'}[0];
    my $received = $header{'received'}[0];
    my $hash = $history->get_message_hash($mid, $date, $subject, $received);
    $self->log_msg(1, sprintf('Hashed message: %s.', $subject // 'undef'));
    $self->log_msg(1, "Message $msg has hash value $hash");
    return $hash
}

=head2 can_classify($hash)

Returns 1 if the message identified by C<$hash> has not yet been seen in
history (i.e. it is safe to classify it fresh), C<undef> otherwise.

=cut

method can_classify ($hash) {
    my $slot = $history->get_slot_from_hash($hash);
    if ($slot ne '') {
        $self->log_msg(1, "Message was already classified (slot $slot).");
        return
    }
    $self->log_msg(1, "The message is not yet in history.");
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
        $self->log_msg(2, "Message not in history; will train directly.");
        return
    }
    my ($id, $from, $to, $cc, $subject, $date, undef, $inserted,
        $bucket, $reclassified, undef, $magnetized) = $history->get_slot_fields($slot);
    $self->log_msg(2, "get_slot_fields: slot=$slot bucket=$bucket reclassified=$reclassified magnetized=$magnetized");
    if ($magnetized) {
        $self->log_msg(1, "The message was classified using a magnet and cannot be reclassified.");
        return
    }
    if ($reclassified) {
        $self->log_msg(1, "The message was already reclassified.");
        return
    }
    if ($new_bucket eq $bucket) {
        $self->log_msg(1, "Will not reclassify to same bucket ($new_bucket).");
        return
    }
    if ($classifier->is_pseudo_bucket($self->api_session(), $new_bucket)) {
        $self->log_msg(1, "Will not reclassify to pseudo-bucket ($new_bucket)");
        return
    }
    return $bucket
}

=head2 folder_for_bucket($bucket, $folder)

Get/set the IMAP folder mapped to C<$bucket>.  With only C<$bucket>, returns
the mapped folder name or C<undef>.  With both arguments, stores the new
mapping in the C<bucket_folder_mappings> config key and returns nothing.

=cut

method folder_for_bucket ($bucket, $folder = undef) {
    my $all = $self->config('bucket_folder_mappings');
    my %mapping = split /$cfg_separator/, $all;
    if (defined $folder) {
        $mapping{$bucket} = $folder;
        my $new = '';
        $new .= "$_$cfg_separator$mapping{$_}$cfg_separator" for keys %mapping;
        $self->log_msg(1, $new);
        $self->config('bucket_folder_mappings', $new);
        return
    }
    return exists $mapping{$bucket} ? $mapping{$bucket} : undef
}

=head2 watched_folders(@new_folders)

Get/set the list of watched IMAP folders.  With no arguments, returns the
current list.  With a list of folder names, replaces the stored
C<watched_folders> config value and returns nothing.

=cut

method watched_folders (@new_folders) {
    my $all = $self->config('watched_folders');
    if (@new_folders) {
        $self->config('watched_folders', join($cfg_separator, @new_folders) . $cfg_separator);
        return
    }
    return split /$cfg_separator/, $all
}

=head2 train_on_archive()

Bulk-trains the classifier from all output folders (skipping C<INBOX> and
pseudo-buckets).  Iterates every message in each output folder and calls
C<< Classifier::Bayes->add_message_to_bucket() >> for new messages (UIDs >=
stored uid_next).  Returns the number of trained messages.  C<training_mode>
is cleared by the parent callback in C<poll()>.

=cut

method train_on_archive() {
    $self->config('training_error', '');
    $self->log_msg(0, "Training on existing archive.");
    %folders = ();
    $self->build_folder_list();
    for my $folder (keys %folders) {
        delete $folders{$folder} if exists $folders{$folder}{watched};
    }
    unless (%folders) {
        $self->log_msg(0, "No output folders configured; nothing to train on.");
        %folders = ();
        return 0
    }
    $self->connect_server();
    my $limit = $self->config('training_limit') || 0;
    my $batch_size = $limit > 0 ? $limit : 50;
    my $total_msgs = 0;
    my $total_folders = 0;
    my %only = map { $_ => 1 } @pending_train_buckets;
    for my $folder (keys %folders) {
        my $bucket = $folders{$folder}{output};
        next if %only && !$only{$bucket};
        next if $classifier->is_pseudo_bucket($self->api_session(), $bucket);
        next if $folder eq 'INBOX';
        my $imap = $folders{$folder}{imap};
        $imap->uid_next($folder, 1);
        my @uids = $imap->get_new_message_list_unselected($folder);
        @uids = @uids[0 .. $limit - 1] if $limit > 0 && @uids > $limit;
        $self->log_msg(0, "Training on " . scalar(@uids) . " messages in folder $folder to bucket $bucket."
            . ($limit > 0 ? " (limit: $limit)" : ''));
        $total_folders++;
        while (@uids) {
            my @batch = splice @uids, 0, $batch_size;
            my @texts;
            for my $msg (@batch) {
                my ($ok, @lines) = $imap->fetch_message_part($msg, '');
                $imap->uid_next($folder, $msg + 1);
                unless ($ok) {
                    $self->log_msg(0, "Could not fetch message $msg!");
                    next;
                }
                push @texts, join('', @lines);
            }
            next unless @texts;
            $self->log_msg(0, "Training batch of " . scalar(@texts) . " messages in folder $folder to bucket $bucket.");
            $classifier->train_messages_batch($self->api_session(), $bucket, \@texts);
            $total_msgs += scalar @texts;
        }
    }
    $self->log_msg(0, "Training complete: $total_msgs messages trained across $total_folders folders.");
    %folders = ();
    return $total_msgs
}

1;
