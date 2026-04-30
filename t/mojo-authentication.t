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
use File::Temp qw(tempdir tempfile);
use TestMocks;

my $tmpdir = tempdir(CLEANUP => 1);
my ($fh, $fixture_file) = tempfile(DIR => $tmpdir, SUFFIX => '.msg');
print $fh "From: alice\@example.com\r\nSubject: Test\r\n\r\nham\r\n";
close $fh;

my %buckets = (ham => '#aaffaa', spam => '#ffaaaa');
my %slots = (
    1 => { fields => [1, 'alice@example.com', 'bob@example.com', '', 'Test',
            '2024-01-01', 'abc', time(), 'ham', undef, 1, '', 100],
            file => $fixture_file, bucket => 'ham' });

my $mock_hist = TestMocks::MockHist->new(slots => \%slots);
my $mock_svc  = TestMocks::MockSvc->new(buckets => \%buckets, hist => $mock_hist);
my $mq        = TestMocks::StubMQ->new();

require POPFile::API;
require POPFile::Configuration;

sub _build_app ($password = '') {
    my $config = POPFile::Configuration->new();
    $config->set_configuration($config);
    $config->set_mq($mq);
    $config->initialize();
    $config->set_started(1);
    $config->parameter('api_local', 1);
    my $ui = POPFile::API->new();
    $ui->set_configuration($config);
    $ui->set_mq($mq);
    $ui->initialize();
    $ui->set_service($mock_svc);
    $config->parameter('api_password', $password)
        if $password ne '';
    my $app = $ui->build_app($mock_svc, 'test-session');
    $app->log->level('fatal');
    return $app
}

subtest 'no password set — API is open without token' => sub {
    my $t = Test::Mojo->new(_build_app(''));
    $t->get_ok('/api/v1/buckets')
        ->status_is(200)
        ->json_has('/0/name');
};

subtest 'password set — API rejects requests without token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets')
        ->status_is(401)
        ->json_is('/error', 'Unauthorized');
};

subtest 'password set — API allows requests with correct token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200)
        ->json_has('/0/name');
};

subtest 'password set — API rejects wrong token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'wrong' })
        ->status_is(401);
};

subtest 'password set — POST requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->post_ok('/api/v1/buckets', json => { name => 'test' })
        ->status_is(401);
    $t->post_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'sekret' }, json => { name => 'test' })
        ->status_is(200);
};

subtest 'password set — static files still served without token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/index.html')
        ->status_is(200);
};

subtest 'no password — history reclassify works without token' => sub {
    my $t = Test::Mojo->new(_build_app(''));
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'password set — history reclassify requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(401);
    $t->post_ok('/api/v1/history/1/reclassify' => { 'X-POPFile-Token' => 'sekret' }, json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'password set — config read/write requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/config')
        ->status_is(401);
    $t->get_ok('/api/v1/config' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200);
    $t->put_ok('/api/v1/config' => { 'X-POPFile-Token' => 'sekret' }, json => {})
        ->status_is(200);
};

subtest 'password set — IMAP endpoints require token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/imap/folders')
        ->status_is(401);
    $t->get_ok('/api/v1/imap/folders' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200);
};

subtest 'password set — health endpoint requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/health')
        ->status_is(401);
};

done_testing;
