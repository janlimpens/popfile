# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Classifier::Bayes;

use Object::Pad;
use feature qw(state try);
no warnings 'experimental::try';
use locale;
use Classifier::Bucket;
use Classifier::Buckets;
use Classifier::Corpus;
use Classifier::MailParse;
use Classifier::Sessions;
use Classifier::Magnets;
use Classifier::Stopwords;
use Classifier::Schema;
use Classifier::Pipeline;
use POPFile::Role::DBConnect;
use POPFile::Role::SQL;
use POPFile::Role::Config;
use IO::Handle;
use DBI;
use List::Util qw(max min);
use MIME::Base64;
use File::Copy;

# This is used to get the hostname of the current machine
# in a cross platform way
use Sys::Hostname;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

# Korean characters definition
my $ksc5601_sym = '(?:[\xA1-\xAC][\xA1-\xFE])';
my $ksc5601_han = '(?:[\xB0-\xC8][\xA1-\xFE])';
my $ksc5601_hanja = '(?:[\xCA-\xFD][\xA1-\xFE])';
my $ksc5601 = "(?:$ksc5601_sym|$ksc5601_han|$ksc5601_hanja)";

my $eksc = "(?:$ksc5601|[\x81-\xC6][\x41-\xFE])"; #extended ksc

class Classifier::Bayes
    :isa(POPFile::Module)
    :does(POPFile::Role::DBConnect)
    :does(POPFile::Role::SQL)
    :does(POPFile::Role::Config)
    :does(POPFile::Role::Logging);


=head1 NAME

Classifier::Bayes - Naive Bayes email classifier

=head1 DESCRIPTION

Implements a Naive Bayes classifier for email messages.  Manages per-user
buckets, a word-frequency corpus stored in SQLite (or MySQL/PostgreSQL),
and a session-key API that proxies and the UI use to perform classification,
training, and corpus management.

The main entry points are C<classify_and_modify> (classify a message and
inject the C<X-Text-Classification> header) and the bucket/word management
methods (C<create_bucket>, C<add_message_to_bucket>, etc.).

=cut

field $hostname = '';

field $history = 0;

# Cached prepared SQL statements (set in db_connect, released in db_disconnect)
field $db_delete_zero_words = 0;

# Caches the name of each bucket — subkeys: id, pseudo
field $db_bucketid = {};

# Per-userid word-count caches
field $db_bucketcount = {};
field $db_bucketunique = {};

field $parser :reader = Classifier::MailParse->new();

# Precomputed per-bucket log-probabilities
field $bucket_start = {};

field $not_likely = {};

field $pipeline :reader = undef;
field $sessions :reader = undef;
field $magnets :reader = undef;
field $buckets :reader = undef;
field $corpus :reader = undef;
field $stopwords :reader = undef;
field $schema :reader = undef;

field $db_name :reader = '';

BUILD {
    $self->set_name('bayes');
    $schema = Classifier::Schema->new(config => $self);
    $pipeline = Classifier::Pipeline->new();
}

=head2 initialize

Called to set up the Bayes module's parameters

=cut

method initialize() {
    $hostname = hostname;
    $self->mq_register('COMIT', $self);
    $self->mq_register('RELSE', $self);

    return 1;
}

=head2 deliver

Called by the message queue to deliver a message

There is no return value from this method

=cut

method deliver ($type, @message) {
    return do {
        if ($type eq 'COMIT') {
            $self->classified($message[0], $message[2]);
        } elsif ($type eq 'RELSE') {
            $sessions->remove_session($message[0]);
        }
    }
}

=head2 start

Called to start the Bayes module running

=cut

method start() {
    # In Japanese or Korean or Chinese mode, explicitly set LC_COLLATE and
    # LC_CTYPE to C.
    #
    # This is to avoid Perl crash on Windows because default
    # LC_COLLATE of Japanese Win is Japanese_Japan.932(Shift_JIS),
    # which is different from the charset POPFile uses for Japanese
    # characters(EUC-JP).
    #
    # And on some configuration (e.g. Japanese Mac OS X), LC_CTYPE is set to
    # UTF-8 but POPFile uses EUC-JP encoding for Japanese. In this situation
    # lc() does not work correctly.
    my $language = $self->config->get('locale');

    if ($language =~ /^(Nihongo$|Korean$|Chinese)/) {
        use POSIX qw(locale_h);
        setlocale(LC_COLLATE, 'C');
        setlocale(LC_CTYPE,   'C');
    }

    # Pass in the current interface language for language specific parsing
    $parser->set_lang($language);
    $parser->mangle()->set_ui_language($language);
    $buckets = Classifier::Buckets->new();
    return 0
        unless $self->db_connect();
    $sessions = Classifier::Sessions->new();
    $magnets = Classifier::Magnets->new();
    $pipeline->register($magnets, priority => 0, name => 'magnets')
        if ($self->config->get('bayes_magnets_enabled'));
    $corpus = Classifier::Corpus->new();
    $stopwords = Classifier::Stopwords->new();

    if ($language eq 'Nihongo') {
        # Setup Nihongo (Japanese) parser.
        my $nihongo_parser = ($self->config->get('nihongo_parser'));

        $nihongo_parser = $parser->setup_nihongo_parser($nihongo_parser);

        $self->log_msg(DEBUG => "Use Nihongo (Japanese) parser : $nihongo_parser");
    }

    return 1;
}

=head2 stop

Called when POPFile is terminating

=cut

method stop() {
    $self->db_disconnect();
    $db_bucketid = {};
    $buckets->reset_parameters();
    $db_bucketcount = {};
    $db_bucketunique = {};
    $parser = Classifier::MailParse->new();
}

=head2 classified

Called to inform the module about a classification event

There is no return value from this method

=cut

method classified ($session, $class) {
    return $self->set_bucket_parameter(
        $session,
        $class,
        'count',
        $self->get_bucket_parameter($session, $class, 'count') + 1)
}

=head2 reclassified

Called to inform the module about a reclassification from one bucket
to another


There is no return value from this method

C<session> Valid API session
C<bucket> The old bucket name
C<newbucket> The new bucket name
C<undo> 1 if this is an undo operation

=cut

method reclassified ($session, $bucket, $newbucket, $undo) {
    $self->log_msg(WARN => "Reclassification from $bucket to $newbucket");

    my $c = $undo
        ? -1
        : 1;

    if ($bucket ne $newbucket) {
        my $count = $self->get_bucket_parameter($session, $newbucket, 'count');
        my $newcount = $count + $c;
        $newcount = 0
            if $newcount < 0;
        $self->set_bucket_parameter($session, $newbucket, 'count', $newcount);
        $count = $self->get_bucket_parameter($session, $bucket, 'count');
        $newcount = $count - $c;
        $newcount = 0
            if $newcount < 0;
        $self->set_bucket_parameter($session, $bucket, 'count', $newcount);
        my $fncount = $self->get_bucket_parameter($session, $newbucket, 'fncount');
        my $newfncount = $fncount + $c;
        $newfncount = 0
            if $newfncount < 0;
        $self->set_bucket_parameter($session, $newbucket, 'fncount', $newfncount);
        my $fpcount = $self->get_bucket_parameter($session, $bucket, 'fpcount');
        my $newfpcount = $fpcount + $c;
        $newfpcount = 0
            if $newfpcount < 0;
        $self->set_bucket_parameter($session, $bucket, 'fpcount', $newfpcount);
    }
}

