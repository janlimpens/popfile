# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::History;

=head1 NAME

POPFile::History - manage the POPFile message history

=head1 DESCRIPTION

Stores and retrieves classified messages in the POPFile database.  Each
message that passes through a proxy is recorded in the C<history> table with
its classification result, sender, subject, and other header fields.

The module supports paged queries (C<start_query>/C<get_query_rows>),
on-the-fly reclassification, slot reservation for messages still in
transit, and periodic cleanup of old entries based on the
C<history_days> configuration parameter.

=cut

use Object::Pad;
use locale;

my @fields = (
    'history.id AS "slot"',
    'hdr_from AS "from"',
    'hdr_to AS "to"',
    'hdr_cc AS "cc"',
    'hdr_subject AS "subject"',
    'hdr_date AS "date"',
    'hash',
    'inserted',
    'buckets.name AS "bucket"',
    'usedtobe',
    'history.bucketid AS "bucket_id"',
    'magnets.val AS "magnet"',
    'size');
my $fields_slot = join ', ', @fields;

use lib '.';
use POPFile::Role::DBConnect;
use POPFile::Role::SQL;
class POPFile::History
    :isa(POPFile::Module) :does(POPFile::Role::DBConnect) :does(POPFile::Role::SQL);

    use Date::Parse;
    use Digest::MD5 qw(md5_hex);
    use File::Path qw(make_path);
    use builtin qw(trim);
    no warnings 'experimental::builtin';

    field $commit_list = [];

    field %queries;

    field $firsttime = 1;

    field $classifier :writer(set_classifier) = 0;

    BUILD {
        $self->set_name('history');
    }

=head2 initialize

Called to initialize the history module. Registers default config values for
C<history_days>, C<archive>, C<archive_dir>, and C<archive_classes>, and
subscribes to the C<TICKD> and C<COMIT> message queue events.

Returns 1 on success.

=cut

method initialize() {
    # Keep the history for two days

    $self->config('history_days', 2);

    # If 1, Messages are saved to an archive when they are removed or expired
    # from the history cache

    $self->config('archive', 0);

    # The directory where messages will be archived to, in sub-directories for
    # each bucket

    $self->config('archive_dir', 'archive');

    # This is an advanced setting which will save archived files to a
    # randomly numbered sub-directory, if set to greater than zero, otherwise
    # messages will be saved in the bucket directory
    #
    # 0 <= directory name < archive_classes

    $self->config('archive_classes', 0);

    # Need TICKD message for history clean up, COMIT when a message
    # is committed to the history

    $self->mq_register('TICKD', $self);
    $self->mq_register('COMIT', $self);

    return 1;
}

=head2 stop

Called to stop the history module. Flushes any pending commit queue entries
and disconnects the cloned database handle.

=cut

method stop() {
    # Commit any remaining history items.  This is needed because it's
    # possible that we get called with a stop after things have been
    # added to the queue and before service() is called

    $self->commit_history();
    $self->_disconnect();
}

