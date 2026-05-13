# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Buckets;

use Object::Pad;
use POPFile::Features;

class Classifier::Buckets;

=head1 NAME

Classifier::Buckets — bucket-name queries and per-bucket parameters

=head1 DESCRIPTION

Query methods for the bucket-name cache maintained by Bayes, plus
per-bucket parameter read/write with an in-memory value cache.

The bucket-name cache (C<$db_bucketid>) is passed as a parameter.
The parameter ID lookup and value cache are owned here.

=cut

field %param_ids;
field %param_cache;

method load_parameter_ids($dbh) {
    my $sth = $dbh->prepare('SELECT name, id FROM bucket_template');
    $sth->execute();
    while (my $row = $sth->fetchrow_arrayref()) {
        $param_ids{$row->[0]} = $row->[1];
    }
}

method reset_parameters() {
    %param_cache = ();
}

# ── name queries (cache passed from Bayes) ──

method names($cache, $userid) {
    my @buckets;
    for my $b (sort keys $cache->{$userid}->%*) {
        push @buckets, $b
            if $cache->{$userid}{$b}{pseudo} == 0;
    }
    return @buckets
}

method pseudo_names($cache, $userid) {
    my @buckets;
    for my $b (sort keys $cache->{$userid}->%*) {
        push @buckets, $b
            if $cache->{$userid}{$b}{pseudo} == 1;
    }
    return @buckets
}

method all_names($cache, $userid) {
    return sort keys $cache->{$userid}->%*
}

method id($cache, $userid, $name) {
    return $cache->{$userid}{$name}{id}
        if defined $cache->{$userid}{$name};
    return
}

method name_for_id($cache, $userid, $id) {
    for my $name (keys $cache->{$userid}->%*) {
        return $name
            if $id == $cache->{$userid}{$name}{id};
    }
    return ''
}

method is_pseudo($cache, $userid, $name) {
    return defined $cache->{$userid}{$name}
        && $cache->{$userid}{$name}{pseudo}
}

method is_real($cache, $userid, $name) {
    return defined $cache->{$userid}{$name}
        && !$cache->{$userid}{$name}{pseudo}
}

# ── parameter access ──

method parameter_get($dbh, $userid, $bucket, $bucketid, $param_name) {
    return $param_cache{$userid}{$bucket}{$param_name}
        if defined $param_cache{$userid}{$bucket}{$param_name};
    my $pid = $param_ids{$param_name};
    return
        unless defined $pid;
    my $row = $dbh->selectrow_arrayref(
        'SELECT bucket_params.val FROM bucket_params
         WHERE bucket_params.bucketid = ? AND bucket_params.btid = ?',
        undef, $bucketid, $pid);
    unless (defined $row) {
        $row = $dbh->selectrow_arrayref(
            'SELECT bucket_template.def FROM bucket_template
             WHERE bucket_template.id = ?',
            undef, $pid);
    }
    my $val = $row ? $row->[0] : undef;
    $param_cache{$userid}{$bucket}{$param_name} = $val
        if defined $val;
    return $val
}

method parameter_set($dbh, $userid, $bucket, $bucketid, $param_name, $value) {
    my $pid = $param_ids{$param_name};
    return
        unless defined $pid;
    $dbh->do(
        'REPLACE INTO bucket_params (bucketid, btid, val) VALUES (?, ?, ?)',
        undef, $bucketid, $pid, $value);
    $param_cache{$userid}{$bucket}{$param_name} = $value
        if defined $param_cache{$userid}{$bucket}{$param_name};
    return 1
}

# ── cache refresh ──

method refresh_id_cache($dbh, $cache, $userid) {
    delete $cache->{$userid};
    my $sth = $dbh->prepare(
        'SELECT name, id, pseudo FROM buckets WHERE userid = ?');
    $sth->execute($userid);
    while (my $row = $sth->fetchrow_arrayref) {
        $cache->{$userid}{$row->[0]}{id} = $row->[1];
        $cache->{$userid}{$row->[0]}{pseudo} = $row->[2];
    }
}

# ── bucket CRUD (DB writes only; Bayes handles cache + history) ──

method name_is_valid($name) {
    return 0
        if $name =~ /[^\p{L}\p{N}\s\-_]/;
    return 0
        if $name =~ m{[/\\]|\.\.};
    return 0
        if $name =~ /^\s|\s$/;
    return 1
}

method create_in_db($dbh, $userid, $name) {
    $dbh->do(
        'INSERT INTO buckets (name, pseudo, userid) VALUES (?, 0, ?)',
        undef, $name, $userid);
}

method delete_from_db($dbh, $userid, $name) {
    $dbh->do(
        'DELETE FROM buckets WHERE buckets.userid = ? AND buckets.name = ? AND buckets.pseudo = 0',
        undef, $userid, $name);
}

method rename_in_db($dbh, $id, $new_name) {
    $dbh->do(
        'UPDATE buckets SET name = ? WHERE id = ?',
        undef, $new_name, $id);
}

method clear_bucket_words($dbh, $bucketid) {
    $dbh->do(
        'DELETE FROM matrix WHERE matrix.bucketid = ?',
        undef, $bucketid);
}

1;