=head2 get_color

Retrieves the color for a specific word, color is the most likely bucket

C<$session> Session key returned by get_session_key
C<$word> Word to get the color of

=cut

method get_color ($session, $word) {
    my $max = -10000;
    my $color = 'black';

    for my $bucket ($self->get_buckets($session)) {
        my $prob = $self->get_value($session, $bucket, $word);
        if ($prob != 0)  {
        if ($prob > $max)  {
                $max = $prob;
                $color = $self->get_bucket_parameter($session, $bucket, 'color');
            }
        }
    }

    return $color;
}

=head2 get_word_colors

    my %colors = $self->get_word_colors($session, @words);

Returns a hash mapping each word in C<@words> to the display color of the
bucket that has the highest probability for that word.  Words not seen in
any bucket are omitted from the result.

=cut

method get_word_colors ($session, @words) {
    my $userid = $self->valid_session_key($session);
    return () unless defined $userid && @words;

    my $uid_buckets = $db_bucketid->{$userid} // {};
    my %id_to_name = map { $db_bucketid->{$userid}{$_}{id} => $_ }
                     keys $uid_buckets->%*;

    my %best_prob;
    my %best_name;
    my $chunk_size = 500;
    while (@words) {
        my @chunk = splice @words, 0, $chunk_size;
        my $word_expr = $self->qb()->compare('w.word', \@chunk);
        my $sth = $self->validate_sql_prepare_and_execute(
            "SELECT w.word, m.bucketid, m.times
             FROM words w
             JOIN matrix m ON m.wordid = w.id
             JOIN buckets b ON b.id = m.bucketid
                            AND b.userid = ?
                            AND b.pseudo = 0
             WHERE " . $word_expr->as_sql(),
            $userid, $word_expr->params());
        next unless defined $sth;
        while (my ($word, $bucketid, $times) = $sth->fetchrow_array()) {
            my $name = $id_to_name{$bucketid} // next;
            my $total = $self->get_bucket_word_count($session, $name);
            next unless $total;
            my $prob = $times / $total;
            if (!exists $best_prob{$word} || $prob > $best_prob{$word}) {
                $best_prob{$word} = $prob;
                $best_name{$word} = $name;
            }
        }
    }

    my %colors;
    for my $word (keys %best_name) {
        $colors{$word} = $self->get_bucket_color($session, $best_name{$word});
    }
    return %colors
}

=head2 get_value_

Returns the value for a specific word in a bucket.  The word is
converted to the log value of the probability before return to get
the raw value just hit the hash directly or call get_base_value_

=cut

method get_value ($session, $bucket, $word) {
    my $value = $self->db_get_word_count($session, $bucket, $word);
    if (defined($value) && ($value > 0)) {
        # Profiling notes:
        #
        # I tried caching the log of the total value and then doing
        # log($value) - $cached and this turned out to be
        # much slower than this single log with a division in it
        return log($value / $self->get_bucket_word_count($session, $bucket));
    } else {
        return 0;
    }
}

=head2 get_base_value

    my $n = $self->get_base_value($session, $bucket, $word);

Returns the raw training count for C<$word> in C<$bucket>, or 0 if the word
is not present.  Unlike C<get_value>, no logarithm is applied.

=cut

method get_base_value ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return 0
        unless defined $userid;
    return $corpus->word_count_get($self->get_handle(),
        $db_bucketid->{$userid}{$bucket}{id}, $word) // 0
}

=head2 update_constants

Updates not_likely and bucket_start

=cut

method update_constants ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my $wc = $self->get_word_count($session);
    $not_likely->{$userid} = {};

    return unless $wc > 0;

    for my $bucket ($self->get_buckets($session)) {
        my $total = $self->get_bucket_word_count($session, $bucket);
        if ($total != 0) {
            $bucket_start->{$userid}{$bucket} = log($total / $wc);
            $not_likely->{$userid}{$bucket} = -log(10 * $total);
        } else {
            $bucket_start->{$userid}{$bucket} = 0;
            $not_likely->{$userid}{$bucket} = 0;
        }
    }
}

=head2 db_connect

Connects to the POPFile database and returns 1 if successful.

=cut

method db_connect() {
    my $db = $self->get_handle();
    return 0
        unless defined $db;
    return 0
        unless $schema->setup($db);
    $db_delete_zero_words = $db->prepare($self->normalize_sql(
        'DELETE FROM matrix
         WHERE (matrix.times <= 0 OR matrix.times IS NULL)
            AND matrix.bucketid = ?'));
    $buckets->load_parameter_ids($db);
    $pipeline->register($self, priority => 1, name => 'bayes');
    return 1
}


=head2 db_disconnect

Disconnect from the POPFile database

=cut

method db_disconnect() {
    return
        unless ref $db_delete_zero_words;
    $db_delete_zero_words->finish();
    undef $db_delete_zero_words;
}

=head2 db_update_cache

Updates our local cache of user and bucket ids.

C<$session> Must be a valid session
C<$updated_bucket> Bucket to update cache
C<$deleted_bucket> Bucket to delete cache
                   If none of them is specified, update whole cache.

=cut

method db_update_cache ($session, $updated_bucket = undef, $deleted_bucket = undef) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    $buckets->refresh_id_cache($self->get_handle(), $db_bucketid, $userid);
    $corpus->refresh_counts($self->get_handle(), $db_bucketcount, $db_bucketunique,
        $db_bucketid, $userid, $updated_bucket, $deleted_bucket);
    $self->update_constants($session);
}

=head2 db_get_word_count

Return the 'count' value for a word in a bucket.  If the word is not
found in that bucket then returns undef.

C<$session> Valid session ID from get_session_key
C<$bucket> bucket word is in
C<$word> word to lookup

=cut

=head2 write_line

Writes a line to a file and parses it unless the classification is
already known

C<$file> File handle for file to write line to
C<$line> The line to write
C<$class> (optional) The current classification

=cut

method write_line ($file, $line, $class) {
    if (defined($file) && (ref $file eq 'GLOB')) {
    if (defined(fileno $file)) {
            print $file $line;
        } else {
            my ($package, $filename, $line, $subroutine) = caller;
            $self->log_msg(WARN => "Tried to write to a closed file. Called from $package line $line");
        }
    }

    if ($class eq '') {
        $parser->parse_line($line);
    }
}

=head2 add_words_to_bucket

Takes words previously parsed by the mail parser and adds/subtracts
them to/from a bucket, this is a helper used by
add_messages_to_bucket, remove_message_from_bucket

C<$session> Valid session from get_session_key
C<$bucket> Bucket to add to
C<$subtract> Set to -1 means subtract the words, set to 1 means add

=cut

method add_words_to_bucket ($session, $bucket, $subtract) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    unless (defined $bucketid) {
        $self->log_msg(WARN => "add_words_to_bucket: bucketid undef for user=$userid bucket=$bucket; skipping");
        return
    }
    unless (keys $parser->words()->%*) {
        $self->log_msg(INFO => "add_words_to_bucket: no words parsed for user=$userid bucket=$bucket; skipping");
        return
    }
    $self->log_msg(5, "add_words_to_bucket: user=$userid bucket=$bucket bucketid=$bucketid words=" . scalar(keys $parser->words()->%*));
    $corpus->add_words($self->get_handle(), $bucketid, $subtract, $parser->words()->%*)
}

