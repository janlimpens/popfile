#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();

my $wm = TestHelper::make_module('Classifier::WordMangle', $config, $mq);
$wm->start();

my $bayes = TestHelper::make_module('Classifier::Bayes', $config, $mq);
$bayes->parser()->set_mangle($wm);
$bayes->start();

my $session = $bayes->get_session_key('admin', '');
$bayes->create_bucket($session, 'inbox');
$bayes->create_bucket($session, 'spam');

# -----------------------------------------------------------------------
subtest 'magnet types' => sub {
    my %types = $bayes->get_magnet_types($session);
    ok( scalar keys %types > 0, 'get_magnet_types returns some types' );
    ok( exists $types{from},    '"from" is a magnet type' );
    ok( exists $types{subject}, '"subject" is a magnet type' );
    ok( exists $types{to},      '"to" is a magnet type' );
};

# -----------------------------------------------------------------------
subtest 'create and retrieve magnets' => sub {
    is( $bayes->create_magnet($session, 'spam', 'from', 'spam@example.com'), 1, 'created from-magnet' );
    is( $bayes->create_magnet($session, 'spam', 'subject', 'FREE PRIZE'),    1, 'created subject-magnet' );

    my @from_magnets = $bayes->get_magnets($session, 'spam', 'from');
    is( scalar @from_magnets, 1,                'one from-magnet in spam' );
    is( $from_magnets[0], 'spam@example.com',   'from-magnet has correct value' );

    my @subj_magnets = $bayes->get_magnets($session, 'spam', 'subject');
    is( scalar @subj_magnets, 1,    'one subject-magnet in spam' );
    is( $subj_magnets[0], 'FREE PRIZE', 'subject-magnet has correct value' );

    is( $bayes->magnet_count($session), 2, 'magnet_count is 2' );
};

# -----------------------------------------------------------------------
subtest 'get_buckets_with_magnets and get_magnet_types_in_bucket' => sub {
    my @bwm = $bayes->get_buckets_with_magnets($session);
    ok( (grep { $_ eq 'spam' } @bwm), '"spam" appears in get_buckets_with_magnets' );
    ok( !(grep { $_ eq 'inbox' } @bwm), '"inbox" absent (no magnets)' );

    my @types_in_spam = $bayes->get_magnet_types_in_bucket($session, 'spam');
    ok( (grep { $_ eq 'from' }    @types_in_spam), '"from" type in spam magnets' );
    ok( (grep { $_ eq 'subject' } @types_in_spam), '"subject" type in spam magnets' );
};

# -----------------------------------------------------------------------
subtest 'delete magnet' => sub {
    is( $bayes->delete_magnet($session, 'spam', 'from', 'spam@example.com'), 1, 'deleted from-magnet' );

    my @from_magnets = $bayes->get_magnets($session, 'spam', 'from');
    is( scalar @from_magnets, 0, 'no from-magnets left after delete' );
    is( $bayes->magnet_count($session), 1, 'magnet_count now 1' );

    is( $bayes->delete_magnet($session, 'spam', 'from', 'nonexistent@example.com'),
        0, 'deleting non-existent magnet returns 0' );
};

# -----------------------------------------------------------------------
subtest 'clear magnets' => sub {
    is( $bayes->clear_magnets($session), 1, 'clear_magnets returned 1' );
    is( $bayes->magnet_count($session),  0, 'magnet_count is 0 after clear' );
};

# -----------------------------------------------------------------------
$bayes->release_session_key($session);
$bayes->stop();

done_testing;