method start () {
    my $dbconnect = $self->module_config('bayes', 'dbconnect') // '';
    my $dbname;
    if ($dbconnect =~ /:memory:/i) {
        $dbname = ':memory:';
    } else {
        $dbname = $self->get_user_path(
            $self->module_config('bayes', 'database') // 'popfile.db');
    }
    $self->_connect($dbname, sqlite_unicode => 1);
    return 1
}

=head2 service

Called periodically so that the module can do its work. On the first call
triggers the legacy history file upgrade, then flushes the commit queue.

Returns 1.

=cut

method service() {
    if ($firsttime) {
        $self->upgrade_history_files();
        $firsttime = 0;
    }

    # Note when we go to multiuser POPFile we'll need to change this call
    # so that we are sure that the session IDs that it is using are still
    # valid.  The easiest way will be to call it in deliver() when we get
    # a COMIT message.

    $self->commit_history();

    return 1;
}

=head2 deliver

Called by the message queue to deliver a message. Handles C<TICKD> (triggers
C<cleanup_history>) and C<COMIT> (enqueues the message for database commit).

There is no return value from this method.

=cut

method deliver ($type, @message) {
    # If a day has passed then clean up the history

    if ($type eq 'TICKD') {
        $self->cleanup_history();
    }

    if ($type eq 'COMIT') {
        push $commit_list->@*, \@message;
    }
}

#----------------------------------------------------------------------------
#
# ADDING TO THE HISTORY
#
# To add a message to the history the following sequence of calls
# is made:
#
# 1. Obtain a unique ID and filename for the new message by a call
#    to reserve_slot
#
# 2. Write the message into the filename returned
#
# 3. Call commit_slot with the bucket into which the message was
#    classified
#
# If an error occurs after #1 and the slot is unneeded then call
# release_slot
#
#----------------------------------------------------------------------------
#
# FINDING A HISTORY ENTRY
#
# 1. If you know the slot id then call get_slot_file to obtain
#    the full path where the file is stored
#
# 2. If you know the message hash then call get_slot_from hash
#    to get the slot id
#
# 3. If you know the message headers then use get_message_hash
#    to get the hash
#
#----------------------------------------------------------------------------

=head2 reserve_slot

Called to reserve a place in the history for a message that is in the
process of being received. Returns a unique slot ID and the full path to
the file where the message should be stored.

The caller is expected to later call either C<release_slot> (if the slot is
not going to be used) or C<commit_slot> (if the file has been written and
the entry should be added to the history).

The optional C<$inserted_time> parameter exists for the test-suite and lets
the caller specify the insertion timestamp (defaults to C<time()>).

=cut

method reserve_slot ($inserted_time = undef) {
    $inserted_time //= time;

    my $insert_sth = $self->db()->prepare($self->normalize_sql(
        'INSERT INTO history ( userid, committed, inserted )
         VALUES ( ?, ?, ? )'));
    my $is_sqlite2 = ($self->db()->{Driver}->{Name} =~ /SQLite2?/) &&
                     ($self->db()->{sqlite_version} =~ /^2\./);
    my $slot;

    while (!defined($slot) || $slot == 0) {
        my $r = int(rand(1000000000)+2);

        $self->log_msg(2, "reserve_slot selected random number $r");

        # Get the date/time now which will be stored in the database
        # so that we can sort on the Date: header in the message and
        # when we received it

        my $result = $insert_sth->execute(1, $r, $inserted_time);
        next if (!defined($result));

        if ($is_sqlite2) {
            $slot = $self->db()->func('last_insert_rowid');
        } else {
            $slot = $self->db()->last_insert_id(undef, undef, 'history', 'id');
        }
    }

    $insert_sth->finish;

    $self->log_msg(2, "reserve_slot returning slot id $slot");

    return ($slot, $self->get_slot_file($slot));
}

=head2 release_slot

Releases a history slot previously allocated with C<reserve_slot> and
discards it (removes the database row and the file from disk).

C<$slot> is the unique ID returned by C<reserve_slot>.

=cut

method release_slot ($slot) {
    # Remove the entry from the database and delete the file
    # if present

    $self->validate_sql_prepare_and_execute('DELETE FROM history WHERE history.id = ?', $slot);

    my $file = $self->get_slot_file($slot);

    unlink $file;

    # It's now possible that the directory for the slot file is empty
    # and we want to delete it so that things get cleaned up
    # automatically

    my $directory = $file;
    $directory =~ s/popfile[a-f0-9]{2}\.msg$//i;

    my $depth = 3;

    while ($depth > 0) {
        if (rmdir($directory)) {
            $directory =~ s![a-f0-9]{2}/$!!i;
            $depth--;
        }
        else {
            # We either aren't allowed to delete the
            # directory or it wasn't empty
            last;
        }
    }
}

=head2 commit_slot

Commits a history slot to the database and makes it part of the history.
Before calling this the full message must have been written to the file
returned by C<reserve_slot>.

Note: the message is queued for insertion and is not written to the database
until shortly afterwards (when C<service()> next runs).

C<$session> is a valid Classifier::Bayes API session; C<$slot> is the ID
from C<reserve_slot>; C<$bucket> is the bucket classified to; C<$magnet>
is the magnet used (or C<undef>).

=cut

method commit_slot ($session, $slot, $bucket, $magnet) {
    $self->mq_post('COMIT', $session, $slot, $bucket, $magnet);
}

=head2 change_slot_classification($slot, $class, $session, $undo)

Reclassifies message C<$slot> to bucket C<$class>.  C<$session> is a valid
Classifier::Bayes API session.  When C<$undo> is 0 the previous bucket ID is
saved to C<usedtobe>; when C<$undo> is 1 (undo operation) C<usedtobe> is not
updated.  Invalidates all open query caches.

=cut

method change_slot_classification ($slot, $class, $session, $undo) {
    $self->log_msg(0, "Change slot classification of $slot to $class");

    # Get the bucket ID associated with the new classification
    # then retrieve the current classification for this slot
    # and update the database

    my $bucketid = $classifier->get_bucket_id($session, $class);
    my $oldbucketid = 0;
    if (!$undo) {
        my @fields = $self->get_slot_fields($slot);
        $oldbucketid = $fields[10];
    }

    $self->validate_sql_prepare_and_execute(
        'UPDATE history SET bucketid = ?, usedtobe = ?
         WHERE id = ?',
        $bucketid, $oldbucketid, $slot);
    $self->force_requery();
}

=head2 revert_slot_classification($slot)

Undoes a previous reclassification for C<$slot> by restoring the bucket stored
in C<usedtobe> and clearing C<usedtobe> to 0.  Invalidates all open query
caches.

=cut

method revert_slot_classification ($slot) {
    my @fields = $self->get_slot_fields($slot);
    my $oldbucketid = $fields[9];

    $self->validate_sql_prepare_and_execute(
        'UPDATE history SET bucketid = ?, usedtobe = ?
         WHERE id = ?',
        $oldbucketid, 0, $slot);
    $self->force_requery();
}

=head2 get_slot_fields($slot)

Returns the database fields for a single committed history entry identified by
C<$slot>.  The returned list has the same columns as C<get_query_rows>:
C<id(0)>, C<from(1)>, C<to(2)>, C<cc(3)>, C<subject(4)>, C<date(5)>,
C<hash(6)>, C<inserted(7)>, C<bucket(8)>, C<usedtobe(9)>, C<bucketid(10)>,
C<magnet(11)>, C<size(12)>.  Returns C<undef> if C<$slot> is invalid.

=cut

method get_slot_fields ($slot) {
    return undef if (!defined($slot) || $slot !~ /^\d+$/);

    my $h = $self->validate_sql_prepare_and_execute(
        "SELECT $fields_slot FROM history, buckets
         LEFT JOIN magnets ON magnets.id = history.magnetid
         WHERE history.id = ?
           AND buckets.id = history.bucketid
           AND history.committed = 1",
        $slot);
    return $h->fetchrow_array
}

=head2 is_valid_slot($slot)

Returns 1 if C<$slot> is a committed history entry, C<undef> otherwise.

=cut

method is_valid_slot ($slot) {
    return undef if (!defined($slot) || $slot !~ /^\d+$/);

    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT id FROM history
         WHERE history.id = ?
           AND history.committed = 1',
        $slot);
    my @row = $h->fetchrow_array;

    return ((@row) && ($row[0] == $slot));
}

#----------------------------------------------------------------------------
#
# commit_history__
#
# (private) Used internally to commit messages that have been committed
# with a call to commit_slot to the database
#
#----------------------------------------------------------------------------
method commit_history() {
    unless (@{$commit_list}) {
        return;
    }

    my $update_history = $self->db()->prepare($self->normalize_sql(
        'UPDATE history SET
             hdr_from = ?,
             hdr_to = ?,
             hdr_date = ?,
             hdr_cc = ?,
             hdr_subject = ?,
             sort_from = ?,
             sort_to = ?,
             sort_cc = ?,
             committed = ?,
             bucketid = ?,
             usedtobe = ?,
             magnetid = ?,
             hash = ?,
             size = ?
         WHERE id = ?'));
    $self->db()->begin_work;
    for my $entry ($commit_list->@*) {
        my ($session, $slot, $bucket, $magnet) = $entry->@*;

        my $file = $self->get_slot_file($slot);

        # Committing to the history requires the following steps
        #
        # 1. Parse the message to extract the headers
        # 2. Compute MD5 hash of Message-ID, Date and Subject
        # 3. Update the related row with the headers and
        #    committed set to 1

        my %header;

        if (open my $file_fh, '<', $file) {
            my $last;
            while (<$file_fh>) {
                s/[\r\n]//g;

                if (/^$/) {
                    last;
                }

                if (/^([^ \t]+):[ \t]*(.*)$/) {
                    $last = lc $1;
                    push $header{$last}->@*, $2;

                } else {
                    if (defined $last) {
                        $header{$last}->[-1] .= $_;
                    }
                }
            }
            close $file_fh;
        }
        else {
            $self->log_msg(0, "Could not open history message file $file for reading.");
        }

        my $hash = $self->get_message_hash(
            $header{'message-id'}->[0],
            $header{'date'}->[0],
            $header{'subject'}->[0],
            $header{'received'}->[0]);

        # For sorting purposes the From, To and CC headers have special
        # cleaned up versions of themselves in the database.  The idea
        # is that case and certain characters should be ignored when
        # sorting these fields
        #
        # "John Graham-Cumming" <spam@jgc.org> maps to
        #     john graham-cumming spam@jgc.org

        my @sortable = qw(from to cc);
        my %sort_headers;

        for my $h (@sortable) {
            $sort_headers{$h} = $classifier->parser()->decode_string(
                $header{$h}->[0]);
            $sort_headers{$h} = lc($sort_headers{$h} || '');
            $sort_headers{$h} =~ s/[\"<>]//g;
            $sort_headers{$h} =~ s/^[ \t]+//g;
            $sort_headers{$h} =~ s/\0//g;
        }

        # Make sure that the headers we are going to insert into
        # the database have been defined and are suitably quoted

        my @required = qw(from to cc subject);

        for my $h (@required) {
            if (!defined $header{$h}->[0] || $header{$h}->[0] =~ /^\s*$/) {
                if ($h ne 'cc') {
                    $header{$h}->[0] = "<$h header missing>";
                } else {
                    $header{$h}->[0] = '';
                }
            }

            $header{$h}->[0] =~ s/\0//g;
        }

        # If we do not have a date header then set the date to
        # 0 (start of the Unix epoch), otherwise parse the string
        # using Date::Parse to interpret it and turn it into the
        # Unix epoch.

        if (!defined($header{date}->[0])) {
            $header{date}->[0] = 0;
        } else {
            $header{date}->[0] = str2time($header{date}->[0]) || 0;
        }

        # Figure out the ID of the bucket this message has been
        # classified into (and the same for the magnet if it is
        # defined)

        my $bucketid = $classifier->get_bucket_id($session, $bucket);
        my $msg_size = -s $file;

        # If we can't get the bucket ID because the bucket doesn't exist
        # which could happen when we are upgrading the history which
        # has old bucket names in it then we will remove the entry from the
        # history and log the failure

        if (defined($bucketid)) {
            my $result = $update_history->execute(
                    $header{from}->[0],    # hdr_from
                    $header{to}->[0],      # hdr_to
                    $header{date}->[0],    # hdr_date
                    $header{cc}->[0],      # hdr_cc
                    $header{subject}->[0], # hdr_subject
                    $sort_headers{from},    # sort_from
                    $sort_headers{to},      # sort_to
                    $sort_headers{cc},      # sort_cc
                    1,                      # committed
                    $bucketid,              # bucketid
                    0,                      # usedtobe
                    $magnet,                # magnetid
                    $hash,                  # hash
                    $msg_size,              # size
                    $slot                   # id
                    );
        } else {
            $self->log_msg(0, "Couldn't find bucket ID for bucket $bucket when committing $slot");
            $self->release_slot($slot);
        }
    }
    $self->db()->commit;
    $update_history->finish;

    $commit_list = [];
    $self->force_requery();
}

=head2 delete_slot($slot, $archive)

Removes a history entry from the database and its message file from disk.
When C<$archive> is 1 and the C<archive> config option is enabled, copies the
file to the archive directory (organised by bucket) before deleting.
Invalidates all open query caches.

=cut

method delete_slot ($slot, $archive) {
    my $file = $self->get_slot_file($slot);
    $self->log_msg(2, "delete_slot called for slot $slot, file $file");

    if ($archive && $self->config('archive')) {
        my $path = $self->get_user_path($self->config('archive_dir'), 0);

        $self->make_directory($path);

        my $b = $self->db()->selectrow_arrayref(
            "select buckets.name from history, buckets
                 where history.bucketid = buckets.id and
                       history.id = $slot;");

        my $bucket = $b->[0];

        if (($bucket ne 'unclassified') &&
             ($bucket ne 'unknown class')) {
            $path .= "\/" . $bucket;
            $self->make_directory($path);

            if ($self->config('archive_classes') > 0) {
                my $subdirectory = int(rand($self->config('archive_classes')));
                $path .= "\/" . $subdirectory;
                $self->make_directory($path);
            }

            # Previous comment about this potentially being unsafe
            # (may have placed messages in unusual places, or
            # overwritten files) no longer applies. Files are now
            # placed in the user directory, in the archive_dir
            # subdirectory

            $self->copy_file($file, $path, "popfile$slot.msg");
        }
    }

    # Now remove the entry from the database, and the file from disk,
    # and also invalidate the caches of any open queries since they
    # may have been affected

    $self->release_slot($slot);
    $self->force_requery();
}

=head2 start_deleting()

Opens a database transaction before a batch of C<delete_slot> calls so that
the deletions are applied as a single atomic write.  Call C<stop_deleting()>
when done.

=cut

method start_deleting() {
#    $classifier->tweak_sqlite( 1, 1, $self->db() );
    $self->db()->begin_work;
}

=head2 stop_deleting()

Commits the transaction opened by C<start_deleting()>.

=cut

method stop_deleting() {
    $self->db()->commit;
#    $classifier->tweak_sqlite( 1, 0, $self->db() );
}

=head2 get_slot_file($slot)

Returns the full filesystem path for the message file associated with
C<$slot>.  The slot ID is encoded as an 8-digit hex number and mapped to a
three-level directory tree under C<msgdir> (e.g.
C<msgdir/aa/bb/cc/popfiledd.msg>).  Creates any missing intermediate
directories.

=cut

method get_slot_file ($slot) {
    # The mapping between the slot and the file goes as follows:
    #
    # 1. Convert the file to an 8 digit hex number (with leading
    #    zeroes).
    # 2. Call that number aabbccdd
    # 3. Build the path aa/bb/cc
    # 4. Name the file popfiledd.msg
    # 5. Add the msgdir location to obtain
    #        msgdir/aa/bb/cc/popfiledd.msg
    #
    # Hence each directory can have up to 256 entries

    my $hex_slot = sprintf('%8.8x', $slot);
    my $path = $self->get_user_path(
        $self->global_config('msgdir') .
        substr($hex_slot, 0, 2) . '/', 0);
    $self->make_directory($path);
    $path .= substr($hex_slot, 2, 2) . '/';
    $self->make_directory($path);
    $path .= substr($hex_slot, 4, 2) . '/';
    $self->make_directory($path);

    my $file = 'popfile' . substr($hex_slot, 6, 2) . '.msg';
    return $path . $file;
}

=head2 get_message_hash($messageid, $date, $subject, $received)

Computes an MD5 hex digest over the four key message headers — C<Message-ID>,
C<Date>, C<Subject>, and the first C<Received> line — so that the same message
can later be located with C<get_slot_from_hash>.  Pass C<undef> for any header
that is absent; it is treated as the empty string.

=cut

method get_message_hash ($messageid, $date, $subject, $received) {
    $messageid = '' if (!defined($messageid));
    $date = '' if (!defined($date));
    $subject = '' if (!defined($subject));
    $received = '' if (!defined($received));

    return md5_hex("[$messageid][$date][$subject][$received]");
}

=head2 get_slot_from_hash($hash)

Returns the slot ID for the first history entry whose C<hash> matches the MD5
digest produced by C<get_message_hash>.  Returns the empty string if no match
is found.

=cut

method get_slot_from_hash ($hash) {
    my $h = $self->validate_sql_prepare_and_execute(
        'SELECT id FROM history WHERE hash = ? LIMIT 1',
        $hash);
    my $result = $h->fetchrow_arrayref;

    return defined($result)?$result->[0]:'';
}

#----------------------------------------------------------------------------
#
# QUERYING THE HISTORY
#
# 1. Start a query session by calling start_query and obtain a unique
#    ID
#
# 2. Set the query parameter (i.e. sort, search and filter) with a call
#    to set_query
#
# 3. Obtain the number of history rows returned by calling get_query_size
#
# 4. Get segments of the history returned by calling get_query_rows with
#    the start and end rows needed
#
# 5. When finished with the query call stop_query
#
#----------------------------------------------------------------------------

=head2 start_query()

Allocates a new query session and returns a unique ID string.  The session
holds a result cache and must be released with C<stop_query()> when no longer
needed.  Use C<set_query()> to specify filter and sort options, then retrieve
rows with C<get_query_rows()>.

=cut

method start_query() {
    # Think of a large random number, make sure that it hasn't
    # been used and then return it

    while (1) {
        my $id = sprintf('%8.8x', int(rand(4294967295)));

        if (!defined($queries{$id})) {
            $queries{$id}{query} = 0;
            $queries{$id}{count} = 0;
            $queries{$id}{cache} = ();
            return $id
        }
    }
}

=head2 stop_query($id)

Releases the query session identified by C<$id>, freeing its database
statement handle and cached rows.

=cut

method stop_query ($id) {
    # If the cache size hasn't grown to the row
    # count then we didn't fetch everything and so
    # we fill call finish to clean up

    my $q = $queries{$id}{query};

    if ((defined $q) && ($q != 0)) {
        if ($#{$queries{$id}{cache}} !=
             $queries{$id}{count}) {
        $q->finish;
            undef $queries{$id}{query};
        }
    }

    delete $queries{$id};
}

=head2 set_query($id, $filter, $search, $sort, $not)

Configures the query session C<$id> with optional filter, full-text search,
and sort criteria.

=over 4

=item C<$filter>

Bucket name to restrict results to, or one of the special values
C<__filter__magnet> (magnet-classified only) or C<__filter__reclassified>
(reclassified messages only).  Empty string means no filter.

=item C<$search>

String to match against C<hdr_from> and C<hdr_subject> (SQL LIKE).  Empty
string means no search.

=item C<$sort>

Field to sort on: one of C<inserted>, C<from>, C<to>, C<cc>, C<subject>,
C<bucket>, C<date>, or C<size>.  Prefix with C<-> for descending order.
Defaults to C<inserted desc>.

=item C<$not>

When 1, negates both the search and the filter.

=back

Results are not fetched immediately; call C<get_query_size()> and
C<get_query_rows()> to retrieve them.

=cut

method set_query ($id, $filter, $search, $sort, $not) {
    $search =~ s/\0//g;
    $sort = '' if ($sort !~ /^(\-)?(inserted|from|to|cc|subject|bucket|date|size)$/);

    # If this query has already been done and is in the cache
    # then do no work here

    if (defined($queries{$id}{fields}) &&
         ($queries{$id}{fields} eq "$filter:$search:$sort:$not")) {
        return;
    }

    $queries{$id}{fields} = "$filter:$search:$sort:$not";

    # We do two queries, the first to get the total number of rows that
    # would be returned and then we start the real query.  This is done
    # so that we know the size of the resulting data without having
    # to retrieve it all

    $queries{$id}{base} =
        'select XXX from history, buckets
                left join magnets on magnets.id = history.magnetid
                where history.userid = 1 and committed = 1';
    $queries{$id}{base} .= ' and history.bucketid = buckets.id';
    $queries{$id}{params} = [];

    my $not_equal = $not ? '!='  : '=';
    my $equal = $not ? '='   : '!=';

    if ($search ne '') {
        my $qb = $self->qb();
        my $pat = '%' . $search . '%';
        my $like_expr = $qb->combine_or(
            $qb->like('hdr_from', $pat),
            $qb->like('hdr_subject', $pat));
        my $expr = $not ? $qb->negate($like_expr) : $like_expr;
        $queries{$id}{base} .= ' and ' . $expr->as_sql();
        push $queries{$id}{params}->@*, $expr->params();
    }

    if ($filter ne '') {
        if ($filter eq '__filter__magnet') {
            $queries{$id}{base} .= " and history.magnetid $equal 0";
        } else {
            if ($filter eq '__filter__reclassified') {
                $queries{$id}{base} .= " and history.usedtobe $equal 0";
            } else {
                my $qb = $self->qb();
                my $expr = $qb->compare('buckets.name', $filter,
                    comparator => $not_equal);
                $queries{$id}{base} .= ' and ' . $expr->as_sql();
                push $queries{$id}{params}->@*, $expr->params();
            }
        }
    }

    # Add the sort option (if there is one)

    if ($sort ne '') {
        $sort =~ s/^(\-)//;
        my $direction = defined($1)?'desc':'asc';
        if ($sort eq 'bucket') {
            $sort = 'buckets.name';
        } else {
            if ($sort =~ /from|to|cc/) {
                $sort = "sort_$sort";
            } else {
                if ($sort ne 'inserted' && $sort ne 'size') {
                    $sort = "hdr_$sort";
                }
            }
        }
        $queries{$id}{base} .= " order by $sort $direction;";
    } else {
        $queries{$id}{base} .= ' order by inserted desc;';
    }

    my $count = $queries{$id}{base};
    $self->log_msg(2, "Base query is $count");
    $count =~ s/XXX/COUNT(*)/;

    my $h = $self->validate_sql_prepare_and_execute($count, $queries{$id}{params}->@*);
    $queries{$id}{count} = $h->fetchrow_arrayref->[0];
    $h->finish;

    my $select = $queries{$id}{base};
    $select =~ s/XXX/$fields_slot/;
    $queries{$id}{query} = $self->db()->prepare($select);
    $queries{$id}{cache} = ();
}

method get_search_queries(%args) {
    my $qb = $self->qb();
    my $where = $qb->combine(AND =>
        $qb->compare('history.userid', \1),
        $qb->compare('committed', \1),
        $qb->compare('history.bucketid' => \'buckets.id'));
    my $base_query = $qb
        ->select()
        ->from(qw(history buckets))
        ->joins( $qb->join('magnets')->on($qb->compare('magnets.id', \'history.magnetid')) )
        ->where($where);
    if (my $search = $args{search}) {
        $search =~ s/\0//g;
        $search = trim($search);
        my $pat = "%$search%";
        my $like_expr = $qb->combine(OR =>
            $qb->like('hdr_from', $pat),
            $qb->like('hdr_subject', $pat));
        $where->add_expression($like_expr);
    }
    if (my $bucket = $args{bucket}) {
        $where->add_expression($qb->compare('buckets.name', $bucket));
    }
    my $count_q = $base_query->clone(columns => ['COUNT(*)']);
    my ($total) = $self->db()->selectcol_arrayref($count_q->as_sql(), undef, $count_q->params())->@*;
    my $pagination = Data::Page->new();
    $pagination->total_entries($total);
    $pagination->entries_per_page($args{per_page}//25);
    $pagination->current_page($args{page}//1);
    my @columns = split /\s?,\s?/, $fields_slot;
    my $rows_q = $base_query->clone(columns => \@columns);
    if (my $sort = $args{sort}) {
        ($sort, my $direction) = split / /, $sort;
        if ($sort =~ /^-?(inserted|from|to|cc|subject|bucket|date|size)$/i) {
            $rows_q->order_by($qb->order_by($1, $direction//'ASC'));
        }
    }
    $rows_q->limit($pagination->entries_per_page());
    $rows_q->offset($pagination->skipped());
    my $rows = $self->db()->selectall_arrayref($rows_q->as_sql(), { Slice => {} }, $rows_q->params());
    return ($total+0, $rows)
}

=head2 delete_query($id)

Deletes every history entry matched by the current query C<$id> from both the
database and disk (with archiving if configured).  Wraps the deletions in a
C<start_deleting>/C<stop_deleting> transaction.

=cut

method delete_query ($id) {
    $self->start_deleting();

    my $delete = $queries{$id}{base};
    $delete =~ s/XXX/history.id/;
    my $d = $self->validate_sql_prepare_and_execute($delete, $queries{$id}{params}->@*);
    my $history_id;
    my @row;
    my @ids;
    $d->bind_columns(\$history_id);
    while ($d->fetchrow_arrayref) {
        push (@ids, $history_id);
    }
    for my $id (@ids) {
        $self->delete_slot($id, 1);
    }

    $self->stop_deleting();
}

=head2 get_query_size($id)

Returns the total number of rows matched by the query C<$id>.  Must be called
after C<set_query()>.

=cut

method get_query_size ($id) {
    return $queries{$id}{count};
}

=head2 get_query_rows($id, $start, $count)

Returns C<$count> rows starting at 1-based position C<$start> from the result
set of query C<$id>.  Rows are fetched lazily and cached.  Each row is an
array ref with the columns: C<id(0)>, C<from(1)>, C<to(2)>, C<cc(3)>,
C<subject(4)>, C<date(5)>, C<hash(6)>, C<inserted(7)>, C<bucket(8)>,
C<usedtobe(9)>, C<bucketid(10)>, C<magnet(11)>, C<size(12)>.

=cut

method get_query_rows ($id, $start, $count) {
    # First see if we have already retrieved these rows from the query
    # if we have then we can just return them from the cache.  Otherwise
    # fetch the rows from the database and then return them

    my $size = $#{$queries{$id}{cache}}+1;

    $self->log_msg(2, "Request for rows $start ($count), current size $size");

    if (($size < ($start + $count - 1))) {
        my $rows = $start + $count - $size;
        $self->log_msg(2, "Getting $rows rows from database");
        $queries{$id}{query}->execute($queries{$id}{params}->@*);
        $queries{$id}{cache} = $queries{$id}{query}->fetchall_arrayref(
            undef, $start + $count - 1);
        $queries{$id}{query}->finish;
    }

    my ($from, $to) = ($start-1, $start+$count-2);

    $self->log_msg(2, "Returning $from..$to");

    return $queries{$id}{cache}->@[$from..$to];
}

# ---------------------------------------------------------------------------
#
# make_directory__
#
# Wrapper for mkdir that ensures that the path we are making doesn't end in
# / or \ (Done because your can't do mkdir 'foo/' on NextStep.
#
# $path        The directory to make
#
# Returns whatever mkdir returns
#
# ---------------------------------------------------------------------------
method make_directory ($path) {
    $path =~ s/[\\\/]$//;

    return 1 if (-d $path);
    return make_path($path);
}

# ---------------------------------------------------------------------------
#
# compare_mf__
#
# Compares two mailfiles, used for sorting mail into order
#
# ---------------------------------------------------------------------------
sub compare_mf__
{
    $a =~ /popfile(\d+)=(\d+)\.msg/;
    my ($ad, $am) = ($1, $2);

    $b =~ /popfile(\d+)=(\d+)\.msg/;
    my ($bd, $bm) = ($1, $2);

    if ($ad == $bd) {
        return ($bm <=> $am);
    } else {
        return ($bd <=> $ad);
    }
}

# ---------------------------------------------------------------------------
#
# upgrade_history_files__
#
# Looks for old .MSG/.CLS history entries and sticks them in the database
#
# ---------------------------------------------------------------------------
method upgrade_history_files() {
    # See if there are any .MSG files in the msgdir, and if there are
    # upgrade them by placing them in the database

    my @msgs = sort compare_mf__ glob $self->get_user_path(
        $self->global_config('msgdir') . 'popfile*.msg', 0);
    if (@msgs) {
        my $session = $classifier->get_session_key('admin', '');

        print "\nFound old history files, moving them into database\n    ";

        my $i = 0;
        $self->db()->begin_work;
        for my $msg (@msgs) {
            if ((++$i % 100) == 0) {
                print "[$i]";
                STDOUT->flush();
            }

            # NOTE.  We drop the information in $usedtobe, so that
            # reclassified messages will no longer appear reclassified
            # in upgraded history.  Also the $magnet is ignored so
            # upgraded history will have no magnet information.

            my ($reclassified, $bucket, $usedtobe, $magnet) =
                $self->history_read_class($msg);
            if ($bucket ne 'unknown_class') {
                my ($slot, $file) = $self->reserve_slot();
                rename $msg, $file;
                my @message = ($session, $slot, $bucket, 0);
                push $commit_list->@*, \@message;
            }
        }
        $self->db()->commit;

        print "\nDone upgrading history\n";

        $self->commit_history();
        $classifier->release_session_key($session);

        unlink $self->get_user_path(
            $self->global_config('msgdir') . 'history_cache', 0);
    }
}

# ---------------------------------------------------------------------------
#
# history_read_class__ - load and delete the class file for a message.
#
# returns: ( reclassified, bucket, usedtobe, magnet )
#   values:
#       reclassified:   boolean, true if message has been reclassified
#       bucket:         string, the bucket the message is in presently,
#                       unknown class if an error occurs
#       usedtobe:       string, the bucket the message used to be in
#                       (null if not reclassified)
#       magnet:         string, the magnet
#
# $filename     The name of the message to load the class for
#
# ---------------------------------------------------------------------------
method history_read_class ($filename) {
    $filename =~ s/msg$/cls/;

    my $reclassified = 0;
    my $bucket = 'unknown class';
    my $usedtobe;
    my $magnet = '';

    if (open my $class_fh, '<', $filename) {
        $bucket = <$class_fh>;
        if (defined($bucket) &&
             ($bucket =~ /([^ ]+) MAGNET ([^\r\n]+)/)) {
            $bucket = $1;
            $magnet = $2;
        }

        $reclassified = 0;
        if (defined($bucket) && ($bucket =~ /RECLASSIFIED/)) {
            $bucket = <$class_fh>;
            $usedtobe = <$class_fh>;
            $reclassified = 1;
            $usedtobe =~ s/[\r\n]//g;
        }
        close $class_fh;
        $bucket =~ s/[\r\n]//g if defined($bucket);
        unlink $filename;
    } else {
        return (undef, $bucket, undef, undef);
    }

    $bucket = 'unknown class' if (!defined($bucket));

    return ($reclassified, $bucket, $usedtobe, $magnet);
}

=head2 cleanup_history()

Deletes history entries older than C<history_days> configuration days.
Called automatically on each C<TICKD> message-queue event (i.e. once per day).

=cut

method cleanup_history() {
    my $seconds_per_day = 24 * 60 * 60;
    my $old = time - $self->config('history_days') * $seconds_per_day;
    my @ids;
    my $d = $self->validate_sql_prepare_and_execute(
        'SELECT id FROM history WHERE inserted < ?',
        $old);
    my $id;
    $d->bind_columns(\$id);
    while ($d->fetchrow_arrayref) {
        push (@ids, $id);
    }
    $d->finish;
    for my $id (@ids) {
        $self->delete_slot($id, 1);
    }
}

# ---------------------------------------------------------------------------
#
# copy_file__
#
# Utility to copy a file and ensure that the path it is going to
# exists
#
# $from               Where to copy from
# $to_dir             The directory it will be copied to
# $to_name            The name of the destination (without the directory)
#
# ---------------------------------------------------------------------------
method copy_file ($from, $to_dir, $to_name) {
    if (open(FROM, "<$from")) {
        if (open(TO, ">$to_dir\/$to_name")) {
            binmode FROM;
            binmode TO;
            while (<FROM>) {
                print TO $_;
            }
            close TO;
        }

        close FROM;
    }
}

=head2 force_requery()

Invalidates the result caches of all open query sessions so that the next call
to C<get_query_rows()> re-executes the query against the database.  Called
automatically after any write operation.

=cut

method force_requery() {
    # Force requery since the messages have changed

    for my $id (keys %queries) {
        $queries{$id}{fields} = '';
    }
}

1;
