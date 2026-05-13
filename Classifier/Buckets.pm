# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Buckets;

use Object::Pad;
use POPFile::Features;

class Classifier::Buckets;

=head1 NAME

Classifier::Buckets — bucket-name queries backed by Bayes' in-memory caches

=head1 DESCRIPTION

Stateless query methods for the bucket-name cache maintained by Bayes.
All cache hashes are passed as parameters.

The cache is still populated by Bayes' C<db_update_cache>.  In a future step
the cache fields may be moved here.

=cut

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

1;
