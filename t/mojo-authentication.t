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
use v5.38;
use warnings;

use Test2::V0;
use Test::Mojo;
use TestHelper;

my ($config, $mq, $svc, $hist, $bayes, $tmpdir) = TestHelper::setup_mojo_services();
my $session = $svc->session();
my $fixture_dir = "$TestHelper::REPO_ROOT/t/fixtures";

$svc->create_bucket('ham');
$svc->create_bucket('spam');

require POPFile::API;

sub _build_app ($password = '', $local = 1) {
    my $ui = POPFile::API->new();
    $ui->set_configuration($config);
    $ui->set_mq($mq);
    $ui->initialize();
    $ui->set_service($svc);
    $config->parameter('api_local', $local);
    $config->parameter('api_password', $password);
    my $app = $ui->build_app($svc, $session);
    $app->log->level('fatal');
    return $app
}

subtest 'no password set — API is open without token' => sub {
    my $t = Test::Mojo->new(_build_app(''));
    $t->get_ok('/api/v1/buckets')
        ->status_is(200)
        ->json_has('/0/name');
};

subtest 'password set — GET works without token, POST requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets')
        ->status_is(200);
    $t->post_ok('/api/v1/buckets', json => { name => 'test1' })
        ->status_is(403);
    $t->post_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'sekret' }, json => { name => 'test1' })
        ->status_is(200);
    $svc->delete_bucket('test1');
};

subtest 'password set — wrong token rejected on POST' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->post_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'wrong' }, json => { name => 't' })
        ->status_is(403);
};

subtest 'password set — static files still served without token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/index.html')
        ->status_is(200);
};

subtest 'password set — config GET works, PUT requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/config')
        ->status_is(200);
    $t->put_ok('/api/v1/config', json => {})
        ->status_is(403);
    $t->put_ok('/api/v1/config' => { 'X-POPFile-Token' => 'sekret' }, json => {})
        ->status_is(200);
};

subtest 'password set — IMAP GET works, POST requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/imap/folders')
        ->status_is(200);
};

subtest 'password set — health GET works without token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/health')
        ->status_is(503);
};

subtest 'local=0 — GET also requires token when not local-only' => sub {
    my $t = Test::Mojo->new(_build_app('sekret', 0));
    $t->get_ok('/api/v1/buckets')
        ->status_is(403);
    $t->get_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200)
        ->json_has('/0/name');
};

done_testing;
