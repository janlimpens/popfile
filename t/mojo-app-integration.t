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
use strict;
use warnings;

use Test2::V0;
use Test::Mojo;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();

my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

require Services::Classifier;
my $svc = Services::Classifier->new();
TestHelper::wire($svc, $config, $mq);
$svc->set_classifier($bayes);
$svc->initialize();
$svc->start();

require POPFile::API;
my $api = POPFile::API->new();
TestHelper::wire($api, $config, $mq);
$api->initialize();

my $app = $api->build_app($svc, $svc->session());
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

# -----------------------------------------------------------------------
subtest 'GET /api/v1/buckets returns JSON array' => sub {
    $t->get_ok('/api/v1/buckets')
      ->status_is(200);
    ok(ref $t->tx->res->json eq 'ARRAY', 'response is a JSON array');
};

# -----------------------------------------------------------------------
subtest 'POST /api/v1/buckets creates a bucket' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'spam' })
      ->status_is(200)
      ->json_is('/ok', 1);
};

# -----------------------------------------------------------------------
subtest 'GET /api/v1/buckets contains newly created bucket' => sub {
    $t->get_ok('/api/v1/buckets')
      ->status_is(200);
    my $list = $t->tx->res->json;
    ok((grep { $_->{name} eq 'spam' } @$list), 'spam bucket appears in list');
};

# -----------------------------------------------------------------------
subtest 'GET /api/v1/status returns 200' => sub {
    $t->get_ok('/api/v1/status')
      ->status_is(200);
};

# -----------------------------------------------------------------------
subtest 'GET /api/v1/config has mojo_ui_locale key' => sub {
    $t->get_ok('/api/v1/config')
      ->status_is(200)
      ->json_has('/mojo_ui_locale');
};

# -----------------------------------------------------------------------
subtest 'DELETE /api/v1/buckets/:name removes the bucket' => sub {
    $t->delete_ok('/api/v1/buckets/spam')
      ->status_is(200)
      ->json_is('/ok', 1);

    $t->get_ok('/api/v1/buckets')
      ->status_is(200);
    my $list = $t->tx->res->json;
    ok(!(grep { $_->{name} eq 'spam' } @$list), 'spam no longer in bucket list');
};

# -----------------------------------------------------------------------
$svc->stop();
$bayes->stop();

done_testing;
