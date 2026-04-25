#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

# -----------------------------------------------------------------------
subtest 'load_fixture from file' => sub {
    my $session = $bayes->get_session_key('admin', '');

    TestHelper::load_fixture($bayes, $session, 'two-buckets-trained');

    my @buckets = $bayes->get_buckets($session);
    my %bset    = map { $_ => 1 } @buckets;
    ok( $bset{inbox}, '"inbox" created by fixture' );
    ok( $bset{spam},  '"spam" created by fixture' );

    ok( $bayes->get_bucket_word_count($session, 'inbox') > 0, 'inbox has training data' );
    ok( $bayes->get_bucket_word_count($session, 'spam')  > 0, 'spam has training data' );

    $bayes->release_session_key($session);
};

# -----------------------------------------------------------------------
subtest 'reset_db clears all user data' => sub {
    my $session = TestHelper::reset_db($bayes, $config);

    my @buckets = $bayes->get_buckets($session);
    my %bset    = map { $_ => 1 } @buckets;
    ok( !$bset{inbox}, '"inbox" gone after reset' );
    ok( !$bset{spam},  '"spam" gone after reset' );

    $bayes->release_session_key($session);
};

# -----------------------------------------------------------------------
subtest 'load_fixture inline hashref' => sub {
    my $session = $bayes->get_session_key('admin', '');

    TestHelper::load_fixture($bayes, $session, {
        buckets => [qw(work personal)],
        train => {
            work => ['ham.eml'],
            personal => ['ham.eml'],
        },
    });

    ok( $bayes->is_bucket($session, 'work'),     '"work" bucket created' );
    ok( $bayes->is_bucket($session, 'personal'), '"personal" bucket created' );

    $bayes->release_session_key($session);
};

# -----------------------------------------------------------------------
subtest 'reset_db then reload fixture gives consistent state' => sub {
    my $session = TestHelper::reset_db($bayes, $config);
    TestHelper::load_fixture($bayes, $session, 'two-buckets-trained');

    my $ham_class  = $bayes->classify($session, "$TestHelper::REPO_ROOT/t/fixtures/ham.eml");
    my $spam_class = $bayes->classify($session, "$TestHelper::REPO_ROOT/t/fixtures/spam.eml");

    is( $ham_class,  'inbox', 'ham classifies correctly after fixture reload' );
    is( $spam_class, 'spam',  'spam classifies correctly after fixture reload' );

    $bayes->release_session_key($session);
};

# -----------------------------------------------------------------------
$bayes->stop();

done_testing;
