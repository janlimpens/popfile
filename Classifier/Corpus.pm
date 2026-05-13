# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Corpus;

use Object::Pad;
use POPFile::Features;

class Classifier::Corpus;

=head1 NAME

Classifier::Corpus — word-count queries backed by Bayes' in-memory caches

=head1 DESCRIPTION

Stateless query methods for the word-count caches maintained by Bayes.
All cache hashes and DB handles are passed as parameters.

=cut

method bucket_count($bcount, $userid, $bucket) {
    return $bcount->{$userid}{$bucket}
        // 0
}

method bucket_unique($bunique, $userid, $bucket) {
    return $bunique->{$userid}{$bucket}
        // 0
}

method total_count($bcount, $bidcache, $userid) {
    my $total = 0;
    for my $name (sort keys $bidcache->{$userid}->%*) {
        next
            if $bidcache->{$userid}{$name}{pseudo};
        $total += $bcount->{$userid}{$name}
            // 0;
    }
    return $total
}

method total_unique($bunique, $bidcache, $userid) {
    my $total = 0;
    for my $name (sort keys $bidcache->{$userid}->%*) {
        next
            if $bidcache->{$userid}{$name}{pseudo};
        $total += $bunique->{$userid}{$name}
            // 0;
    }
    return $total
}

method word_count($dbh, $bidcache, $userid, $bucket, $word) {
    return
        unless defined $bidcache->{$userid}{$bucket};
    my $bucketid = $bidcache->{$userid}{$bucket}{id};
    my $h = $dbh->prepare('SELECT id FROM words WHERE word = ?');
    $h->execute($word);
    my $row = $h->fetchrow_arrayref;
    return
        unless defined $row;
    my $wordid = $row->[0];
    my $h2 = $dbh->prepare('SELECT times FROM matrix WHERE bucketid = ? AND wordid = ?');
    $h2->execute($bucketid, $wordid);
    $row = $h2->fetchrow_arrayref;
    return $row->[0]
        if defined $row;
    return
}

method word_list_for_bucket($dbh, $bucketid, $prefix) {
    $prefix = '' unless defined $prefix;
    $prefix =~ s/\0//g;
    my $rows = $dbh->selectall_arrayref('
        SELECT words.id, words.word, matrix.times
        FROM matrix, words
        WHERE matrix.wordid = words.id
            AND matrix.bucketid = ?
            AND words.word LIKE ?', undef, $bucketid, "$prefix%");
    return $rows->@*
}

# ── word-count cache refresh (mutates hashes passed by reference) ──

method refresh_counts($dbh, $bcount, $bunique, $id_cache, $userid,
                       $updated_bucket, $deleted_bucket) {
    if (defined $updated_bucket
            && defined $id_cache->{$userid}{$updated_bucket}) {
        my $bid = $id_cache->{$userid}{$updated_bucket}{id};
        my $row = $dbh->selectrow_arrayref(
            'SELECT sum(times), count(*) FROM matrix WHERE bucketid = ?',
            undef, $bid);
        $bcount->{$userid}{$updated_bucket} =
            (defined $row->[0] ? $row->[0] : 0);
        $bunique->{$userid}{$updated_bucket} = $row->[1];
        return 1
    }
    if (defined $deleted_bucket) {
        delete $bcount->{$userid}{$deleted_bucket};
        delete $bunique->{$userid}{$deleted_bucket};
        return 1
    }
    delete $bcount->{$userid};
    delete $bunique->{$userid};
    my $sth = $dbh->prepare(
        'SELECT sum(matrix.times), count(matrix.id), buckets.name
         FROM matrix, buckets
         WHERE matrix.bucketid = buckets.id
            AND buckets.userid = ?
         GROUP BY buckets.name');
    $sth->execute($userid);
    for my $b (sort keys $id_cache->{$userid}->%*) {
        $bcount->{$userid}{$b} = 0;
        $bunique->{$userid}{$b} = 0;
    }
    while (my $row = $sth->fetchrow_arrayref) {
        $bcount->{$userid}{$row->[2]} = $row->[0];
        $bunique->{$userid}{$row->[2]} = $row->[1];
    }
    0
}

method raw_word_prefixes($dbh, $bucketid) {
    return $dbh->selectcol_arrayref("
        SELECT words.word FROM matrix, words
        WHERE matrix.wordid = words.id
            AND matrix.bucketid = ?", undef, $bucketid)
}

method word_for_id($dbh, $id) {
    my $row = $dbh->selectrow_arrayref(
        'SELECT word FROM words WHERE id = ?', undef, $id);
    return $row ? $row->[0] : undef
}

1;
