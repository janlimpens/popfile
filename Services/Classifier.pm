# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Services::Classifier;

use Object::Pad;
use locale;

class Services::Classifier :isa(POPFile::Module);

=head1 NAME

Services::Classifier — session-less facade over the Bayes classifier

=head1 DESCRIPTION

C<Services::Classifier> wraps L<Classifier::Bayes> and manages a single
long-lived admin session key so that proxy and UI modules can call
classification, bucket, magnet, and stopword operations without tracking
sessions themselves.

The module acquires an admin session in C<start()> and releases it in
C<stop()>.  Every public method delegates to the underlying Bayes engine,
prepending the held session key.

=head1 LIFECYCLE

=head2 start

Acquires an admin session key from the Bayes classifier.  Returns 1 on
success, 0 if the session key could not be obtained.

=cut

field $classifier :writer(set_classifier) = undef;
field $history :writer(set_history) = undef;
field $session = '';

BUILD {
    $self->set_name('classifier_service');
}

method start() {
    $session = $classifier->get_session_key('admin', '');
    return defined($session) ? 1 : 0;
}

=head2 stop

Releases the admin session key.

=cut

method stop() {
    if ($session ne '') {
        $classifier->release_session_key($session);
        $session = '';
    }
}

=head1 CLASSIFICATION

=head2 classify_message

$self->classify_message($mail, $client, $nosave, $class, $slot, $echo, $crlf);

Classifies the message in C<$mail> and modifies the message stream written to
C<$client> by inserting the C<X-Text-Classification> header.  Delegates to
C<< Classifier::Bayes->classify_and_modify >>.

=cut

method classify_message ($mail, $client, $nosave, $class, $slot, $echo, $crlf) {
    return $classifier->classify_and_modify(
        $session, $mail, $client, $nosave, $class, $slot, $echo, $crlf);
}

=head2 classify

my $bucket = $self->classify($file);

Classifies the message in C<$file> and returns the bucket name.

=cut

method classify ($file)     { $classifier->classify($session, $file) }

=head1 BUCKETS

=head2 get_buckets

Returns a list of all non-pseudo bucket names for the current user.

=head2 get_all_buckets

Returns a list of all bucket names including pseudo-buckets.

=head2 get_pseudo_buckets

Returns a list of pseudo-bucket names only.

=head2 is_bucket

my $bool = $self->is_bucket($name);

Returns true if C<$name> is a real (non-pseudo) bucket.

=head2 is_pseudo_bucket

my $bool = $self->is_pseudo_bucket($name);

Returns true if C<$name> is a pseudo-bucket.

=head2 create_bucket

$self->create_bucket($name);

Creates a new bucket with the given name.

=head2 delete_bucket

$self->delete_bucket($name);

Deletes the named bucket and all its training data.

=head2 rename_bucket

$self->rename_bucket($old_name, $new_name);

Renames a bucket.

=head2 clear_bucket

$self->clear_bucket($name);

Removes all training data from a bucket without deleting it.

=cut

method get_buckets()          { $classifier->get_buckets($session) }
method get_all_buckets()      { $classifier->get_all_buckets($session) }
method get_pseudo_buckets()   { $classifier->get_pseudo_buckets($session) }
method is_bucket ($b)       { $classifier->is_bucket($session, $b) }
method is_pseudo_bucket ($b){ $classifier->is_pseudo_bucket($session, $b) }
method create_bucket ($b)   { $classifier->create_bucket($session, $b) }
method delete_bucket ($b)   { $classifier->delete_bucket($session, $b) }
method rename_bucket ($old, $new) { $classifier->rename_bucket($session, $old, $new) }
method clear_bucket ($b)    { $classifier->clear_bucket($session, $b) }

=head1 BUCKET STATISTICS

=head2 get_bucket_word_count

my $n = $self->get_bucket_word_count($bucket);

Returns the total word count (with repetitions) for C<$bucket>.

=head2 get_bucket_unique_count

my $n = $self->get_bucket_unique_count($bucket);

Returns the number of distinct words in C<$bucket>.

=head2 get_word_count

Returns the total word count across all buckets.

=head2 get_unique_word_count

Returns the number of distinct words across all buckets.

=head2 get_bucket_word_list

my @words = $self->get_bucket_word_list($bucket, $prefix);

Returns words in C<$bucket> that start with C<$prefix>.

=head2 get_bucket_word_prefixes

my @prefixes = $self->get_bucket_word_prefixes($bucket);

Returns all word prefixes present in C<$bucket>.

=head2 get_count_for_word

my $n = $self->get_count_for_word($bucket, $word);

Returns the training count for C<$word> in C<$bucket>.

=cut

method get_bucket_word_count ($b)       { $classifier->get_bucket_word_count($session, $b) }
method get_bucket_unique_count ($b)     { $classifier->get_bucket_unique_count($session, $b) }
method get_word_count()                   { $classifier->get_word_count($session) }
method get_unique_word_count()            { $classifier->get_unique_word_count($session) }
method get_bucket_word_list ($b, $pfx)  { $classifier->get_bucket_word_list($session, $b, $pfx) }
method get_bucket_word_prefixes ($b)    { $classifier->get_bucket_word_prefixes($session, $b) }
method get_count_for_word ($b, $w)      { $classifier->get_count_for_word($session, $b, $w) }

=head1 BUCKET PARAMETERS AND COLOR

=head2 get_bucket_parameter

my $val = $self->get_bucket_parameter($bucket, $param);