=head2 echo_to_dot

$mail The stream (created with IO::) to send the message to (the
remote mail server)
$client (optional) The local mail client (created with IO::) that
needs the response
$file (optional) A file to print the response to, caller specifies
open style
$before (optional) String to send to client before the dot is sent

echo all information from the $mail server until a single line with
a . is seen

NOTE Also echoes the line with . to $client but not to $file

Returns 1 if there was a . or 0 if reached EOF before we hit the .

=cut

method echo_to_dot ($mail, $client, $file, $before) {
    my $hit_dot = 0;

    my $isopen = open FILE, "$file" if (defined($file));
    binmode FILE if ($isopen);

    while (my $line = $self->slurp($mail)) {
        # Check for an abort
        last if ($self->alive() == 0);

        # The termination has to be a single line with exactly a dot
        # on it and nothing else other than line termination
        # characters.  This is vital so that we do not mistake a line
        # beginning with . as the end of the block
        if ($line =~ /^\.(\r\n|\r|\n)$/) {
            $hit_dot = 1;

            if (defined($before) && ($before ne '')) {
                print $client $before if (defined($client));
                print FILE $before if (defined($isopen));
            }

            # Note that there is no print FILE here.  This is correct
            # because we do no want the network terminator . to appear
            # in the file version of any message
            print $client $line if (defined($client));
            last;
        }

        print $client $line if (defined($client));
        print FILE $line if (defined($isopen));
    }

    close FILE
        if ($isopen);

    return $hit_dot;
}

=head2 substr_euc

"substr" function which supports EUC Japanese charset

C<$pos> Start position
C<$len> Word length

=cut

sub substr_euc($str, $pos, $len) {
    my $result_str;
    my $char;
    my $count = 0;
    if (!$pos) {
        $pos = 0;
    }
    if (!$len) {
        $len = length($str);
    }

    for ($pos = 0; $count < $len; $pos++) {
        $char = substr($str, $pos, 1);
        if ($char =~ /[\x80-\xff]/) {
        $char = substr($str, $pos++, 2);
        }
        $result_str .= $char;
        $count++;
    }

    return $result_str;
}

=head2 valid_session_key

Returns undef is the session key is not valid, or returns the user
ID associated with the session key which can be used in database
accesses

C<$session> Session key returned by call to get_session_key

=cut

method valid_session_key($session) {
    return $sessions->validate_session($session)
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
=head2 get_session_key


Returns a string based session key if the username and password
match, or undef if not

C<$user> The name of an existing user
C<$pwd> The user's password

=cut

method get_session_key ($user, $pwd) {
    my ($session, $userid) = $sessions->create_session($self->get_handle(), $user, $pwd);
    return
        unless defined $session;
    $self->db_update_cache($session);
    return $session
}

=head2 release_session_key


Releases and invalidates the session key

C<$session> A session key previously returned by get_session_key

=cut

method release_session_key ($session) {
    $self->mq_post("RELSE", $session);
}


=head2 classify


Splits the mail message into valid words, then runs the Bayes
algorithm to figure out which bucket it belongs in.  Returns the
bucket name

C<$session> A valid session key returned by a call to get_session_key
$file The name of the file containing the text to classify (or undef
to use the data already in the parser)
$matrix (optional) Reference to a hash that will be filled with the
word matrix used in classification
$idmap (optional) Reference to a hash that will map word ids in the
$matrix to actual words

=cut

method classify ($ctx, $session, $file, $matrix = undef, $idmap = undef) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    # Unclassified cutoff: top probability must be this many times greater
    # than the second probability (default 100×)
    my $unclassified = log($self->config()->get('unclassified_weight'));

    if (defined($file)) {
        return if (!-f $file);

        $parser->parse_file($file,
            $self->config->get('message_cutoff'));
    }

    my @buckets = $self->get_buckets($session);

    return "unclassified"
        unless @buckets;

    return "unclassified"
        unless $not_likely->{$userid}->%*;

    # The score hash will contain the likelihood that the given
    # message is in each bucket, the buckets are the keys for score
    # Set up the initial score as P(bucket)
    my %score;
    my %matchcount;

    # Build up a list of the buckets that are OK to use for
    # classification (i.e.  that have at least one word in them).
    my @ok_buckets;
    for my $bucket (@buckets) {
        if (defined $bucket_start->{$userid}{$bucket} && $bucket_start->{$userid}{$bucket} != 0) {
            $score{$bucket} = $bucket_start->{$userid}{$bucket};
            $matchcount{$bucket} = 0;
            push @ok_buckets, ($bucket);
        }
    }
    @buckets = @ok_buckets;

    return "unclassified"
        if (@buckets < 2);

    # Classification against the database works in a sequence of steps
    # to get the fastest time possible.  The steps are as follows:
    #
    # 1. Convert the list of words returned by the parser into a list
    #    of unique word ids that can be used in the database.  This
    #    requires a select against the database to get the word ids
    #    (and associated words) which is then converted into two
    #    things: @id_list which is just the sorted list of word ids
    #    and %idmap which maps a word to its id.
    #
    # 2. Then run a second select that get the triplet (count, id,
    #    bucket) for each word id and each bucket.  The triplet
    #    contains the word count from the database for each bucket and
    #    each id, where there is an entry. That data gets loaded into
    #    the sparse matrix %matrix.
    #
    # 3. Do the normal classification loop as before running against
    # the @id_list for the words and for each bucket.  If there's an
    # entry in %matrix for the id/bucket combination then calculate
    # the probability, otherwise use the not_likely probability.
    #
    # NOTE.  Since there is a single not_likely probability we do not
    # worry about the fact that the select in 1 might return a shorter
    # list of words than was found in the message (because some words
    # are not in the database) since the missing words will be the
    # same for all buckets and hence constitute a fixed scaling factor
    # on all the buckets which is irrelevant in deciding which the
    # winning bucket is.
    my @words = sort keys $parser->words()->%*;

    my ($id_list_ref, $idmap_ref) = $corpus->resolve_word_ids(
        $self->get_handle(), \@words);
    if (defined $idmap) {
        %$idmap = (%$idmap, %$idmap_ref);
    } else {
        $idmap = $idmap_ref;
    }
    my $matrix_ref = $corpus->fetch_matrix(
        $self->get_handle(), $id_list_ref, $userid);
    if (defined $matrix) {
        %$matrix = (%$matrix, %$matrix_ref);
    } else {
        $matrix = $matrix_ref;
    }
    my @id_list = $id_list_ref->@*;
    my $not_likely_for_bucket = $not_likely->{$userid};
    my $stopword_ratio = ($self->config->get('stopword_ratio')) + 0;

    for my $id (@id_list) {
        if ($stopword_ratio > 0 && @buckets > 1) {
            my $min_c = 'inf';
            my $max_c = 0;
            my $all_present = 1;
            for my $bucket (@buckets) {
                my $c = $$matrix{$id}{$bucket} // 0;
                if ($c == 0) { $all_present = 0; last }
                $min_c = $c if $c < $min_c;
                $max_c = $c if $c > $max_c;
            }
            next()
                if $all_present && $max_c / $min_c < $stopword_ratio;
        }
        my $count = $parser->words()->{$$idmap{$id}};

        for my $bucket (@buckets) {
            my $probability = $not_likely_for_bucket->{$bucket};

            if (defined($$matrix{$id}{$bucket}) && ($$matrix{$id}{$bucket} > 0)) {
                $probability = log($$matrix{$id}{$bucket} / $db_bucketcount->{$userid}{$bucket});
                $matchcount{$bucket} += $count;
            }

            $score{$bucket} += ($probability * $count);
        }
    }

    # Now sort the scores to find the highest and return that bucket
    # as the classification
    my @ranking = sort {$score{$b} <=> $score{$a}} keys %score;

    my $base_score = defined $ranking[0] ? $score{$ranking[0]} : 0;
    my $total = 0;

    # If the first and second bucket are too close in their
    # probabilities, call the message unclassified.  Also if there are
    # fewer than 2 buckets.
    my $class = 'unclassified';
    if (@buckets > 1 && $score{$ranking[0]} > ($score{$ranking[1]} + $unclassified)) {
        $class = $ranking[0];
    }

    # Compute the total of all the scores to generate the normalized
    # scores and probability estimate.  $total is always 1 after the
    # first loop iteration, so any additional term less than 2 ** -54
    # is insignificant, and need not be computed.
    my $ln2p_54 = -54 * log(2);

    my %raw_score;
    for my $b (@ranking) {
        $raw_score{$b} = $score{$b};
        $score{$b} -= $base_score;

        $total += exp($score{$b}) if ($score{$b} > $ln2p_54);
    }

    return $class;
}

