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
use File::Spec;
use FindBin qw($Bin);
use Cwd qw(abs_path);
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

my $root_dir = abs_path("$Bin/..");
my $lang_dir = File::Spec->catdir($root_dir, 'languages');
my @msg_files = sort glob "$lang_dir/*.msg";
my $file_count = scalar @msg_files;

subtest 'GET /api/v1/i18n returns locale list' => sub {
    $t->get_ok('/api/v1/i18n')
        ->status_is(200)
        ->json_is('/0/name', 'Arabic');
    my $body = $t->tx->res->json;
    is(scalar @$body, $file_count, 'one entry per .msg file');
    ok(exists $body->[0]{name}, 'has name');
    ok(exists $body->[0]{code}, 'has code');
    ok(exists $body->[0]{direction}, 'has direction');
};

subtest 'GET /api/v1/i18n English entry' => sub {
    $t->get_ok('/api/v1/i18n')
        ->status_is(200);
    my $body = $t->tx->res->json;
    my ($en) = grep { $_->{name} eq 'English' } @$body;
    ok(defined $en, 'English locale present');
    is($en->{code}, 'en', 'English code is en');
    is($en->{direction}, 'ltr', 'English direction is ltr');
};

subtest 'GET /api/v1/i18n/:locale English' => sub {
    $t->get_ok('/api/v1/i18n/English')
        ->status_is(200)
        ->json_has('/LanguageCode')
        ->json_is('/LanguageCode', 'en')
        ->json_is('/Language_Name', 'English');
};

subtest 'GET /api/v1/i18n/:locale not found' => sub {
    $t->get_ok('/api/v1/i18n/doesnotexist')
        ->status_is(404)
        ->json_has('/error');
};

subtest 'GET /api/v1/i18n/:locale sanitises input' => sub {
    $t->get_ok('/api/v1/i18n/../../etc/passwd')
        ->status_is(404);
};

subtest 'GET /api/v1/languages returns sorted list' => sub {
    $t->get_ok('/api/v1/languages')
        ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, $file_count, 'one entry per .msg file');
    ok(exists $body->[0]{code}, 'has code');
    ok(exists $body->[0]{name}, 'has name');
    my @names = map { $_->{name} } @$body;
    my @sorted = sort @names;
    is(\@names, \@sorted, 'list is sorted by name');
};

subtest 'GET /api/v1/languages English entry' => sub {
    $t->get_ok('/api/v1/languages')
        ->status_is(200);
    my $body = $t->tx->res->json;
    my ($en) = grep { $_->{code} eq 'English' } @$body;
    ok(defined $en, 'English entry present');
    is($en->{name}, 'English', 'native name is English');
};

done_testing;
