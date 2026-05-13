# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Magnets;

use Object::Pad;
use POPFile::Features;

class Classifier::Magnets;

=head1 NAME

Classifier::Magnets — magnet CRUD and matching for forced classification

=head1 DESCRIPTION

Manages magnets — rules that force a message into a specific bucket when
a header matches.  Provides CRUD operations and the pure matching logic.

Classification-time orchestration (magnet_match_helper, magnet_match) stays
on Bayes because it ties together magnets, the bucket-name cache, history,
and the classification pipeline.

All dependencies are passed in method signatures.

=cut

=head2 get_types($dbh)

Returns a hash mapping magnet type keys (e.g. 'from') to display names (e.g. 'From').

=cut

method get_types($dbh) {
    my %result;
    my $h = $dbh->prepare(
        'SELECT magnet_types.mtype, magnet_types.header
         FROM magnet_types ORDER BY mtype');
    $h->execute();
    while (my $row = $h->fetchrow_arrayref()) {
        $result{$row->[0]} = $row->[1];
    }
    $h->finish();
    return %result
}

=head2 get_buckets_with($dbh, $userid)

Returns the names of buckets that have at least one magnet defined.

=cut

method get_buckets_with($dbh, $userid) {
    my @result;
    my $sth = $dbh->prepare(
        'SELECT buckets.name FROM buckets, magnets
         WHERE buckets.userid = ?
            AND magnets.id != 0
            AND magnets.bucketid = buckets.id
         GROUP BY buckets.name
         ORDER BY buckets.name');
    $sth->execute($userid);
    while (my $row = $sth->fetchrow_arrayref()) {
        push @result, $row->[0];
    }
    return @result
}

=head2 get_types_in_bucket($dbh, $bucketid)

Returns the magnet types (e.g. 'from', 'to') present in a specific bucket.

=cut

method get_types_in_bucket($dbh, $bucketid) {
    my @result;
    my $h = $dbh->prepare(
        'SELECT magnet_types.mtype FROM magnet_types, magnets, buckets
         WHERE magnet_types.id = magnets.mtid
            AND magnets.bucketid = buckets.id
            AND buckets.id = ?
         GROUP BY magnet_types.mtype
         ORDER BY magnet_types.mtype');
    $h->execute($bucketid);
    while (my $row = $h->fetchrow_arrayref()) {
        push @result, $row->[0];
    }
    $h->finish();
    return @result
}

=head2 get($dbh, $bucketid, $type)

Returns the magnet values of a given type in a bucket.

=cut

method get($dbh, $bucketid, $type) {
    my @result;
    my $h = $dbh->prepare(
        'SELECT magnets.val FROM magnets, magnet_types
         WHERE magnets.bucketid = ?
            AND magnets.id != 0
            AND magnet_types.id = magnets.mtid
            AND magnet_types.mtype = ?
         ORDER BY magnets.val');
    $h->execute($bucketid, $type);
    while (my $row = $h->fetchrow_arrayref()) {
        push @result, $row->[0];
    }
    $h->finish();
    return @result
}

=head2 create($dbh, $bucketid, $type, $text)

Creates a new magnet in a bucket.  Returns 1 on success, 0 otherwise.

=cut

method create($dbh, $bucketid, $type, $text) {
    my $result = $dbh->selectrow_arrayref(
        'SELECT magnet_types.id FROM magnet_types WHERE magnet_types.mtype = ?',
        undef, $type);
    my $mtid = $result ? $result->[0] : undef;
    return 0
        unless defined $mtid;
    $dbh->do(
        'INSERT INTO magnets ( bucketid, mtid, val ) VALUES ( ?, ?, ? )',
        undef, $bucketid, $mtid, $text);
    return 1
}

=head2 delete($dbh, $bucketid, $type, $text, $on_changed)

Removes a magnet.  Calls C<$on_changed->()> after the history foreign-key
references have been zeroed.  Returns 1 if deleted, 0 if not found.

=cut

method delete($dbh, $bucketid, $type, $text, $on_changed) {
    my $result = $dbh->selectrow_arrayref(
        'SELECT magnets.id FROM magnets, magnet_types
         WHERE magnets.mtid = magnet_types.id
            AND magnets.bucketid = ?
            AND magnets.val = ?
            AND magnet_types.mtype = ?',
        undef, $bucketid, $text, $type);
    return 0
        unless defined $result;
    my $magnetid = $result->[0];
    return 0
        unless defined $magnetid;
    $dbh->do('DELETE FROM magnets WHERE id = ?',
        undef, $magnetid);
    $dbh->do(
        'UPDATE history SET magnetid = 0
         WHERE magnetid = ?
            AND userid = ?',
        undef, $magnetid, $dbh->selectrow_array(
            'SELECT userid FROM buckets WHERE id = ?', undef, $bucketid));
    $on_changed->()
        if $on_changed;
    return 1
}

=head2 clear($dbh, $bucketid, $userid)

Removes all magnets from all buckets belonging to C<$userid>.  Also zeroes
history magnet references.  Returns 1.

=cut

method clear($dbh, $userid) {
    my $buckets = $dbh->selectall_arrayref(
        'SELECT id FROM buckets WHERE userid = ?', undef, $userid);
    for my $row ($buckets->@*) {
        my $bucketid = $row->[0];
        $dbh->do('DELETE FROM magnets WHERE magnets.bucketid = ?',
            undef, $bucketid);
        $dbh->do(
            'UPDATE history SET magnetid = 0
             WHERE bucketid = ?
                AND userid = ?',
            undef, $bucketid, $userid);
    }
    return 1
}

=head2 count($dbh, $userid)

Returns the number of magnets defined for C<$userid>.

=cut

method count($dbh, $userid) {
    my $result = $dbh->selectrow_arrayref(
        'SELECT count(*) FROM magnets, buckets
         WHERE buckets.userid = ?
            AND magnets.id != 0
            AND magnets.bucketid = buckets.id',
        undef, $userid);
    return $result ? $result->[0] + 0 : 0
}

=head2 word_match($magnet, $match, $type)

Tests whether C<$match> matches the magnet pattern C<$magnet> given the
match C<$type> ('from', 'to', or 'subject').  Fully self-contained regex
matching — no DB access.

=cut

method word_match($magnet, $match, $type) {
    my $matched = 0;
    if ($type =~ /^(from|to)$/) {
        if ($magnet =~ /[\w]+\@[\w]+/) {
            $matched = 1
                if $match =~ m/(^|[^\w\-])\Q$magnet\E($|[^\w\.])/i;
        } elsif ($magnet =~ /\./) {
            if ($magnet =~ /^[\@\.]/) {
                $matched = 1
                    if $match =~ /\Q$magnet\E($|[^\w\.])/i;
            } else {
                $matched = 1
                    if $match =~ m/[\@\.]\Q$magnet\E($|[^\w\.])/i;
            }
        } else {
            $matched = 1
                if $match =~ m/(^|[^\w])\Q$magnet\E($|[^\w])/i;
        }
    } else {
        $matched = 1
            if $match =~ m/(^|[^\w])\Q$magnet\E($|[^\w])/i;
    }
    return $matched
}

method find_match($dbh, $bucketid, $type, $match) {
    my $sth = $dbh->prepare(
        'SELECT magnets.val, magnets.id
         FROM magnets
         JOIN buckets ON buckets.id = magnets.bucketid
         JOIN magnet_types ON magnet_types.id = magnets.mtid
         WHERE buckets.id = ?
            AND magnets.id != 0
            AND magnet_types.mtype = ?
         ORDER BY magnets.val');
    $sth->execute($bucketid, $type);
    my @magnets;
    while (my $row = $sth->fetchrow_arrayref) {
        push @magnets, [$row->[0], $row->[1]];
    }
    for my $m (@magnets) {
        my ($magnet, $id) = $m->@*;
        if ($self->word_match($magnet, $match, $type)) {
            return $id
        }
    }
    return 0
}

1;
