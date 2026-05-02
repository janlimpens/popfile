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
$svc->set_bucket_color('ham', '#00cc00');
$svc->set_bucket_parameter('ham', 'fpcount', 1);
$svc->set_bucket_parameter('ham', 'fncount', 2);
$svc->add_message_to_bucket('ham', "$fixture_dir/ham.eml")
    for 1 .. 3;
my $ham_id = $svc->get_bucket_id('ham');

$svc->create_bucket('spam');
$svc->set_bucket_color('spam', '#cc0000');
$svc->add_message_to_bucket('spam', "$fixture_dir/spam.eml")
    for 1 .. 2;
my $spam_id = $svc->get_bucket_id('spam');

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
    my %names = map { $_->{name} => $_ } @$body;
    ok(exists $names{ham}, 'ham bucket present');
    ok(exists $names{spam}, 'spam bucket present');
    ok(exists $names{unclassified}, 'unclassified pseudo-bucket present');
    is($names{ham}{color}, '#00cc00', 'ham color correct');
    ok($names{ham}{word_count} > 0, 'ham has words');
    is($names{spam}{color}, '#cc0000', 'spam color correct');
    ok($names{spam}{word_count} > 0, 'spam has words');
    is($names{unclassified}{pseudo}, 1, 'unclassified is pseudo');
    ok($names{ham}{id} > 0, 'ham has id');
};

subtest 'GET /api/v1/buckets/:id found' => sub {
    $t->get_ok("/api/v1/buckets/$ham_id")
        ->status_is(200)
        ->json_is('/name', 'ham')
        ->json_is('/id', $ham_id)
        ->json_is('/color', '#00cc00')
        ->json_has('/word_count')
        ->json_is('/fpcount', 1)
        ->json_is('/fncount', 2);
};

subtest 'GET /api/v1/buckets/:id pseudo bucket found' => sub {
    my $u_id = $svc->get_bucket_id('unclassified');
    $t->get_ok("/api/v1/buckets/$u_id")
        ->status_is(200)
        ->json_is('/name', 'unclassified')
        ->json_is('/pseudo', 1);
};

subtest 'GET /api/v1/buckets/:id not found' => sub {
    $t->get_ok('/api/v1/buckets/99999')
        ->status_is(404)
        ->json_has('/error');
};

subtest 'POST /api/v1/buckets success' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'newbucket' })
        ->status_is(200)
        ->json_is('/ok', 1)
        ->json_has('/id');
    ok($svc->is_bucket('newbucket'), 'bucket created');
};

subtest 'POST /api/v1/buckets with color' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'coloredbucket', color => '#ff0000' })
        ->status_is(200)
        ->json_is('/ok', 1)
        ->json_has('/id');
    is($svc->get_bucket_color('coloredbucket'), '#ff0000', 'color set');
};

subtest 'POST /api/v1/buckets missing name' => sub {
    $t->post_ok('/api/v1/buckets', json => {})
        ->status_is(400)
        ->json_has('/error');
};

subtest 'POST /api/v1/buckets invalid chars in name' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'Bad/Name' })
        ->status_is(422)
        ->json_has('/error');
};

subtest 'POST /api/v1/buckets already exists' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'ham' })
        ->status_is(409)
        ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:id' => sub {
    $svc->create_bucket('tobedeleted');
    my $del_id = $svc->get_bucket_id('tobedeleted');
    $t->delete_ok("/api/v1/buckets/$del_id")
        ->status_is(200)
        ->json_is('/ok', 1);
    ok(!$svc->is_bucket('tobedeleted'), 'bucket removed');
};

subtest 'PUT /api/v1/buckets/:id/rename' => sub {
    $svc->create_bucket('oldbucket');
    my $old_id = $svc->get_bucket_id('oldbucket');
    $t->put_ok("/api/v1/buckets/$old_id/rename", json => { new_name => 'renamedto' })
        ->status_is(200)
        ->json_is('/ok', 1);
    ok(!$svc->is_bucket('oldbucket'), 'old name removed');
    ok($svc->is_bucket('renamedto'), 'new name exists');
};

subtest 'PUT /api/v1/buckets/:id/rename missing new_name' => sub {
    $t->put_ok("/api/v1/buckets/$ham_id/rename", json => {})
        ->status_is(400)
        ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:id/words clears bucket' => sub {
    $t->delete_ok("/api/v1/buckets/$spam_id/words")
        ->status_is(200)
        ->json_is('/ok', 1);
    is($svc->get_bucket_word_count('spam'), 0, 'word count cleared');
};

subtest 'PUT /api/v1/buckets/:id/params color' => sub {
    $t->put_ok("/api/v1/buckets/$spam_id/params", json => { color => '#0000ff' })
        ->status_is(200)
        ->json_is('/ok', 1);
    is($svc->get_bucket_color('spam'), '#0000ff', 'color updated');
};

subtest 'GET /api/v1/buckets/:id/words returns word list' => sub {
    $t->get_ok("/api/v1/buckets/$ham_id/words")
        ->status_is(200);
    my $body = $t->tx->res->json;
    ok(scalar @$body > 0, 'words returned');
    my %words = map { $_->{word} => $_ } @$body;
    ok(exists $words{meeting}, 'word "meeting" in ham');
    is($words{meeting}{count}, 6, 'meeting count is 6 (subject+body x3)');
};

done_testing;
