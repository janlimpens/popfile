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
use File::Spec;
use Cwd qw(abs_path);
use FindBin qw($Bin);

my $root = abs_path("$Bin/..");
$ENV{POPFILE_ROOT} = $root;

require Mojolicious;
require POPFile::API::Controller::Locale;

my $app = Mojolicious->new();
$app->log->level('fatal');

push $app->routes->namespaces->@*, 'POPFile::API::Controller';

my $r = $app->routes;
$r->get('/api/v1/i18n')->to('Locale#list_locales');
$r->get('/api/v1/i18n/:locale')->to('Locale#get_locale');
$r->get('/api/v1/languages')->to('Locale#list_languages');

my $t = Test::Mojo->new($app);

my $lang_dir = File::Spec->catdir($root, 'languages');
my @msg_files = sort glob "$lang_dir/*.msg";
my $file_count = scalar @msg_files;

subtest 'GET /api/v1/i18n returns locale list' => sub {
    $t->get_ok('/api/v1/i18n')
      ->status_is(200)
      ->json_is('/0/name', 'Arabic');
    my $body = $t->tx->res->json;
    is(scalar @$body, $file_count, 'one entry per .msg file');
    ok(exists $body->[0]{name},      'has name');
    ok(exists $body->[0]{code},      'has code');
    ok(exists $body->[0]{direction}, 'has direction');
};

subtest 'GET /api/v1/i18n English entry' => sub {
    $t->get_ok('/api/v1/i18n')
      ->status_is(200);
    my $body = $t->tx->res->json;
    my ($en) = grep { $_->{name} eq 'English' } @$body;
    ok(defined $en,             'English locale present');
    is($en->{code},      'en',  'English code is en');
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
    ok(defined $en,               'English entry present');
    is($en->{name}, 'English',    'native name is English');
};

done_testing;
