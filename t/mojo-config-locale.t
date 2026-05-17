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
use feature 'try';
use Encode qw(decode);
use FindBin qw($Bin);
use Cwd qw(abs_path);
use TestMocks;

my $root = abs_path("$Bin/..");

require POPFile::API;
require POPFile::Configuration;

my $mq = TestMocks::StubMQ->new();

my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->set_popfile_root("$root/");
$config->initialize();
$config->set_started(1);

use File::Temp qw(tempdir);
my $tmpdir = tempdir(CLEANUP => 1);
$ENV{POPFILE_PATH} = "$tmpdir/config.json";

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();

my $app = $ui->build_app(undef, '');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'api_locale config key is registered and returned' => sub {
    $t->get_ok('/api/v1/config')
      ->status_is(200)
      ->json_has('/api_locale', 'api_locale key exists in config');
    my $val = $t->tx->res->json->{api_locale};
    is($val, '', 'default locale is empty string (auto-detect)');
};

subtest 'PUT /api/v1/config persists api_locale' => sub {
    $t->put_ok('/api/v1/config', json => { api_locale => 'de' })
      ->status_is(200)
      ->json_is('/ok', 1);
    ok(-e "$tmpdir/config.json", 'config.json written');
    require POPFile::ConfigFile;
    my $data = POPFile::ConfigFile->new()->load("$tmpdir/config.json");
    is($data->{api}{locale}, 'de', 'locale persisted on disk');
};

subtest 'GET /api/v1/i18n returns locale list' => sub {
    $t->get_ok('/api/v1/i18n')
      ->status_is(200);
    my $locales = $t->tx->res->json;
    ok(ref $locales eq 'ARRAY', 'returns array');
    my ($english) = grep { $_->{name} eq 'en' } @$locales;
    ok(defined $english, 'English locale present');
    is($english->{code}, 'en', 'English code is en');
};

subtest 'GET /api/v1/i18n/:locale returns strings for English' => sub {
    $t->get_ok('/api/v1/i18n/en')
      ->status_is(200);
    my $strings = $t->tx->res->json;
    ok(ref $strings eq 'HASH', 'returns hash of strings');
    ok(exists $strings->{NavHistory}, 'NavHistory key present');
};

subtest 'GET /api/v1/i18n/:locale response is valid UTF-8' => sub {
    $t->get_ok('/api/v1/i18n/de')
      ->status_is(200);
    my $body = $t->tx->res->body;
    my $error;
    my $decoded = do { try { decode('UTF-8', $body, Encode::FB_CROAK) }
        catch ($e) { $error = $e; undef } };
    ok(defined $decoded, 'response body is valid UTF-8')
        or diag "UTF-8 decode error: $error";
};

subtest 'JSON response Content-Type is application/json' => sub {
    $t->get_ok('/api/v1/config')
      ->status_is(200)
      ->content_type_like(qr{application/json});
};

subtest 'imap_password accepted in config update without errors' => sub {
    $t->put_ok('/api/v1/config', json => {
        imap_hostname => 'mail.example.com',
        imap_login => 'alice',
        imap_password => 's3cret',
    })->status_is(200)->json_is('/ok', 1);
    require POPFile::ConfigFile;
    my $data = POPFile::ConfigFile->new()->load("$tmpdir/config.json");
    is($data->{imap}{hostname}, 'mail.example.com', 'hostname persisted');
    is($data->{imap}{login}, 'alice', 'login persisted');
    is($data->{imap}{password}, 's3cret', 'password persisted but not logged');
};

done_testing;
