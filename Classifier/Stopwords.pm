# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Stopwords;

use Object::Pad;
use POPFile::Features;

class Classifier::Stopwords;

=head1 NAME

Classifier::Stopwords — stopword detection and candidate discovery

=head1 DESCRIPTION

Provides two views of stopwords:
=over
=item * C<get_list> — language-specific stopwords from the WordMangle module
=item * C<get_candidates> — low-discrimination words determined from corpus
statistics, useful for building the language-specific list
=back

All dependencies are passed in method signatures rather than stored as fields.

=cut

=head2 get_list($mangle, $userid)

Returns the complete list of language-specific stopwords from the word
mangler.  C<$userid> is accepted for API consistency but ignored for
this call.

=cut

method get_list($mangle, $userid) {
    return $mangle->stopwords();
}

=head2 get_candidates($dbh, $userid, $ratio = 2.0, $limit = 50)

Returns words that appear in every non-pseudo bucket with a max-to-min
per-bucket frequency ratio below C<$ratio>.  These words carry little
discriminative power.  C<$limit> caps the result set (default 50).

Each entry is a hashref with C<word>, C<min_count>, C<max_count>, and C<ratio>.

=cut

method get_candidates($dbh, $userid, $ratio = 2.0, $limit = 50) {
    my $bucket_count_row = $dbh->selectrow_arrayref(
        'SELECT COUNT(*) FROM buckets WHERE userid = ? AND pseudo = 0',
        undef, $userid);
    my $n_buckets = $bucket_count_row ? $bucket_count_row->[0] : 0;
    return ()
        if $n_buckets < 2;
    my $sth = $dbh->prepare(
        'SELECT w.word,
                MIN(m.times) AS min_count,
                MAX(m.times) AS max_count,
                CAST(MAX(m.times) AS FLOAT) / MIN(m.times) AS ratio
         FROM words w
         JOIN matrix m ON m.wordid = w.id
         JOIN buckets b ON b.id = m.bucketid
         WHERE b.userid = ?
           AND b.pseudo = 0
         GROUP BY w.id, w.word
         HAVING COUNT(DISTINCT m.bucketid) = ?
            AND MIN(m.times) > 0
            AND CAST(MAX(m.times) AS FLOAT) / MIN(m.times) < ?
         ORDER BY CAST(MAX(m.times) AS FLOAT) / MIN(m.times) ASC
         LIMIT ?');
    $sth->execute($userid, $n_buckets, $ratio, $limit);
    my @candidates;
    while (my $row = $sth->fetchrow_hashref()) {
        push @candidates, {
            word => $row->{word},
            min_count => $row->{min_count} + 0,
            max_count => $row->{max_count} + 0,
            ratio => $row->{ratio} + 0,
        };
    }
    return @candidates
}

1;
