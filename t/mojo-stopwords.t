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

$svc->add_stopword('viagra');

require POPFile::API;

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($svc);

my $app = $ui->build_app($svc, $session);
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/stopwords returns pre-seeded stopword' => sub {
    $t->get_ok('/api/v1/stopwords')
        ->status_is(200);
    my $words = $t->tx->res->json;
    ok((grep { $_ eq 'viagra' } @$words), 'viagra in stopwords');
};

subtest 'POST /api/v1/stopwords adds a word' => sub {
    $t->post_ok('/api/v1/stopwords', json => { word => 'spamword' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'GET /api/v1/stopwords reflects added word' => sub {
    $t->get_ok('/api/v1/stopwords')
        ->status_is(200);
    my $words = $t->tx->res->json;
    ok((grep { $_ eq 'spamword' } @$words), 'spamword added');
};

subtest 'POST /api/v1/stopwords with empty word returns 400' => sub {
    $t->post_ok('/api/v1/stopwords', json => { word => '' })
        ->status_is(400)
        ->json_has('/error');
};

subtest 'DELETE /api/v1/stopwords/:word removes a word' => sub {
    $t->delete_ok('/api/v1/stopwords/spamword')
        ->status_is(200)
        ->json_is('/ok', 1);
    $t->get_ok('/api/v1/stopwords')
        ->status_is(200);
    my $words = $t->tx->res->json;
    ok(!(grep { $_ eq 'spamword' } @$words), 'spamword removed');
};

subtest 'GET /api/v1/stopword-candidates returns array' => sub {
    $t->get_ok('/api/v1/stopword-candidates')
        ->status_is(200);
    my $candidates = $t->tx->res->json;
    ok(ref $candidates eq 'ARRAY', 'candidates is an array');
};

done_testing;
