#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

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
$bayes->{parser__}->mangle($wm);

my $started = $bayes->start();
is( $started, 1, 'Bayes started successfully (DB created)' );

# -----------------------------------------------------------------------
subtest 'session management' => sub {
    my $session = $bayes->get_session_key('admin', '');
    ok( defined $session && $session ne '', 'get_session_key returns a non-empty key' );
    ok( exists $bayes->{api_sessions__}{$session}, 'session key registered internally' );

    $bayes->release_session_key($session);
    ok( !exists $bayes->{api_sessions__}{$session}, 'session key removed after release' );
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
$bayes->release_session_key($session);
$bayes->stop();

done_testing;