=head2 classify_and_modify

This method reads an email terminated by . on a line by itself (or
the end of stream) from a handle and creates an entry in the
history, outputting the same email on another handle with the
appropriate header modifications and insertions


Returns a classification if it worked and the slot ID of the history
item related to this classification

IMPORTANT NOTE: $mail and $client should be binmode

C<$session> - A valid session key returned by a call to get_session_key
C<$mail> - an open stream to read the email from
C<$client> - an open stream to write the modified email to
C<$nosave> - set to 1 indicates that this should not save to history
C<$class> - if we already know the classification
C<$slot> - Must be defined if $class is set
C<$echo> - 1 to echo to the client, 0 to supress, defaults to 1
C<$crlf> - The sequence to use at the end of a line in the output,
  normally this is left undefined and this method uses $eol (the
  normal network end of line), but if this method is being used with
  real files you may wish to pass in \n instead

=cut

method classify_and_modify ($session, $mail, $client, $nosave, $class, $slot, $echo, $crlf) {
    $echo = 1    unless (defined $echo);
    $crlf = $eol unless (defined $crlf);

    my $msg_body = '';
    my $hdr = {
        subject => undef,
        before => '',
        after => '',
        q => '',
        in_subject => 0 };

    # These two variables are used to control the insertion of the
    # X-POPFile-TimeoutPrevention header when downloading long or slow
    # emails
    my $last_timeout = time;
    my $timeout_count = 0;

    # Indicates whether the first time through the receive loop we got
    # the full body, this will happen on small emails
    my $got_full_body = 0;

    # The size of the message downloaded so far.
    my $message_size = 0;

    # The classification for this message
    my $classification = '';

    # Whether we are currently reading the mail headers or not
    my $getting_headers = 1;

    # The maximum size of message to parse, or 0 for unlimited
    my $max_size = $self->config->get('message_cutoff');
    $max_size = 0 unless (defined($max_size) || ($max_size =~ /\D/));

    my $msg_file;

    # If we don't yet know the classification then start the parser
    $class = '' unless (defined($class));
    if ($class eq '') {
        $parser->start_parse();
        ($slot, $msg_file) = $history->reserve_slot();
    } else {
        $msg_file = $history->get_slot_file($slot);
    }

    # We append .TMP to the filename for the MSG file so that if we are in
    # middle of downloading a message and we refresh the history we do not
    # get class file errors
    my $msg;
    if (!$nosave) {
        open $msg, '>', $msg_file or $self->log_msg(WARN => "Could not open $msg_file : $!");
    }

    while (my $line = $self->slurp($mail)) {
        my $fileline;

        # This is done so that we remove the network style end of line
        # CR LF and allow Perl to decide on the local system EOL which
        # it will expand out of \n when this gets written to the temp
        # file
        $fileline = $line;
        $fileline =~ s/[\r\n]//g;
        $fileline .= "\n";

        # Check for an abort
        last if ($self->alive() == 0);

        # The termination of a message is a line consisting of exactly
        # .CRLF so we detect that here exactly
        if ($line =~ /^\.(\r\n|\r|\n)$/) {
            $got_full_body = 1;
            last;
        }

        if ($getting_headers)  {
            # Kill header lines containing only whitespace (Exim does this)
            next if ($line =~ /^[ \t]+(\r\n|\r|\n)$/i);

            if ($line !~ /^(\r\n|\r|\n)$/i) {
                $message_size += length $line;
                $self->write_line($nosave?undef:$msg, $fileline, $class);

                if ($echo) {
                    next
                        if $self->_handle_echo_header($line, $hdr, $crlf);
                }
            } else {
                $self->write_line($nosave?undef:$msg, "\n", $class);
                $message_size += length $crlf;
                $getting_headers = 0;
            }
        } else {
            $message_size += length $line;
            $msg_body .= $line;
            $self->write_line($nosave?undef:$msg, $fileline, $class);
        }

        # Check to see if too much time has passed and we need to keep
        # the mail client happy
        if (time > ($last_timeout + 2)) {
            print $client "X-POPFile-TimeoutPrevention: $timeout_count$crlf" if ($echo);
            $timeout_count += 1;
            $last_timeout = time;
        }

        last
            if $max_size > 0
            && $message_size > $max_size
            && !$getting_headers;
    }

    close $msg
        unless $nosave;

    # If we don't yet know the classification then stop the parser
    if ($class eq '') {
        $parser->stop_parse();
    }

    # Do the text classification and update the counter for that
    # bucket that we just downloaded an email of that type
    $classification = ($class ne '')
        ? $class
        : $pipeline->classify($self, $session, undef);

    my $subject_modification = $self->get_bucket_parameter($session, $classification, 'subject');
    my $xtc_insertion = $self->get_bucket_parameter($session, $classification, 'xtc');
    my $xpl_insertion = $self->get_bucket_parameter($session, $classification, 'xpl');
    my $quarantine = $self->get_bucket_parameter($session, $classification, 'quarantine');

    my $modification = ($self->config->get('subject_mod_left')) . $classification . ($self->config->get('subject_mod_right'));

    # Add the Subject line modification or the original line back again
    # Don't add the classification unless it is not present
    my $original_msg_subject = $hdr->{subject};

    if ($subject_modification) {
        if (!defined $hdr->{subject}) {
            $hdr->{subject} = " $modification";
        } elsif ($hdr->{subject} !~ /\Q$modification\E/) {
            if (($self->config->get('subject_mod_pos')) > 0) {
                $hdr->{subject} = " $modification$hdr->{subject}";
            } else {
                $hdr->{subject} = "$hdr->{subject} $modification";
            }
        }
    }

    if ($quarantine) {
        if (defined($original_msg_subject)) {
            $hdr->{before} .= "Subject:$original_msg_subject$crlf";
        }
    } else {
        if (defined $hdr->{subject}) {
            $hdr->{before} .= "Subject:$hdr->{subject}$crlf";
        }
    }

    $hdr->{after} =~ s/\015\z/$crlf/;

    if ($xtc_insertion && !$quarantine) {
        $hdr->{after} .= "X-Text-Classification: $classification$crlf";
    }

    # Add the XPL header
    my $host = $self->config('GLOBAL')->get('local') // 1
        ? ($self->config->get('localhostname')) || '127.0.0.1'
        : $hostname;
    my $port = $self->config('GLOBAL')->get('port') // 0;

    my $xpl = "http://$host:$port/jump_to_message?view=$slot";

    $xpl = "<$xpl>" if (($self->config->get('xpl_angle')));

    if ($xpl_insertion && !$quarantine) {
        $hdr->{after} .= "X-POPFile-Link: $xpl$crlf";
    }

    $hdr->{after} .= $hdr->{q};
    $hdr->{after} .= $crlf if (!$getting_headers);

    if ($echo) {
        $self->_emit_quarantine_notice($client, $crlf, $slot, $xpl, $hdr->{subject}, $classification, $xtc_insertion, $xpl_insertion)
            if $quarantine;
        print $client $hdr->{before};
        print $client $hdr->{after};
        print $client $msg_body;
    }

    my $before_dot = '';

    if ($quarantine && $echo) {
        $before_dot = "$crlf--$slot--$crlf";
    }

    my $need_dot = 0;

    if ($got_full_body) {
        $need_dot = 1;
    } else {
        $need_dot = !$self->echo_to_dot($mail, $echo?$client:undef, $nosave?undef:'>>' . $msg_file, $before_dot) && !$nosave;
    }

    if ($need_dot) {
        print $client $before_dot if ($before_dot ne '');
        print $client ".$crlf"    if ($echo);
    }

    $self->_flush_message_overflow($mail, $client, $msg_file, $echo, $nosave, $crlf);

    if ($class eq '') {
        if ($nosave) {
            $history->release_slot($slot);
        } else {
            $history->commit_slot($session, $slot, $classification,
                $pipeline->last_detail());
        }
    }
    return ($classification, $slot,
        $pipeline->last_classifier() eq 'magnets' ? 1 : 0);
}

