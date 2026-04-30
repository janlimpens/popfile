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
$svc->create_bucket('spam');

require POPFile::API;

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($svc);

my $app = $ui->build_app($svc, $session);
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/magnet-types returns built-in types' => sub {
    $t->get_ok('/api/v1/magnet-types')
        ->status_is(200);
    my $types = $t->tx->res->json;
    my %expect = (from => 'From', to => 'To', subject => 'Subject', cc => 'Cc');
    is($types->{from}, 'From', 'from type present');
    is($types->{to}, 'To', 'to type present');
    is($types->{subject}, 'Subject', 'subject type present');
    is($types->{cc}, 'Cc', 'cc type present');
};

subtest 'GET /api/v1/magnets empty when no magnets exist' => sub {
    $t->get_ok('/api/v1/magnets')
        ->status_is(200)
        ->json_is({});
};

subtest 'POST /api/v1/magnets returns 400 for missing or empty fields' => sub {
    $t->post_ok('/api/v1/magnets', json => {})
        ->status_is(400)
        ->json_has('/error');
    $t->post_ok('/api/v1/magnets', json => { bucket => 'spam' })
        ->status_is(400)
        ->json_has('/error');
    $t->post_ok('/api/v1/magnets', json => { bucket => 'spam', type => 'from' })
        ->status_is(400)
        ->json_has('/error');
    $t->post_ok('/api/v1/magnets',
        json => { bucket => '', type => 'from', value => 'evil@example.com' })
        ->status_is(400)
        ->json_has('/error');
};

subtest 'POST /api/v1/magnets creates a magnet' => sub {
    $t->post_ok('/api/v1/magnets',
        json => { bucket => 'spam', type => 'from', value => 'evil@example.com' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'GET /api/v1/magnets reflects created magnet' => sub {
    $t->get_ok('/api/v1/magnets')
        ->status_is(200)
        ->json_is('/spam/from/0', 'evil@example.com');
};

subtest 'DELETE /api/v1/magnets removes a magnet' => sub {
    $t->delete_ok('/api/v1/magnets',
        json => { bucket => 'spam', type => 'from', value => 'evil@example.com' })
        ->status_is(200)
        ->json_is('/ok', 1);
    $t->get_ok('/api/v1/magnets')
        ->status_is(200)
        ->json_is({});
};

done_testing;
