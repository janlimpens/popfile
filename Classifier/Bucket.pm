# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Bucket;

=head1 NAME

Classifier::Bucket - value object representing a POPFile classification bucket

=head1 DESCRIPTION

A lightweight value object that holds the name, colour, word count, and
Naive Bayes prior probability for a single bucket.  Instances are typically
created by L</new_from_db> from a database row and then passed around inside
L<Classifier::Bayes> during classification.

=cut

use Object::Pad;

class Classifier::Bucket;

field %props;
field $prior = 0;

=head2 new_from_db

    my $bucket = Classifier::Bucket->new_from_db($row);

Constructs a new instance from a hash-ref database row.  Expects the keys
C<name>, C<color>, and C<count>.

=cut

method new_from_db ($row) {
    my $b = Classifier::Bucket->new();
    $b->set_property('name', $row->{name});
    $b->set_property('color', $row->{color});
    $b->set_property('count', $row->{count});
    return $b
}

=head2 get_property

    my $val = $bucket->get_property($key);

Returns the value stored under C<$key>, or C<undef> if not set.

=cut

method get_property ($key) {
    return $props{$key}
}

=head2 set_property

    $bucket->set_property($key, $value);

Stores C<$value> under C<$key>.  Returns C<$self> for chaining.

=cut

method set_property ($key, $value) {
    $props{$key} = $value;
    return $self
}

=head2 prior

    my $p = $bucket->prior();

Returns the bucket's Naive Bayes prior probability.

=cut

method prior() { return $prior }

=head2 set_prior

    $bucket->set_prior($probability);

Sets the bucket's prior probability.

=cut

method set_prior ($v) { $prior = $v }

1;
