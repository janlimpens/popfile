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

The module supports paged queries via C<POPFile::HistoryQueries>,
on-the-fly reclassification, slot reservation for messages still in
transit, and periodic cleanup of old entries based on the
C<history_days> configuration parameter.

=cut

use Object::Pad;
use POPFile::Features;
use locale;
use lib '.';
use POPFile::DBUtil ();

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

use POPFile::Role::DBConnect;
use POPFile::Role::SQL;
use POPFile::HistoryQueries;
class POPFile::History
    :isa(POPFile::Module) :does(POPFile::Role::DBConnect) :does(POPFile::Role::SQL);

    use Date::Parse;
    use Digest::MD5 qw(md5_hex);
    use Path::Tiny qw(path);

    field $commit_list = [];

    field $queries :reader;

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
    $self->config('history_days', 2);
    $self->config('archive', 0);
    $self->config('archive_dir', 'archive');
    $self->config('archive_classes', 0);
    $self->mq_register('TICKD', $self);
    $self->mq_register('COMIT', $self);
    return 1;
}

=head2 stop

Called to stop the history module. Flushes any pending commit queue entries
and disconnects the cloned database handle.

=cut

method stop() {
    $self->commit_history();
    $self->_disconnect();
}

method _txn($coderef) {
    my $dbh = $self->get_handle();
    $dbh->begin_work();
    try {
        $coderef->();
        $dbh->commit();
    } catch ($e) {
        $dbh->rollback();
        die $e;
    }
}

