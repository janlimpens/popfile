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

$svc->create_bucket('news');
$svc->set_bucket_color('news', '#aaffaa');
$svc->add_message_to_bucket('news', "$fixture_dir/ham.eml")
    for 1 .. 5;

$svc->create_bucket('spam');
$svc->set_bucket_color('spam', '#ffaaaa');
$svc->add_message_to_bucket('spam', "$fixture_dir/spam.eml")
    for 1 .. 10;

require POPFile::API;

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($svc);

my $app = $ui->build_app($svc, $session);
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/buckets returns all buckets' => sub {
    $t->get_ok('/api/v1/buckets')
        ->status_is(200);
    my $body = $t->tx->res->json;
    my %by_name = map { $_->{name} => $_ } @$body;
    ok($by_name{spam}, 'spam bucket present');
    ok($by_name{news}, 'news bucket present');
    ok($by_name{unclassified}, 'unclassified bucket present');
    ok($by_name{spam}{word_count} > 0, 'spam has words');
    is($by_name{news}{color}, '#aaffaa', 'news color correct');
    is($by_name{unclassified}{pseudo} + 0, 1, 'unclassified is pseudo');
    is($by_name{spam}{pseudo} + 0, 0, 'spam is not pseudo');
};

subtest 'GET /api/v1/buckets/:name returns single bucket' => sub {
    $t->get_ok('/api/v1/buckets/spam')
        ->status_is(200)
        ->json_is('/name', 'spam')
        ->json_has('/word_count')
        ->json_is('/color', '#ffaaaa');
};

subtest 'GET /api/v1/buckets/:name unknown bucket returns 404' => sub {
    $t->get_ok('/api/v1/buckets/noexist')
        ->status_is(404)
        ->json_has('/error');
};

subtest 'POST /api/v1/buckets creates bucket' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'ham' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'POST /api/v1/buckets missing name returns 400' => sub {
    $t->post_ok('/api/v1/buckets', json => {})
        ->status_is(400)
        ->json_has('/error');
};

subtest 'POST /api/v1/buckets invalid name returns 422' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'Bad Name!' })
        ->status_is(422)
        ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:name' => sub {
    $t->delete_ok('/api/v1/buckets/spam')
        ->status_is(200)
        ->json_is('/ok', 1);
    ok(!$svc->is_bucket('spam'), 'spam bucket removed');
};

done_testing;
