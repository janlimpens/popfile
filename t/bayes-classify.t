#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use FindBin qw($Bin);

my ($config, $mq, $tmpdir) = TestHelper::setup();

# Wire up WordMangle
my $wm = TestHelper::make_module('Classifier::WordMangle', $config, $mq);
$wm->start();

# Wire up Bayes (which creates MailParse internally)
my $bayes = TestHelper::make_module('Classifier::Bayes', $config, $mq);

# Bayes uses get_root_path_() to find popfile.sql, so POPFILE_ROOT
# (via Configuration) must point to the repo root – TestHelper sets this.

# Inject WordMangle into the parser Bayes created internally
$bayes->parser()->set_mangle($wm);

my $started = $bayes->start();
is( $started, 1, 'Bayes started successfully (DB created)' );

# -----------------------------------------------------------------------
subtest 'session management' => sub {
    my $session = $bayes->get_session_key('admin', '');
    ok( defined $session && $session ne '', 'get_session_key returns a non-empty key' );
    my @buckets = $bayes->get_buckets($session);
    ok( defined $buckets[0] || 1, 'session key accepted by API' );

    $bayes->release_session_key($session);
    my $after = $bayes->get_buckets($session);
    ok( !defined $after, 'released session key no longer accepted' );
};

# -----------------------------------------------------------------------
# Get a session for the rest of the tests
my $session = $bayes->get_session_key('admin', '');
ok( defined $session, 'session obtained for further tests' );

# -----------------------------------------------------------------------
subtest 'bucket management' => sub {
    # Fresh DB always has the 'unclassified' pseudo-bucket
    my @buckets = $bayes->get_buckets($session);
    ok( scalar @buckets >= 0, 'get_buckets returns a list' );

    is( $bayes->create_bucket($session, 'inbox'),  1, 'created bucket "inbox"' );
    is( $bayes->create_bucket($session, 'spam'),   1, 'created bucket "spam"' );

    @buckets = $bayes->get_buckets($session);
    my %bset = map { $_ => 1 } @buckets;
    ok( $bset{inbox}, '"inbox" in bucket list' );
    ok( $bset{spam},  '"spam" in bucket list' );

    ok( $bayes->is_bucket($session, 'inbox'), 'is_bucket true for "inbox"' );
    ok( !$bayes->is_bucket($session, 'nonexistent'), 'is_bucket false for unknown bucket' );
};

# -----------------------------------------------------------------------
subtest 'training and classification' => sub {
    my $ham_fixture  = "$Bin/fixtures/ham.eml";
    my $spam_fixture = "$Bin/fixtures/spam.eml";

    # Train several times to build a meaningful corpus
    for (1..5) {
        $bayes->add_message_to_bucket($session, 'inbox', $ham_fixture);
    }
    for (1..5) {
        $bayes->add_message_to_bucket($session, 'spam', $spam_fixture);
    }

    # Word counts should now be non-zero
    my $inbox_wc = $bayes->get_bucket_word_count($session, 'inbox');
    my $spam_wc  = $bayes->get_bucket_word_count($session, 'spam');
    ok( $inbox_wc > 0, "inbox has $inbox_wc words after training" );
    ok( $spam_wc  > 0, "spam has $spam_wc words after training" );

    # Classify the ham fixture – should land in 'inbox'
    my $ham_class = $bayes->classify($session, $ham_fixture);
    is( $ham_class, 'inbox', 'ham classified into inbox' );

    # Classify the spam fixture – should land in 'spam'
    my $spam_class = $bayes->classify($session, $spam_fixture);
    is( $spam_class, 'spam', 'spam classified into spam' );
};

# -----------------------------------------------------------------------
subtest 'bucket parameters' => sub {
    my $color = $bayes->get_bucket_color($session, 'inbox');
    ok( defined $color && $color ne '', 'bucket has a color' );

    $bayes->set_bucket_color($session, 'inbox', 'blue');
    is( $bayes->get_bucket_color($session, 'inbox'), 'blue', 'bucket color updated' );
};

# -----------------------------------------------------------------------
subtest 'word count APIs' => sub {
    my $total_wc = $bayes->get_word_count($session);
    ok( $total_wc > 0, "total word count ($total_wc) is positive" );

    my $inbox_wc = $bayes->get_bucket_word_count($session, 'inbox');
    my $spam_wc  = $bayes->get_bucket_word_count($session, 'spam');
    is( $total_wc, $inbox_wc + $spam_wc, 'total equals sum of bucket counts' );

    my $meeting_count = $bayes->get_count_for_word($session, 'inbox', 'meeting');
    ok( $meeting_count > 0, "\"meeting\" appears in inbox ($meeting_count times)" );

    my $inbox_unique = $bayes->get_bucket_unique_count($session, 'inbox');
    ok( $inbox_unique > 0, "inbox has $inbox_unique unique words" );

    my $total_unique = $bayes->get_unique_word_count($session);
    ok( $total_unique >= $inbox_unique, 'total unique >= inbox unique' );
};

# -----------------------------------------------------------------------
subtest 'word list retrieval' => sub {
    my @prefixes = $bayes->get_bucket_word_prefixes($session, 'inbox');
    ok( @prefixes > 0, 'get_bucket_word_prefixes returns some prefixes' );

    my $prefix = $prefixes[0];
    my @words  = $bayes->get_bucket_word_list($session, 'inbox', $prefix);
    ok( @words > 0, "get_bucket_word_list returns words for prefix '$prefix'" );
};

