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

field $id :param = undef;
field $name :param :reader;
field $color :param :reader :writer = 'black';
field $count :param :reader :writer = 0;
field $pseudo :param :reader = 0;
field $prior :reader :writer = 0;

=head2 new_from_db

    my $bucket = Classifier::Bucket->new_from_db($row);

Constructs a new instance from a hash-ref database row.  Expects the keys
C<id>, C<name>, C<color>, and C<count>.

=cut

method new_from_db ($row) {
    return Classifier::Bucket->new(
        id      => $row->{id},
        name    => $row->{name},
        color   => $row->{color},
        count   => $row->{count},
        pseudo  => $row->{pseudo} // 0,
    )
}

1;