method _handle_echo_header($line, $hdr, $crlf) {
    if ($line =~ /^Subject:(.*)/i) {
        $hdr->{subject} = $1;
        $hdr->{subject} =~ s/(\012|\015)//g;
        $hdr->{in_subject} = 1;
        return 1
    }
    $hdr->{in_subject} = 0
        unless $line =~ /^[ \t]/;
    return 1
        if $line =~ /^X-Text-Classification:/i;
    return 1
        if $line =~ /^X-POPFile-Link:/i;
    if ($line =~ /^[ \t]/ && $hdr->{in_subject}) {
        $line =~ s/(\012|\015)//g;
        $hdr->{subject} .= $crlf . $line;
        return 1
    }
    if ($line =~ /^([ \t]|([A-Z0-9\-_]+:))/i) {
        unless (defined $hdr->{subject}) {
            $hdr->{before} .= $hdr->{q} . $line;
        } else {
            $hdr->{after} .= $hdr->{q} . $line;
        }
        $hdr->{q} = '';
    } else {
        $self->log_msg(INFO => "Found odd email header: $line");
        $hdr->{q} .= $line;
    }
    return 0
}

method _emit_quarantine_notice($client, $crlf, $slot, $xpl, $msg_subject, $classification, $xtc_insertion, $xpl_insertion) {
    my ($orig_from, $orig_to, $orig_subject) = ($parser->get_header('from'), $parser->get_header('to'), $parser->get_header('subject'));
    my ($encoded_from, $encoded_to) = ($orig_from, $orig_to);
    if ($parser->lang() eq 'Nihongo') {
        require Encode;
        Encode::from_to($orig_from, 'euc-jp', 'iso-2022-jp');
        Encode::from_to($orig_to, 'euc-jp', 'iso-2022-jp');
        Encode::from_to($orig_subject, 'euc-jp', 'iso-2022-jp');
        $encoded_from = $orig_from;
        $encoded_to = $orig_to;
        $encoded_from =~ s/(\x1B\x24\x42.+\x1B\x28\x42)/"=?ISO-2022-JP?B?" . encode_base64($1, '') . "?="/eg;
        $encoded_to =~ s/(\x1B\x24\x42.+\x1B\x28\x42)/"=?ISO-2022-JP?B?" . encode_base64($1, '') . "?="/eg;
    }
    print $client "From: $encoded_from$crlf";
    print $client "To: $encoded_to$crlf";
    print $client "Date: " . $parser->get_header('date') . "$crlf";
    print $client "Subject:$msg_subject$crlf"
        if defined $msg_subject;
    print $client "X-Text-Classification: $classification$crlf"
        if $xtc_insertion;
    print $client "X-POPFile-Link: $xpl$crlf"
        if $xpl_insertion;
    print $client "MIME-Version: 1.0$crlf";
    print $client "Content-Type: multipart/report; boundary=\"$slot\"$crlf$crlf--$slot$crlf";
    print $client "Content-Type: text/plain";
    print $client "; charset=iso-2022-jp"
        if $parser->lang() eq 'Nihongo';
    print $client "$crlf$crlf";
    print $client "POPFile has quarantined a message.  It is attached to this email.$crlf$crlf";
    print $client "Quarantined Message Detail$crlf$crlf";
    print $client "Original From: $orig_from$crlf";
    print $client "Original To: $orig_to$crlf";
    print $client "Original Subject: $orig_subject$crlf";
    print $client "To examine the email open the attachment. ";
    print $client "To change this mail's classification go to $xpl$crlf";
    print $client "$crlf";
    print $client "The first 20 words found in the email are:$crlf$crlf";
    my $first20 = $parser->first20();
    if ($parser->lang() eq 'Nihongo') {
        require Encode;
        Encode::from_to($first20, 'euc-jp', 'iso-2022-jp');
    }
    print $client $first20;
    print $client "$crlf--$slot$crlf";
    print $client "Content-Type: message/rfc822$crlf$crlf"
}

