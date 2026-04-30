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
$svc->add_message_to_bucket('ham', "$fixture_dir/ham.eml")
    for 1 .. 5;
$svc->create_bucket('spam');
$svc->add_message_to_bucket('spam', "$fixture_dir/spam.eml")
    for 1 .. 3;

require POPFile::API;

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($svc);

my $app = $ui->build_app($svc, $session);
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/words/search returns structure' => sub {
    $t->get_ok('/api/v1/words/search?q=meeting')
        ->status_is(200)
        ->json_has('/words')
        ->json_has('/total')
        ->json_has('/buckets');
    my $body = $t->tx->res->json;
    ok($body->{total} > 0, 'found matching words');
    ok(scalar $body->{buckets}->@* > 0, 'buckets listed');
    my $first = $body->{words}[0];
    ok(exists $first->{word}, 'word key present');
    ok(exists $first->{coverage}, 'coverage key present');
    ok(exists $first->{is_stopword}, 'is_stopword key present');
    ok(ref $first->{buckets} eq 'HASH', 'per-bucket hash present');
};

subtest 'GET /api/v1/words/search passes sort and dir params' => sub {
    $t->get_ok('/api/v1/words/search?q=meeting&sort=coverage&dir=desc')
        ->status_is(200);
};

subtest 'GET /api/v1/words/search with empty query returns all words' => sub {
    $t->get_ok('/api/v1/words/search?q=')
        ->status_is(200)
        ->json_has('/total');
    my $body = $t->tx->res->json;
    ok($body->{total} > 0, 'empty query returns all words');
};

done_testing;