method start () {
    $queries = POPFile::HistoryQueries->new();
    $self->connect_db(
        dbconnect => $self->module_config('bayes', 'dbconnect') // '',
        database => $self->module_config('bayes', 'database') // 'popfile.db');
    return 1
}

=head2 service

Called periodically so that the module can do its work. Flushes the
pending commit queue. Returns 1.

=cut

method service() {
    $self->commit_history();
    return 1;
}

=head2 deliver

Called by the message queue to deliver a message. Handles C<TICKD> (triggers
C<cleanup_history>) and C<COMIT> (enqueues the message for database commit).

There is no return value from this method.

=cut

method deliver ($type, @message) {
    if ($type eq 'TICKD') {
        $self->cleanup_history();
    }
    if ($type eq 'COMIT') {
        push $commit_list->@*, \@message;
    }
}

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
    my $insert_sth = $self->get_handle()->prepare(POPFile::DBUtil::normalize_sql(
        'INSERT INTO history ( userid, committed, inserted )
         VALUES ( ?, ?, ? )'));
    my $slot;
    while (!defined($slot) || $slot == 0) {
        my $candidate = int(rand(1000000000) + 2);
        $self->log_msg(DEBUG => "reserve_slot selected random number $candidate");
        my $result = $insert_sth->execute(1, $candidate, $inserted_time);
        next
            unless defined $result;
        $slot = $self->get_handle()->last_insert_id(undef, undef, 'history', 'id');
    }
    $insert_sth->finish();
    $self->log_msg(DEBUG => "reserve_slot returning slot id $slot");
    return ($slot, $self->get_slot_file($slot));
}

=head2 release_slot

Releases a history slot previously allocated with C<reserve_slot> and
discards it (removes the database row and the file from disk).

C<$slot> is the unique ID returned by C<reserve_slot>.

=cut

method release_slot ($slot) {
    $self->get_handle()->do('DELETE FROM history WHERE history.id = ?', undef, $slot);
    my $file = $self->get_slot_file($slot);
    unlink $file;
    my $directory = $file;
    $directory =~ s/popfile[a-f0-9]{2}\.msg$//i;
    my $depth = 3;
    while ($depth > 0) {
        if (rmdir($directory)) {
            $directory =~ s![a-f0-9]{2}/$!!i;
            $depth--;
        } else {
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
    $self->log_msg(WARN => "Change slot classification of $slot to $class");
    my $bucketid = $classifier->get_bucket_id($session, $class);
    my $oldbucketid = 0;
    if (!$undo) {
        my @fields = $self->get_slot_fields($slot);
        $oldbucketid = $fields[10];
    }
    $self->get_handle()->do(
        'UPDATE history SET bucketid = ?, usedtobe = ?
         WHERE id = ?',
        undef, $bucketid, $oldbucketid, $slot);
    $queries->invalidate_all();
}

=head2 set_message_id($slot, $mid)

Stores the IMAP C<Message-ID> header value for history entry C<$slot>.
Used by the IMAP service so that direct moves can be performed after restart
without rescanning the entire folder.

=cut

method set_message_id ($slot, $mid) {
    $self->get_handle()->do(
        'UPDATE history SET mid = ? WHERE id = ?',
        undef, $mid, $slot)
}

=head2 revert_slot_classification($slot)

Undoes a previous reclassification for C<$slot> by restoring the bucket stored
in C<usedtobe> and clearing C<usedtobe> to 0.  Invalidates all open query
caches.

=cut

method revert_slot_classification ($slot) {
    my @fields = $self->get_slot_fields($slot);
    my $oldbucketid = $fields[9];

    $self->get_handle()->do(
        'UPDATE history SET bucketid = ?, usedtobe = ?
         WHERE id = ?',
        undef, $oldbucketid, 0, $slot);
    $queries->invalidate_all();
}

=head2 get_slot_fields($slot)

Returns the database fields for a single committed history entry identified by
C<$slot>.  The returned list has the same columns as C<get_query_rows>:
C<id(0)>, C<from(1)>, C<to(2)>, C<cc(3)>, C<subject(4)>, C<date(5)>,
C<hash(6)>, C<inserted(7)>, C<bucket(8)>, C<usedtobe(9)>, C<bucketid(10)>,
C<magnet(11)>, C<size(12)>.  Returns C<undef> if C<$slot> is invalid.

=cut

method get_slot_fields ($slot) {
    return if !defined($slot) || $slot !~ /^\d+$/;

    my $sth = $self->get_handle()->prepare(
        "SELECT $fields_slot FROM history, buckets
         LEFT JOIN magnets ON magnets.id = history.magnetid
         WHERE history.id = ?
           AND buckets.id = history.bucketid
           AND history.committed = 1");
    $sth->execute($slot);
    return $sth->fetchrow_array
}

=head2 is_valid_slot($slot)

Returns 1 if C<$slot> is a committed history entry, C<undef> otherwise.

=cut

method is_valid_slot ($slot) {
    return
        if !defined($slot) || $slot !~ /^\d+$/;
    my $sth = $self->get_handle()->prepare(
        'SELECT id FROM history
         WHERE history.id = ?
           AND history.committed = 1');
    $sth->execute($slot);
    my @row = $sth->fetchrow_array;
    return (@row && $row[0] == $slot);
}

#----------------------------------------------------------------------------
# commit_history — flushes the COMIT queue to the database
#----------------------------------------------------------------------------
method commit_history() {
    return
        unless $commit_list->@*;
    my $update_history = $self->get_handle()->prepare(POPFile::DBUtil::normalize_sql(
        'UPDATE history SET
             hdr_from = ?, hdr_to = ?, hdr_date = ?, hdr_cc = ?,
             hdr_subject = ?, sort_from = ?, sort_to = ?, sort_cc = ?,
             committed = ?, bucketid = ?, usedtobe = ?, magnetid = ?,
             hash = ?, size = ?
         WHERE id = ?'));
    $self->_txn(sub {
        for my $entry ($commit_list->@*) {
            my ($session, $slot, $bucket, $magnet) = $entry->@*;
            my $file = $self->get_slot_file($slot);
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
                    } elsif (defined $last) {
                        $header{$last}->[-1] .= $_;
                    }
                }
                close $file_fh;
            } else {
                $self->log_msg(WARN => "Could not open history message file $file for reading.");
            }
            my $hash = $self->get_message_hash(
                $header{'message-id'}->[0],
                $header{'date'}->[0],
                $header{'subject'}->[0],
                $header{'received'}->[0]);
            my %sort_headers;
            for my $header_name (qw(from to cc)) {
                $sort_headers{$header_name} = $classifier->parser()->decode_string(
                    $header{$header_name}->[0]);
                $sort_headers{$header_name} = lc($sort_headers{$header_name} || '');
                $sort_headers{$header_name} =~ s/[\"<>]//g;
                $sort_headers{$header_name} =~ s/^[ \t]+//g;
                $sort_headers{$header_name} =~ s/\0//g;
            }
            for my $header_name (qw(from to cc subject)) {
                if (!defined $header{$header_name}->[0]
                    || $header{$header_name}->[0] =~ /^\s*$/) {
                    $header{$header_name}->[0] = $header_name eq 'cc'
                        ? '' : "<$header_name header missing>";
                }
                $header{$header_name}->[0] =~ s/\0//g;
            }
            $header{date}->[0] = defined $header{date}->[0]
                ? str2time($header{date}->[0]) || 0
                : 0;
            my $bucketid = $classifier->get_bucket_id($session, $bucket);
            my $msg_size = -s $file;
            if (defined($bucketid)) {
                $update_history->execute(
                    $header{from}->[0], $header{to}->[0], $header{date}->[0],
                    $header{cc}->[0], $header{subject}->[0],
                    $sort_headers{from}, $sort_headers{to}, $sort_headers{cc},
                    1, $bucketid, 0, $magnet, $hash, $msg_size, $slot);
            } else {
                $self->log_msg(WARN => "Couldn't find bucket ID for bucket $bucket when committing $slot");
                $self->release_slot($slot);
            }
        }
    });
    $update_history->finish();
    $commit_list = [];
    $queries->invalidate_all();
}

=head2 delete_slot($slot, $archive)

Removes a history entry from the database and its message file from disk.
When C<$archive> is 1 and the C<archive> config option is enabled, copies the
file to the archive directory (organised by bucket) before deleting.
Invalidates all open query caches.

=cut

method delete_slot ($slot, $archive) {
    return
        unless defined $slot && $slot =~ /^\d+$/;
    my $file = $self->get_slot_file($slot);
    $self->log_msg(DEBUG => "delete_slot called for slot $slot, file $file");
    if ($archive && $self->config('archive')) {
        my $path = $self->get_user_path($self->config('archive_dir'), 0);
        path($path)->mkpath;
        my $qb = $self->qb();
        my $select = $qb->select('buckets.name')
            ->from(qw(history buckets))
            ->where($qb->combine_and(
                $qb->compare('history.bucketid' => \'buckets.id'),
                $qb->compare('history.id' => $slot)))
            ->limit(1);
        my $row = $self->get_handle()->selectrow_arrayref(
            $select->as_sql(), undef, $select->params());
        my $bucket_name = $row->[0];
        if ($bucket_name ne 'unclassified'
            && $bucket_name ne 'unknown class') {
            $path .= '/' . $bucket_name;
            path($path)->mkpath;
            if ($self->config('archive_classes') > 0) {
                my $subdir = int(rand($self->config('archive_classes')));
                $path .= '/' . $subdir;
                path($path)->mkpath;
            }
            path($file)->copy("$path/popfile$slot.msg");
        }
    }
    $self->release_slot($slot);
    $queries->invalidate_all();
}

=head2 get_slot_file($slot)

Returns the full filesystem path for the message file associated with
C<$slot>.  The slot ID is encoded as an 8-digit hex number and mapped to a
three-level directory tree under C<msgdir> (e.g.
C<msgdir/aa/bb/cc/popfiledd.msg>).  Creates any missing intermediate
directories.

=cut

method get_slot_file ($slot) {
    my $hex_slot = sprintf('%8.8x', $slot);
    my $path = $self->get_user_path(
        $self->global_config('msgdir')
        . substr($hex_slot, 0, 2) . '/', 0);
    path($path)->mkpath;
    $path .= substr($hex_slot, 2, 2) . '/';
    path($path)->mkpath;
    $path .= substr($hex_slot, 4, 2) . '/';
    path($path)->mkpath;
    return $path . 'popfile' . substr($hex_slot, 6, 2) . '.msg';
}

=head2 get_message_hash($messageid, $date, $subject, $received)

Computes an MD5 hex digest over the four key message headers — C<Message-ID>,
C<Date>, C<Subject>, and the first C<Received> line — so that the same message
can later be located with C<get_slot_from_hash>.  Pass C<undef> for any header
that is absent; it is treated as the empty string.

=cut

method get_message_hash ($messageid, $date, $subject, $received) {
    $messageid //= '';
    $date //= '';
    $subject //= '';
    $received //= '';
    return md5_hex("[$messageid][$date][$subject][$received]");
}

=head2 get_slot_from_hash($hash)

Returns the slot ID for the first history entry whose C<hash> matches the MD5
digest produced by C<get_message_hash>.  Returns the empty string if no match
is found.

=cut

method get_slot_from_hash ($hash) {
    my $sth = $self->get_handle()->prepare(
        'SELECT id FROM history WHERE hash = ? LIMIT 1');
    $sth->execute($hash);
    my $result = $sth->fetchrow_arrayref;

    return defined($result) ? $result->[0] : '';
}

=head2 set_query($id, $filter, $search, $sort, $not)

Delegates to L<POPFile::HistoryQueries/set>.

=cut

method set_query ($id, $filter, $search, $sort, $not) {
    $queries->set($id, $filter, $search, $sort, $not, $self->get_handle())
}

=head2 delete_query($id)

Deletes every history entry matched by the current query C<$id> from both the
database and disk (with archiving if configured).  Wrapped in C<_txn> for atomicity.

=cut

method delete_query ($id) {
    $self->_txn(sub {
        my $ids = $queries->delete_ids($id, $self->get_handle());
        for my $slot_id ($ids->@*) {
            $self->delete_slot($slot_id, 1)
        }
    });
}

=head2 cleanup_history()

Deletes history entries older than C<history_days> configuration days.
Called automatically on each C<TICKD> message-queue event (i.e. once per day).

=cut

method cleanup_history() {
    my $seconds_per_day = 24 * 60 * 60;
    my $cutoff_time = time - $self->config('history_days') * $seconds_per_day;
    my $sth = $self->get_handle()->prepare_cached(
        'SELECT id FROM history WHERE inserted < ?');
    $sth->execute($cutoff_time);
    my @ids = map { $_->[0] } $sth->fetchall_arrayref->@*;
    $sth->finish();
    for my $id (@ids) {
        $self->delete_slot($id, 1);
    }
}

1;
