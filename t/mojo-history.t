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
print $fh "From: alice\@example.com\r\nSubject: Test\r\n\r\nThis is a ham message.\r\n";
close $fh;

my %slots = (
    1 => { fields => [1, 'alice@example.com', 'bob@example.com', '', 'Test', '2024-01-01', 'abc', time(), 'ham', undef, 1, '', 100], file => $fixture_file, bucket => 'ham' },
    2 => { fields => [2, 'spammer@evil.com',  'bob@example.com', '', 'Win', '2024-01-02', 'def', time(), 'unclassified', undef, 2, '', 200], file => $fixture_file, bucket => 'unclassified' },
);

my %buckets = (ham => '#aaffaa', spam => '#ffaaaa');

my $mock_hist = TestMocks::MockHist->new(slots => \%slots);
my $mock_svc  = TestMocks::MockSvc->new(buckets => \%buckets, hist => $mock_hist);
my $mq = TestMocks::StubMQ->new();

require POPFile::API;
require POPFile::Configuration;

my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($mock_svc);

my $app = $ui->build_app($mock_svc, 'test-session');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/history returns items and total' => sub {
    $t->get_ok('/api/v1/history')
      ->status_is(200)
      ->json_has('/items')
      ->json_has('/total');
    my $data = $t->tx->res->json;
    is($data->{total}, 2, 'total matches slot count');
    is(scalar $data->{items}->@*, 2, 'items count matches');
};

subtest 'GET /api/v1/history items include correct bucket color' => sub {
    $t->get_ok('/api/v1/history')
      ->status_is(200);
    my $items = $t->tx->res->json->{items};
    my ($ham_item) = grep { $_->{bucket} eq 'ham' } @$items;
    ok(defined $ham_item, 'ham item found');
    is($ham_item->{color}, '#aaffaa', 'ham bucket color is correct');
    my ($unclass_item) = grep { $_->{bucket} eq 'unclassified' } @$items;
    ok(defined $unclass_item, 'unclassified item found');
    is($unclass_item->{color}, '#666666', 'unknown bucket falls back to gray');
};

subtest 'GET /api/v1/history pagination' => sub {
    $t->get_ok('/api/v1/history?page=1&per_page=1')
      ->status_is(200);
    my $data = $t->tx->res->json;
    is($data->{total}, 2, 'total still 2');
    is(scalar $data->{items}->@*, 1, 'per_page=1 returns 1 item');
};

subtest 'GET /api/v1/history/:slot valid slot' => sub {
    $t->get_ok('/api/v1/history/1')
      ->status_is(200)
      ->json_has('/body')
      ->json_has('/word_colors');
    my $data = $t->tx->res->json;
    like($data->{body}, qr/ham/, 'body contains message text');
};

subtest 'GET /api/v1/history/:slot invalid slot returns 404' => sub {
    $t->get_ok('/api/v1/history/999')
      ->status_is(404);
};

subtest 'POST /api/v1/history/:slot/reclassify changes bucket' => sub {
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
      ->status_is(200)
      ->json_is('/ok', 1);
    is($slots{1}{bucket}, 'spam', 'bucket updated in mock');
};

subtest 'POST /api/v1/history/:slot/reclassify unknown bucket returns 422' => sub {
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'nosuchbucket' })
      ->status_is(422)
      ->json_has('/error');
};

subtest 'POST /api/v1/history/bulk-reclassify returns updated count' => sub {
    $slots{1}{bucket} = 'ham';
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { slots => [1, 2], bucket => 'spam' })
      ->status_is(200)
      ->json_has('/updated');
    my $data = $t->tx->res->json;
    ok($data->{updated} >= 1, 'at least one slot updated');
};

subtest 'POST /api/v1/history/bulk-reclassify missing params returns 400' => sub {
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { slots => [] })
      ->status_is(400);
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { bucket => 'spam' })
      ->status_is(400);
};

subtest 'POST /api/v1/history/reclassify-unclassified returns updated and total' => sub {
    $slots{2}{bucket} = 'unclassified';
    $t->post_ok('/api/v1/history/reclassify-unclassified')
      ->status_is(200)
      ->json_has('/updated')
      ->json_has('/total');
};

done_testing;