method _flush_message_overflow($mail, $client, $msg_file, $echo, $nosave, $crlf) {
    if ($nosave || $echo) {
        $self->flush_extra($mail, $client, $echo ? 0 : 1);
        return
    }
    if (open FLUSH, ">$msg_file.flush") {
        binmode FLUSH;
        $self->flush_extra($mail, \*FLUSH, 0);
        close FLUSH;
        if (((-s "$msg_file.flush") > 0) && (open FLUSH, "<$msg_file.flush")) {
            binmode FLUSH;
            if (open TEMP, ">>$msg_file") {
                binmode TEMP;
                print TEMP ".$crlf";
                print TEMP $_ while (<FLUSH>);
                close TEMP;
            }
            close FLUSH;
        }
        unlink("$msg_file.flush");
    }
}

=head2 get_buckets

Returns a list containing all the real bucket names sorted into
alphabetic order

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_buckets($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $buckets->names($db_bucketid, $userid)
}

=head2 get_bucket_objects

Returns a list of Classifier::Bucket objects for all non-pseudo buckets,
each populated with name, color, count, and prior from the in-memory cache.

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_bucket_objects ($session) {
    my $userid = $self->valid_session_key($session);
    return ()
        unless defined $userid;
    my @result;
    for my $name ($self->get_buckets($session)) {
        my $b = Classifier::Bucket->new(
            name   => $name,
            color  => $self->get_bucket_parameter($session, $name, 'color'),
            count  => $db_bucketcount->{$userid}{$name} // 0,
            prior  => $bucket_start->{$userid}{$name} // 0,
        );
        push @result, $b;
    }
    return @result
}

=head2 get_bucket_id

Returns the internal ID for a bucket for database calls

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket name

=cut

method get_bucket_id ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless (defined($db_bucketid->{$userid}{$bucket}));

    return $db_bucketid->{$userid}{$bucket}{id};
}

=head2 get_bucket_name

Returns the name of a bucket from an internal ID

C<$session> A valid session key returned by a call to get_session_key
C<$id> The bucket id

=cut

method get_bucket_name ($session, $id) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    for $b (keys $db_bucketid->{$userid}->%*) {
        if ($id == $db_bucketid->{$userid}{$b}{id}) {
            return $b;
        }
    }

    return '';
}

=head2 get_pseudo_buckets

Returns a list containing all the pseudo bucket names sorted into
alphabetic order

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_pseudo_buckets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    my @buckets;

    for my $b (sort keys $db_bucketid->{$userid}->%*) {
        if ($db_bucketid->{$userid}{$b}{pseudo} == 1) {
            push @buckets, ($b);
        }
    }

    return @buckets;
}

=head2 get_all_buckets

Returns a list containing all the bucket names sorted into
alphabetic order

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_all_buckets ($session) {
    if (my $userid = $self->valid_session_key($session)) {
        return sort keys $db_bucketid->{$userid}->%*
    }
    $self->log_msg(WARN => 'Could not get user ID');
    return
}

=head2 is_pseudo_bucket

Returns 1 if the named bucket is pseudo

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to check

=cut

method is_pseudo_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return (defined($db_bucketid->{$userid}{$bucket}) &&
             $db_bucketid->{$userid}{$bucket}{pseudo});
}

=head2 is_bucket

Returns 1 if the named bucket is a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to check

=cut

method is_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return (defined($db_bucketid->{$userid}{$bucket}) &&
        !$db_bucketid->{$userid}{$bucket}{pseudo});
}

=head2 get_bucket_word_count

Returns the total word count (including duplicates) for the passed in bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired

=cut

method get_bucket_word_count ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->bucket_count($db_bucketcount, $userid, $bucket)
}

=head2 get_bucket_word_list

Returns a list of words all with the same first character

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired
C<$prefix> The first character of the words

=cut

method get_bucket_word_list ($session, $bucket, $prefix) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless exists $db_bucketid->{$userid}{$bucket};
    return $corpus->word_list_for_bucket($self->get_handle(),
        $db_bucketid->{$userid}{$bucket}{id}, $prefix)
}

=head2 get_words_for_bucket

Returns a paginated list of words for a bucket sorted by Laplace-smoothed
relevance descending: C<bucket_count / (total_count + 10)>.  This surfaces
words that are both frequent and strongly associated with the bucket, while
burying single-occurrence noise and near-neutral stopwords.

C<$session> A valid session key
C<$bucket> Bucket name
C<%opts> page (1-based), per_page

Returns a hashref with keys: words (arrayref of hashrefs), total (int).

=cut

