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

require POPFile::API;

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($svc);

my $app = $ui->build_app($svc, $session);
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/stopwords returns module stopwords' => sub {
    $t->get_ok('/api/v1/stopwords')
        ->status_is(200);
    my $words = $t->tx->res->json;
    ok(scalar @$words > 0, 'stopwords list is not empty');
    ok((grep { $_ eq 'the' } @$words), 'common english stopword present');
};

subtest 'POST /api/v1/stopwords removed — returns 404' => sub {
    $t->post_ok('/api/v1/stopwords', json => { word => 'test' })
        ->status_is(404);
};

subtest 'DELETE /api/v1/stopwords/:word removed — returns 404' => sub {
    $t->delete_ok('/api/v1/stopwords/test')
        ->status_is(404);
};

subtest 'GET /api/v1/stopword-candidates returns array' => sub {
    $t->get_ok('/api/v1/stopword-candidates')
        ->status_is(200);
    my $candidates = $t->tx->res->json;
    ok(ref $candidates eq 'ARRAY', 'candidates is an array');
};

done_testing;
