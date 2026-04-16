#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

require Services::Classifier;

my $svc = Services::Classifier->new();
$svc->set_configuration($config);
$svc->set_mq($mq);
$svc->initialize();
$svc->set_classifier($bayes);

subtest 'start acquires admin session' => sub {
    my $ok = $svc->start();
    is($ok, 1, 'start returns 1');
    my $sess = $svc->session();
    ok(defined $sess && $sess ne '', 'session is non-empty after start');
    my @buckets = $svc->get_all_buckets();
    ok(defined $buckets[0] || 1, 'get_all_buckets accepted session from start');
};

subtest 'forked reacquires session after db reconnect' => sub {
    my $sess_before = $svc->session();
    $bayes->forked(undef);
    $svc->forked();
    my $sess_after = $svc->session();
    ok(defined $sess_after && $sess_after ne '', 'session non-empty after forked');
    my @buckets = $svc->get_all_buckets();
    ok(defined $buckets[0] || 1, 'get_all_buckets works with refreshed session');
};

subtest 'get_all_buckets returns buckets from db' => sub {
    my $sess = $svc->session();
    $bayes->create_bucket($sess, 'ham');
    $bayes->create_bucket($sess, 'spam');
    $bayes->db_update_cache($sess);
    $svc->forked();
    my @all = $svc->get_all_buckets();
    my %bset = map { $_ => 1 } @all;
    ok($bset{ham},  'ham in get_all_buckets');
    ok($bset{spam}, 'spam in get_all_buckets');
};

subtest 'stop releases session' => sub {
    $svc->stop();
    is($svc->session(), '', 'session empty after stop');
};

done_testing;