method get_words_for_bucket ($session, $bucket, %opts) {
    my $userid = $self->valid_session_key($session);
    return { words => [], total => 0 }
        unless defined $userid;
    return { words => [], total => 0 }
        unless exists $db_bucketid->{$userid}{$bucket};
    my $page = ($opts{page} // 1) + 0;
    my $per_page = ($opts{per_page} // 50) + 0;
    $page = 1 if $page < 1;
    $per_page = 50 if $per_page < 1 || $per_page > 500;
    my $offset = ($page - 1) * $per_page;
    my $dir  = ($opts{dir} // '') eq 'asc' ? 'ASC' : 'DESC';
    my $sort = $opts{sort} // 'relevance';
    my ($words, $total) = $corpus->bucket_word_page(
        $self->get_handle(), $db_bucketid->{$userid}{$bucket}{id},
        $sort, $dir, $per_page, $offset);
    return { words => $words, total => $total }
}

=head2 search_words_cross_bucket

Search words across all non-pseudo buckets, returning per-bucket counts.

C<$session> A valid session key
C<$prefix> Word prefix to search (empty matches all)
C<%opts> sort (word|coverage|total|<bucket-name>), dir (asc|desc), page, per_page

Returns hashref: { words => [...], total => N, buckets => [...] }.

=cut

method search_words_cross_bucket ($session, $prefix, %opts) {
    my $userid = $self->valid_session_key($session);
    return { words => [], total => 0, buckets => [] }
        unless defined $userid;
    my $page = ($opts{page} // 1) + 0;
    my $per_page = ($opts{per_page} // 50) + 0;
    $page = 1 if $page < 1;
    $per_page = 50 if $per_page < 1 || $per_page > 500;
    my $sort = $opts{sort} // 'word';
    my $dir = ($opts{dir} // '') eq 'desc' ? 'DESC' : 'ASC';
    my $bucket_filter = $opts{bucket} // '';
    my @bucket_names = map { $_->[0] }
        $self->validate_sql_prepare_and_execute(
            'SELECT name FROM buckets WHERE userid = ? AND pseudo = 0 ORDER BY name',
            $userid)->fetchall_arrayref->@*;
    return { words => [], total => 0, buckets => \@bucket_names }
        unless @bucket_names;
    return { words => [], total => 0, buckets => \@bucket_names }
        if $bucket_filter ne '' && !(grep { $_ eq $bucket_filter } @bucket_names);
    my %stopwords = map { $_ => 1 } $self->get_stopword_list($session);
    my ($paged_words, $total, $bucket_data) =
        $self->_search_words_fetch($userid, $prefix, $bucket_filter, $sort, $dir, $per_page, ($page - 1) * $per_page);
    return { words => [], total => $total, buckets => \@bucket_names }
        unless $paged_words->@*;
    my @result = map {
        my $word = $_;
        my %b = map { $_ => ($bucket_data->{$word}{$_} // 0) } @bucket_names;
        my $cov = scalar grep { $b{$_} > 0 } @bucket_names;
        { word => $word,
          buckets => \%b,
          coverage => $cov,
          is_stopword => exists $stopwords{$word} ? \1 : \0 }
    } $paged_words->@*;
    return { words => \@result, total => $total, buckets => \@bucket_names }
}

method _search_words_fetch ($userid, $prefix, $bucket_filter, $sort, $dir, $per_page, $offset) {
    return $corpus->search_words_cross($self->get_handle(), $self->qb(),
        $userid, $prefix, $bucket_filter, $sort, $dir, $per_page, $offset)
}

=head2 get_word_by_id

Returns the word string for a given word ID, or undef if not found.

C<$id> Word ID from the words table

=cut

method get_word_by_id ($id) {
    return $corpus->word_for_id($self->get_handle(), $id)
}

=head2 remove_word_from_bucket

Removes a word from a bucket's corpus (deletes the matrix row).

C<$session> A valid session key
C<$bucket>  Bucket name
C<$word>    Word to remove

=cut

method remove_word_from_bucket ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless exists $db_bucketid->{$userid}{$bucket};
    $corpus->remove_word($self->get_handle(),
        $db_bucketid->{$userid}{$bucket}{id}, $word);
    $self->db_update_cache($session, $bucket);
}

=head2 move_word_between_buckets

Moves a word's count from one bucket to another in the matrix.

C<$session>     A valid session key
C<$from_bucket> Source bucket name
C<$to_bucket>   Target bucket name
C<$word>        Word to move

=cut

method move_word_between_buckets ($session, $from_bucket, $to_bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless exists $db_bucketid->{$userid}{$from_bucket}
            && exists $db_bucketid->{$userid}{$to_bucket};
    my $from_id = $db_bucketid->{$userid}{$from_bucket}{id};
    my $to_id = $db_bucketid->{$userid}{$to_bucket}{id};
    $corpus->move_word($self->get_handle(), $from_id, $to_id, $word);
    $self->db_update_cache($session, $from_bucket);
    $self->db_update_cache($session, $to_bucket);
}

=head2 get_bucket_word_prefixes

Returns a list of all the initial letters of words in a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired

=cut

method get_bucket_word_prefixes($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    my $prev = '';
    my $bucketid = $db_bucketid->{$userid}{$bucket}{id};
    my $result = $corpus->raw_word_prefixes($self->get_handle(), $bucketid);
    if (($self->config->get('locale')) eq 'Nihongo') {
        return
            grep {$_ ne $prev && ($prev = $_, 1)}
            sort
            map {substr_euc($_,0,1)}
            $result->@*;
    } else {
        if  (($self->config->get('locale')) eq 'Korean') {
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {$_ =~ /([\x20-\x80]|$eksc)/} $result->@*;
        } else {
            return grep {$_ ne $prev && ($prev = $_, 1)} sort map {substr($_,0,1)} $result->@*;
        }
    }
}

=head2 get_word_count

Returns the total word count (including duplicates)

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_word_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->total_count($db_bucketcount, $db_bucketid, $userid)
}

=head2 get_count_for_word

Returns the number of times the word occurs in a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket we are asking about
C<$word> The word we are asking about

=cut

method get_count_for_word ($session, $bucket, $word) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $self->get_base_value($session, $bucket, $word);
}

=head2 get_bucket_unique_count

Returns the unique word count (excluding duplicates) for the passed
in bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the word count is desired

=cut

method get_bucket_unique_count ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->bucket_unique($db_bucketunique, $userid, $bucket)
}

=head2 get_unique_word_count

Returns the unique word count (excluding duplicates) for all buckets

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_unique_word_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    return $corpus->total_unique($db_bucketunique, $db_bucketid, $userid)
}

=head2 get_bucket_color

Returns the color associated with a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the color is requested
C<NOTE> This API is DEPRECATED in favor of calling get_bucket_parameter for
      the parameter named 'color'

=cut

method get_bucket_color ($session, $bucket) {
    return $self->get_bucket_parameter($session, $bucket, 'color');
}

=head2 set_bucket_color

Returns the color associated with a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket for which the color is requested
C<$color> The new color
C<NOTE> This API is DEPRECATED in favor of calling set_bucket_parameter for
      the parameter named 'color'

=cut

method set_bucket_color ($session, $bucket, $color) {
    return $self->set_bucket_parameter($session, $bucket, 'color', $color);
}

=head2 get_bucket_parameter

Returns the value of a per bucket parameter

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The name of the bucket
C<$parameter> The name of the parameter

=cut

method get_bucket_parameter ($session, $bucket, $parameter) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    return $buckets->parameter_get($self->get_handle(), $userid, $bucket,
        $db_bucketid->{$userid}{$bucket}{id}, $parameter)
}

=head2 set_bucket_parameter

Sets the value associated with a bucket specific parameter

=cut

method set_bucket_parameter ($session, $bucket, $parameter, $value) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    return $buckets->parameter_set($self->get_handle(), $userid, $bucket,
        $db_bucketid->{$userid}{$bucket}{id}, $parameter, $value)
}

=head2 create_bucket

Creates a new bucket, returns 1 if the creation succeeded

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name for the new bucket

=cut

method create_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        if $self->is_bucket($session, $bucket)
        || $self->is_pseudo_bucket($session, $bucket);
    return 0
        unless $buckets->name_is_valid($bucket);
    $buckets->create_in_db($self->get_handle(), $userid, $bucket);
    $self->db_update_cache($session, $bucket);
    return 1
}

=head2 delete_bucket

Deletes a bucket, returns 1 if the delete succeeded

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to delete

=cut

method delete_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    $buckets->delete_from_db($self->get_handle(), $userid, $bucket);
    $self->db_update_cache($session, undef, $bucket);
    $history->queries()->invalidate_all();
    return 1
}

=head2 rename_bucket

Renames a bucket, returns 1 if the rename succeeded

C<$session> A valid session key returned by a call to get_session_key
C<$old_bucket> The old name of the bucket
C<$new_bucket> The new name of the bucket

=cut

