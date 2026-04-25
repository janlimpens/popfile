#!/usr/bin/perl
BEGIN {
    @INC = grep { !/\/lib$/ && $_ ne 'lib' && !/thread-multi/ } @INC;
    require FindBin;
    require Cwd;
    my $root = Cwd::abs_path("$FindBin::Bin/..");
    require lib;
    lib->import("$root/local/lib/perl5");
    unshift @INC, "$FindBin::Bin/lib", $root;
}
use strict;
use warnings;

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

subtest 'GET /api/v1/health returns 503 when no loader injected' => sub {
    my $app = $api->build_app($svc, $svc->session());
    $app->log->level('fatal');
    my $t = Test::Mojo->new($app);
    $t->get_ok('/api/v1/health')->status_is(503);
    is($t->tx->res->json->{error}, 'health data not available', 'error message present');
};

subtest 'GET /api/v1/health returns ok when loader has no health reports' => sub {
    require POPFile::Loader;
    my $loader = POPFile::Loader->new();
    $api->set_loader($loader);
    my $app = $api->build_app($svc, $svc->session());
    $app->log->level('fatal');
    my $t = Test::Mojo->new($app);
    $t->get_ok('/api/v1/health')->status_is(200);
    is($t->tx->res->json->{status}, 'ok', 'overall status is ok');
    is(ref $t->tx->res->json->{modules}, 'HASH', 'modules is a hash');
};

subtest 'GET /api/v1/health reflects warning from loader health map' => sub {
    require POPFile::Loader;
    my $loader = POPFile::Loader->new();
    $loader->deliver('HLTH_SET', 'imap', 'warning', 'poll subprocess hanging');
    $api->set_loader($loader);
    my $app = $api->build_app($svc, $svc->session());
    $app->log->level('fatal');
    my $t = Test::Mojo->new($app);
    $t->get_ok('/api/v1/health')->status_is(200);
    is($t->tx->res->json->{status}, 'warning', 'overall status is warning');
    is($t->tx->res->json->{modules}{imap}{status}, 'warning', 'imap module status is warning');
    is($t->tx->res->json->{modules}{imap}{message}, 'poll subprocess hanging', 'message preserved');
};

subtest 'GET /api/v1/health shows critical when any module is critical' => sub {
    require POPFile::Loader;
    my $loader = POPFile::Loader->new();
    $loader->deliver('HLTH_SET', 'imap', 'warning', 'degraded');
    $loader->deliver('HLTH_SET', 'bayes', 'critical', 'db unreachable');
    $api->set_loader($loader);
    my $app = $api->build_app($svc, $svc->session());
    $app->log->level('fatal');
    my $t = Test::Mojo->new($app);
    $t->get_ok('/api/v1/health')->status_is(200);
    is($t->tx->res->json->{status}, 'critical', 'overall status is critical when any module is critical');
};

done_testing;
