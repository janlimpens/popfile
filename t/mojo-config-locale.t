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
use Encode qw(decode);

require FindBin;
require Cwd;
my $root = Cwd::abs_path("$FindBin::Bin/..");

require UI::Mojo;
require POPFile::Configuration;

my $mq = bless {}, 'StubMQ';
sub StubMQ::post     {}
sub StubMQ::register {}

my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->set_popfile_root("$root/");
$config->initialize();
$config->set_started(1);

my $ui = UI::Mojo->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();

my $app = $ui->build_app(undef, '');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'mojo_ui_locale config key is registered and returned' => sub {
    $t->get_ok('/api/v1/config')
      ->status_is(200)
      ->json_has('/mojo_ui_locale', 'mojo_ui_locale key exists in config');
    my $val = $t->tx->res->json->{mojo_ui_locale};
    is($val, '', 'default locale is empty string (auto-detect)');
};

subtest 'PUT /api/v1/config persists mojo_ui_locale' => sub {
    $t->put_ok('/api/v1/config', json => { mojo_ui_locale => 'Deutsch' })
      ->status_is(200)
      ->json_is('/ok', 1);
    $t->get_ok('/api/v1/config')
      ->status_is(200)
      ->json_is('/mojo_ui_locale', 'Deutsch', 'locale persisted across GET');
};

subtest 'GET /api/v1/i18n returns locale list' => sub {
    $t->get_ok('/api/v1/i18n')
      ->status_is(200);
    my $locales = $t->tx->res->json;
    ok(ref $locales eq 'ARRAY', 'returns array');
    my ($english) = grep { $_->{name} eq 'English' } @$locales;
    ok(defined $english, 'English locale present');
    is($english->{code}, 'en', 'English code is en');
};

subtest 'GET /api/v1/i18n/:locale returns strings for English' => sub {
    $t->get_ok('/api/v1/i18n/English')
      ->status_is(200);
    my $strings = $t->tx->res->json;
    ok(ref $strings eq 'HASH', 'returns hash of strings');
    ok(exists $strings->{NavHistory}, 'NavHistory key present');
};

subtest 'GET /api/v1/i18n/:locale response is valid UTF-8' => sub {
    $t->get_ok('/api/v1/i18n/Deutsch')
      ->status_is(200);
    my $body = $t->tx->res->body;
    my $decoded = eval { decode('UTF-8', $body, Encode::FB_CROAK) };
    ok(!$@, 'response body is valid UTF-8')
        or diag "UTF-8 decode error: $@";
};

subtest 'JSON response Content-Type is application/json' => sub {
    $t->get_ok('/api/v1/config')
      ->status_is(200)
      ->content_type_like(qr{application/json});
};

done_testing;