method rename_bucket ($session, $old_bucket, $new_bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    unless (defined $db_bucketid->{$userid}{$old_bucket}) {
        $self->log_msg(WARN => "Bad bucket name $old_bucket to rename_bucket");
        return 0
    }
    if (defined $db_bucketid->{$userid}{$new_bucket}) {
        $self->log_msg(WARN => "Bucket named $new_bucket already exists");
        return 0
    }
    return 0
        unless $buckets->name_is_valid($new_bucket);
    $self->log_msg(INFO => "Rename bucket $old_bucket to $new_bucket");
    $buckets->rename_in_db($self->get_handle(),
        $db_bucketid->{$userid}{$old_bucket}{id}, $new_bucket);
    $self->db_update_cache($session, $new_bucket, $old_bucket);
    $history->queries()->invalidate_all();
    return 1
}

=head2 add_messages_to_bucket

Parses mail messages and updates the statistics in the specified bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to be updated
@files           List of file names to parse

=cut

method add_messages_to_bucket ($session, $bucket, @files) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    # This is done to clear out the word list because in the loop
    # below we are going to not reset the word list on each parse
    $parser->start_parse();
    $parser->stop_parse();

    for my $file (@files) {
        $parser->parse_file($file, $self->config->get('message_cutoff'), 0);
    }

    $self->add_words_to_bucket($session, $bucket, 1);
    $self->db_update_cache($session, $bucket);

    return 1;
}

=head2 train_messages_batch

Parses a list of raw message texts and trains them all into C<$bucket> in a
single DB transaction.  Aggregates word counts across all messages before
writing.

C<$session>  A valid session key returned by a call to get_session_key
C<$bucket>   Name of the bucket to train into
C<$texts>    Array-ref of raw message text strings

=cut

method train_messages_batch ($session, $bucket, $texts) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    $parser->start_parse();
    $parser->stop_parse();
    for my $text ($texts->@*) {
        $parser->start_parse(0);
        $parser->parse_line($_) for split /(?<=\n)/, $text;
        $parser->stop_parse();
    }
    $self->add_words_to_bucket($session, $bucket, 1);
    $self->db_update_cache($session, $bucket);
    return 1
}

=head2 add_message_to_bucket

Parses a mail message and updates the statistics in the specified bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to be updated
C<$file> Name of file containing mail message to parse

=cut

method add_message_to_bucket ($session, $bucket, $file) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        $self->log_msg(WARN => "add_message_to_bucket: bucket '$bucket' not found for user=$userid file=" . ($file // 'undef'));
        return 0;
    }

    my $result = $self->add_messages_to_bucket($session, $bucket, $file);
    $self->log_msg(5, "add_message_to_bucket: user=$userid bucket=$bucket file=" . ($file // 'undef') . " result=" . (defined $result ? $result : 'undef'));
    return $result;
}

=head2 remove_message_from_bucket

Parses a mail message and updates the statistics in the specified bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> Name of the bucket to be updated
C<$file> Name of file containing mail message to parse

=cut

method remove_message_from_bucket ($session, $bucket, $file) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;

    unless (defined($db_bucketid->{$userid}{$bucket})) {
        return 0;
    }

    $parser->parse_file($file,
        $self->config->get('message_cutoff'));
        $self->add_words_to_bucket($session, $bucket, -1);
        $self->db_update_cache($session, $bucket);

    return 1;
}

=head2 get_buckets_with_magnets

Returns the names of the buckets for which magnets are defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_buckets_with_magnets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->get_buckets_with($self->get_handle(), $userid)
}

=head2 get_magnet_types_in_bucket

Returns the types of the magnets in a specific bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to search for magnets

=cut

method get_magnet_types_in_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    return $magnets->get_types_in_bucket($self->get_handle(), $db_bucketid->{$userid}{$bucket}{id})
}

=head2 clear_bucket

Removes all words from a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to clear

=cut

method clear_bucket ($session, $bucket) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return
        unless defined $db_bucketid->{$userid}{$bucket};
    $buckets->clear_bucket_words($self->get_handle(),
        $db_bucketid->{$userid}{$bucket}{id});
    $self->db_update_cache($session, $bucket);
    return 1
}

=head2 clear_magnets

Removes every magnet currently defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method clear_magnets ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->clear($self->get_handle(), $userid)
}

=head2 get_magnets

Returns the magnets of a certain type in a bucket

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket to search for magnets
C<$type> The magnet type (e.g. from, to or subject)

=cut

method get_magnets ($session, $bucket, $type) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket}
            && defined $type;
    return $magnets->get($self->get_handle(), $db_bucketid->{$userid}{$bucket}{id}, $type)
}

=head2 get_magnet_types

Get a hash mapping magnet types (e.g. from) to magnet names (e.g. From);

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_magnet_types ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->get_types($self->get_handle())
}

=head2 create_magnet

C<$session> A valid session key returned by a call to get_session_key
C<$bucket> The bucket the magnet belongs in
C<$type> The magnet type (e.g. from, to or subject)
C<$text> The text of the magnet

Creates a new magnet in C<$bucket>.

=cut

method create_magnet ($session, $bucket, $type, $text) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    return $magnets->create($self->get_handle(), $db_bucketid->{$userid}{$bucket}{id}, $type, $text)
}

=head2 delete_magnet

    $self->delete_magnet($session, $bucket, $type, $text);

Removes the magnet with type C<$type> and value C<$text> from C<$bucket>.

=cut

method delete_magnet ($session, $bucket, $type, $text) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return 0
        unless defined $db_bucketid->{$userid}{$bucket};
    return $magnets->delete($self->get_handle(), $db_bucketid->{$userid}{$bucket}{id}, $type, $text,
        sub { $history->queries()->invalidate_all() })
}

=head2 get_stopword_list

Gets the complete list of stop words

C<$session> A valid session key returned by a call to get_session_key

=cut

method get_stopword_list ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $stopwords->get_list($parser->mangle(), $userid)
}

=head2 get_stopword_candidates

    my @candidates = $self->get_stopword_candidates($session, $ratio, $limit);

Returns words that appear in every non-pseudo bucket with a max-to-min
per-bucket frequency ratio below C<$ratio>.  These words carry little
discriminative power.  C<$limit> caps the result set (default 50).

Each entry is a hashref with C<word>, C<min_count>, C<max_count>, and C<ratio>.

=cut

method get_stopword_candidates ($session, $ratio = 2.0, $limit = 50) {
    my $userid = $self->valid_session_key($session);
    return ()
        unless defined $userid;
    return $stopwords->get_candidates($self->get_handle(), $userid, $ratio, $limit)
}

=head2 magnet_count

Gets the number of magnets that are defined

C<$session> A valid session key returned by a call to get_session_key

=cut

method magnet_count ($session) {
    my $userid = $self->valid_session_key($session);
    return
        unless defined $userid;
    return $magnets->count($self->get_handle(), $userid)
}

=head2 set_history

    $self->set_history($history_obj);

Injects the C<POPFile::History> object used to record classified messages.

=cut

method set_history($h) {
    $history = $h;
}

1;
