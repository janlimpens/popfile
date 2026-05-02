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

$svc->create_bucket('spam');
$svc->add_message_to_bucket('spam', "$fixture_dir/spam.eml")
    for 1 .. 10;
my $spam_id = $svc->get_bucket_id('spam');

$svc->create_bucket('ham');
$svc->add_message_to_bucket('ham', "$fixture_dir/ham.eml")
    for 1 .. 10;
my $ham_id = $svc->get_bucket_id('ham');

require POPFile::API;

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($svc);

my $app = $ui->build_app($svc, $session);
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/buckets/:id/words/accuracy returns correct structure' => sub {
    $t->get_ok("/api/v1/buckets/$spam_id/words/accuracy")
        ->status_is(200)
        ->json_has('/words')
        ->json_has('/total')
        ->json_has('/page')
        ->json_has('/per_page');
    my $body = $t->tx->res->json;
    ok($body->{total} > 0, 'total is positive');
    is($body->{page}, 1, 'page defaults to 1');
    is(scalar $body->{words}->@*, $body->{total}, 'words count matches total');
    my $first = $body->{words}[0];
    ok(exists $first->{word}, 'word key present');
    ok(exists $first->{count}, 'count key present');
};

subtest 'GET /api/v1/buckets/:id/words/accuracy accepts page and per_page params' => sub {
    $t->get_ok("/api/v1/buckets/$spam_id/words/accuracy?page=1&per_page=10")
        ->status_is(200)
        ->json_is('/page', 1)
        ->json_is('/per_page', 10);
};

subtest 'GET /api/v1/buckets/:id/words/accuracy unknown id returns 404' => sub {
    $t->get_ok('/api/v1/buckets/99999/words/accuracy')
        ->status_is(404)
        ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:id/word/:word removes a word' => sub {
    my $word = $svc->get_words_for_bucket('spam', per_page => 1)->{words}[0]{word};
    $t->delete_ok("/api/v1/buckets/$spam_id/word/$word")
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'POST /api/v1/buckets/:id/word/:word/move moves a word' => sub {
    my $word = $svc->get_words_for_bucket('spam', per_page => 1)->{words}[0]{word};
    my $spam_before = $svc->get_count_for_word('spam', $word);
    $t->post_ok("/api/v1/buckets/$spam_id/word/$word/move",
        json => { to => 'ham' })
        ->status_is(200)
        ->json_is('/ok', 1);
    my $spam_after = $svc->get_count_for_word('spam', $word);
    my $ham_count = $svc->get_count_for_word('ham', $word);
    ok($ham_count > 0, 'ham now has the word');
    is($spam_after, 0, 'spam no longer has the word');
};

subtest 'POST /api/v1/buckets/:id/word/:word/move missing to returns 400' => sub {
    $t->post_ok("/api/v1/buckets/$spam_id/word/money/move", json => {})
        ->status_is(400)
        ->json_has('/error');
};

done_testing;
