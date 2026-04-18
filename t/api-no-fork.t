#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Test::Mojo;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

require Services::Classifier;
my $svc = Services::Classifier->new();
TestHelper::wire($svc, $config, $mq);
$svc->set_classifier($bayes);
$svc->initialize();
$svc->start();

require POPFile::API;
my $api = POPFile::API->new();
TestHelper::wire($api, $config, $mq);
$api->initialize();
$api->set_service($svc);

subtest 'run_server removed from POPFile::API' => sub {
    ok(!POPFile::API->can('run_server'), 'run_server() has been removed');
};

subtest 'forked removed from Services::Classifier' => sub {
    ok(!Services::Classifier->can('forked'), 'Services::Classifier::forked() has been removed');
};

subtest 'start() registers in-process Mojo daemon without fork' => sub {
    $api->start();
    ok($api->can('daemon') && defined $api->daemon(),
        'daemon is set up in-process after start()');
    if ($api->can('daemon') && defined $api->daemon()) {
        isa_ok($api->daemon(), 'Mojo::Server::Daemon');
    }
    $api->stop();
};

$svc->stop();
$bayes->stop();

done_testing;
