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

subtest 'get_all_buckets returns buckets from db' => sub {
    my $sess = $svc->session();
    $bayes->create_bucket($sess, 'ham');
    $bayes->create_bucket($sess, 'spam');
    $bayes->db_update_cache($sess);
    my @all = $svc->get_all_buckets();
    my %bset = map { $_ => 1 } @all;
    ok($bset{ham},  'ham in get_all_buckets');
    ok($bset{spam}, 'spam in get_all_buckets');
};

subtest 'stop releases session' => sub {
    $svc->stop();
    is($svc->session(), '', 'session empty after stop');
};

subtest 'Unicode bucket names' => sub {
    my $session = $bayes->get_session_key('admin', '');
    my $uname = "Test_Unicode_\x{00e4}\x{00f6}\x{00fc}";
    ok($bayes->create_bucket($session, $uname), "create bucket '$uname'");
    ok($bayes->is_bucket($session, $uname), 'is_bucket returns true');
    ok($bayes->delete_bucket($session, $uname), "delete bucket '$uname'");
    $bayes->release_session_key($session);
};

subtest 'Unicode bucket names with spaces' => sub {
    my $session = $bayes->get_session_key('admin', '');
    ok($bayes->create_bucket($session, "Pers\x{f6}nliches"), 'create Persönliches');
    ok($bayes->create_bucket($session, "Imposto de Renda"), 'create with spaces');
    ok($bayes->is_bucket($session, "Pers\x{f6}nliches"), 'is_bucket Persönliches');
    ok($bayes->is_bucket($session, "Imposto de Renda"), 'is_bucket with spaces');
    ok($bayes->delete_bucket($session, "Pers\x{f6}nliches"), 'delete Persönliches');
    ok($bayes->delete_bucket($session, "Imposto de Renda"), 'delete with spaces');
    $bayes->release_session_key($session);
};

subtest 'Reject dangerous bucket names' => sub {
    my $session = $bayes->get_session_key('admin', '');
    ok(!$bayes->create_bucket($session, '../etc'), 'reject path traversal');
    ok(!$bayes->create_bucket($session, 'foo/bar'), 'reject slash');
    ok(!$bayes->create_bucket($session, "foo\x{00}bar"), 'reject null byte');
    ok(!$bayes->is_bucket($session, '../etc'), 'path traversal is not a bucket');
    $bayes->release_session_key($session);
};

done_testing;
