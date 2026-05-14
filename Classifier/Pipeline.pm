# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Features;

class Classifier::Pipeline;

=head1 NAME

Classifier::Pipeline — ordered classifier chain with priority fallback

=head1 DESCRIPTION

Classifiers register with a numeric priority.  C<classify()> iterates
through them in priority order (lower numbers first) and returns the
first non-C<undef> bucket.  If no classifier matches, returns the
string C<'unclassified'>.

After classification the caller may inspect C<last_classifier()> and
C<last_detail()> to see which classifier decided and, for magnets,
which magnet ID caused the match.

=cut

field @_entries;
field $_last_classifier = '';
field $_last_detail = 0;

=head2 register($classifier, %opts)

Registers a classifier object.  Recognised options:

=over 4

=item priority

Integer sort order (default 0).  Lower numbers run first.

=item name

String key stored in C<last_classifier()> after a match (default: the
classifier's blessed class name without leading C<Classifier::>).

=back

=cut

method register($classifier, %opts) {
    my $name = $opts{name} // do {
        my $n = ref($classifier);
        $n =~ s/^Classifier:://;
        $n
    };
    push @_entries, {
        classifier => $classifier,
        priority   => $opts{priority} // 0,
        name       => $name };
    @_entries = sort { $a->{priority} <=> $b->{priority} } @_entries;
}

=head2 classify($ctx, $session, $file)

Runs each registered classifier in priority order.  The C<\$ctx> object
(typically the Bayes engine) is passed to every classifier so they can
access shared resources (parser, DB handle, session validation).

A classifier must implement:

    \$classifier->classify(\$ctx, \$session, \$file)

Return C<(\$bucket, \$detail)> on match, or C<(undef, undef)> to pass.

Returns the winning bucket name, or C<'unclassified'>.

=cut

method classify($ctx, $session, $file) {
    $_last_classifier = '';
    $_last_detail = 0;
    for my $entry (@_entries) {
        my ($bucket, $detail) = $entry->{classifier}->classify($ctx, $session, $file);
        if (defined $bucket) {
            $_last_classifier = $entry->{name};
            $_last_detail = $detail // 0;
            return $bucket
        }
    }
    return 'unclassified'
}

=head2 last_classifier()

Returns the name of the classifier that matched on the last call to
C<classify()>.

=head2 last_detail()

Returns classifier-specific detail from the last match (e.g. magnet ID).
0 if last classification was not a magnet match.

=cut

method last_classifier() { $_last_classifier }
method last_detail()     { $_last_detail }

1;