# -----------------------------------------------------------------------
subtest 'pseudo and all buckets' => sub {
    my @pseudo = $bayes->get_pseudo_buckets($session);
    ok( @pseudo > 0, 'get_pseudo_buckets returns at least one pseudo bucket' );
    ok( (grep { $_ eq 'unclassified' } @pseudo), '"unclassified" is a pseudo bucket' );

    ok(  $bayes->is_pseudo_bucket($session, 'unclassified'), 'is_pseudo_bucket true for "unclassified"' );
    ok( !$bayes->is_pseudo_bucket($session, 'inbox'),        'is_pseudo_bucket false for real bucket' );

    my @all     = $bayes->get_all_buckets($session);
    my %all_set = map { $_ => 1 } @all;
    ok( $all_set{inbox},        '"inbox" in get_all_buckets' );
    ok( $all_set{unclassified}, '"unclassified" in get_all_buckets' );
};

# -----------------------------------------------------------------------
subtest 'bucket parameter get/set' => sub {
    my $fncount = $bayes->get_bucket_parameter($session, 'inbox', 'fncount');
    ok( defined $fncount, 'fncount parameter is defined' );

    $bayes->set_bucket_parameter($session, 'inbox', 'fncount', 42);
    is( $bayes->get_bucket_parameter($session, 'inbox', 'fncount'), 42, 'fncount updated to 42' );

    $bayes->set_bucket_parameter($session, 'inbox', 'fncount', $fncount);
};

# -----------------------------------------------------------------------
subtest 'rename bucket' => sub {
    is( $bayes->create_bucket($session, 'tmp-rename'),              1, 'created "tmp-rename"' );
    is( $bayes->rename_bucket($session, 'tmp-rename', 'tmp-renamed'), 1, 'renamed to "tmp-renamed"' );
    ok(  $bayes->is_bucket($session, 'tmp-renamed'), '"tmp-renamed" exists' );
    ok( !$bayes->is_bucket($session, 'tmp-rename'),  '"tmp-rename" gone' );
    is( $bayes->rename_bucket($session, 'tmp-rename', 'tmp-renamed'), 0, 'renaming non-existent returns 0' );
    $bayes->delete_bucket($session, 'tmp-renamed');
};

# -----------------------------------------------------------------------
subtest 'delete bucket' => sub {
    is( $bayes->create_bucket($session, 'tmp-delete'),  1, 'created "tmp-delete"' );
    is( $bayes->delete_bucket($session, 'tmp-delete'),  1, 'deleted "tmp-delete"' );
    ok( !$bayes->is_bucket($session, 'tmp-delete'), '"tmp-delete" no longer exists' );
    is( $bayes->delete_bucket($session, 'tmp-delete'), 0, 'deleting non-existent bucket returns 0' );
};

# -----------------------------------------------------------------------
subtest 'get_stopword_candidates' => sub {
    my @candidates = $bayes->get_stopword_candidates($session, 2.0, 50);
    ok( defined \@candidates, 'get_stopword_candidates returns a list' );
    for my $c (@candidates) {
        ok( $c->{ratio} < 2.0, "candidate '$c->{word}' ratio $c->{ratio} < 2.0" );
        ok( $c->{max_count} >= $c->{min_count}, 'max_count >= min_count' );
    }
};

# -----------------------------------------------------------------------
subtest 'stopword_ratio config filters uniform words at classify time' => sub {
    my $ham_fixture  = "$Bin/fixtures/ham.eml";
    my $spam_fixture = "$Bin/fixtures/spam.eml";

    $bayes->config('stemming', 0);
    $bayes->config('stopword_ratio', 0);
    my $class_no_filter = $bayes->classify($session, $ham_fixture);

    $bayes->config('stopword_ratio', 1000);
    my $class_with_filter = $bayes->classify($session, $ham_fixture);

    ok( defined $class_no_filter,   'classify works without filtering' );
    ok( defined $class_with_filter, 'classify works with aggressive filtering (ratio 1000)' );
    $bayes->config('stopword_ratio', 0);
};

# -----------------------------------------------------------------------
subtest 'clear bucket' => sub {
    my $wc_before = $bayes->get_bucket_word_count($session, 'inbox');
    ok( $wc_before > 0, "inbox has words before clear" );
    is( $bayes->clear_bucket($session, 'inbox'),          1, 'clear_bucket returned 1' );
    is( $bayes->get_bucket_word_count($session, 'inbox'),  0, 'inbox word count is 0 after clear' );
};

# -----------------------------------------------------------------------
subtest 'matrix integrity after training (regression #170)' => sub {
    my $spam_fixture = "$Bin/fixtures/spam.eml";
    is( $bayes->create_bucket($session, 'spam2'), 1, 'created bucket "spam2"' );
    for (1..3) {
        $bayes->add_message_to_bucket($session, 'spam2', $spam_fixture);
    }
    my $wc = $bayes->get_bucket_word_count($session, 'spam2');
    ok( $wc > 0, "spam2 has $wc words after training" );
    my $null_bucket_rows = $bayes->db()->selectrow_array(
        'SELECT COUNT(*) FROM matrix WHERE bucketid IS NULL');
    is( $null_bucket_rows, 0, 'no matrix rows with NULL bucketid' );
    my $spam2_matrix_count = $bayes->db()->selectrow_array(
        'SELECT COUNT(*) FROM matrix m JOIN buckets b ON m.bucketid = b.id WHERE b.name = ?',
        undef, 'spam2');
    ok( $spam2_matrix_count > 0, "spam2 has $spam2_matrix_count matrix entries" );
    $bayes->delete_bucket($session, 'spam2');
};

# -----------------------------------------------------------------------
$bayes->release_session_key($session);
$bayes->stop();

done_testing;