Returns the value of a per-bucket parameter.

=head2 set_bucket_parameter

$self->set_bucket_parameter($bucket, $param, $value);

Sets a per-bucket parameter.

=head2 get_bucket_color

my $color = $self->get_bucket_color($bucket);

Returns the display color for C<$bucket>.

=head2 set_bucket_color

$self->set_bucket_color($bucket, $color);

Sets the display color for C<$bucket>.

=head2 get_color

my $color = $self->get_color($word);

Returns the color of the bucket that would claim C<$word>.

=head2 get_word_colors

my %colors = $self->get_word_colors(@words);

Returns a hash mapping each word to its bucket color.

=head2 mangle_word

my $mangled = $self->mangle_word($word);

Normalises C<$word> through the word-mangler (stemming, lowercasing, etc.).

=head2 add_message_to_bucket

$self->add_message_to_bucket($bucket, $file);

Trains the message in C<$file> into C<$bucket>.

=head2 add_messages_to_bucket

$self->add_messages_to_bucket($bucket, @files);

Trains multiple message files into C<$bucket>.

=head2 remove_message_from_bucket

$self->remove_message_from_bucket($bucket, $file);

Removes the training contribution of C<$file> from C<$bucket>.

=cut

method get_bucket_parameter ($b, $p)        { $classifier->get_bucket_parameter($session, $b, $p) }
method set_bucket_parameter ($b, $p, $v)    { $classifier->set_bucket_parameter($session, $b, $p, $v) }
method get_bucket_color ($b)                { $classifier->get_bucket_color($session, $b) }
method set_bucket_color ($b, $c)            { $classifier->set_bucket_color($session, $b, $c) }
method get_color ($w)                       { $classifier->get_color($session, $w) }
method get_word_colors (@words)             { $classifier->get_word_colors($session, @words) }
method mangle_word ($w)                     { $classifier->parser()->mangle()->mangle($w) }
method add_message_to_bucket ($b, $file)    { $classifier->add_message_to_bucket($session, $b, $file) }
method add_messages_to_bucket ($b, @files)  { $classifier->add_messages_to_bucket($session, $b, @files) }
method remove_message_from_bucket ($b, $f)  { $classifier->remove_message_from_bucket($session, $b, $f) }

=head1 MAGNETS

=head2 get_buckets_with_magnets

Returns a list of bucket names that have at least one magnet defined.

=head2 get_magnet_types

Returns a list of all magnet type names (e.g. C<from>, C<to>, C<subject>).

=head2 get_magnet_types_in_bucket

my @types = $self->get_magnet_types_in_bucket($bucket);

Returns the magnet types that have entries in C<$bucket>.

=head2 get_magnets

my @magnets = $self->get_magnets($bucket, $type);

Returns all magnet strings of C<$type> in C<$bucket>.

=head2 create_magnet

$self->create_magnet($bucket, $type, $text);

Creates a new magnet matching C<$text> of C<$type> pointing to C<$bucket>.

=head2 delete_magnet

$self->delete_magnet($bucket, $type, $text);

Deletes the magnet matching C<$text> of C<$type> in C<$bucket>.

=head2 clear_magnets

Deletes all magnets for all buckets.

=head2 magnet_count

Returns the total number of magnets defined.

=cut

method get_buckets_with_magnets()             { $classifier->get_buckets_with_magnets($session) }
method get_magnet_types()                     { $classifier->get_magnet_types($session) }
method get_magnet_types_in_bucket ($b)      { $classifier->get_magnet_types_in_bucket($session, $b) }
method get_magnets ($b, $t)                 { $classifier->get_magnets($session, $b, $t) }
method create_magnet ($b, $t, $text)        { $classifier->create_magnet($session, $b, $t, $text) }
method delete_magnet ($b, $t, $text)        { $classifier->delete_magnet($session, $b, $t, $text) }
method clear_magnets()                        { $classifier->clear_magnets($session) }
method magnet_count()                         { $classifier->magnet_count($session) }

=head1 STOPWORDS

=head2 get_stopword_list

Returns a list of all stopwords.

=head2 add_stopword

$self->add_stopword($word);

Adds C<$word> to the stopword list.

=head2 remove_stopword

$self->remove_stopword($word);

Removes C<$word> from the stopword list.

=cut

method get_words_for_bucket ($bucket, %opts) { $classifier->get_words_for_bucket($session, $bucket, %opts) }
method remove_word_from_bucket ($bucket, $word) { $classifier->remove_word_from_bucket($session, $bucket, $word) }
method move_word_between_buckets ($from, $to, $word) { $classifier->move_word_between_buckets($session, $from, $to, $word) }

method get_stopword_list() { $classifier->get_stopword_list($session) }
method add_stopword ($w) { $classifier->add_stopword($session, $w) }
method remove_stopword ($w) { $classifier->remove_stopword($session, $w) }
method get_stopword_candidates ($ratio, $limit = 50) { $classifier->get_stopword_candidates($session, $ratio, $limit) }
method search_words_cross_bucket ($prefix, %opts) { $classifier->search_words_cross_bucket($session, $prefix, %opts) }

=head1 ACCESSORS

=head2 session

Returns the current admin session key.

=head2 bayes

Returns the underlying L<Classifier::Bayes> object.

=head2 history_obj

Returns the injected L<POPFile::History> object.

=cut

method session()      { $session }
method bayes()        { $classifier }
method history_obj()  { $history }


1;
