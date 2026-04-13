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
use FindBin qw($Bin);
use Cwd qw(abs_path);

package MockSvc;
sub get_all_buckets { () }
sub is_bucket { 0 }
sub is_pseudo_bucket { 0 }
sub get_bucket_color { '#666666' }
sub get_bucket_word_count { 0 }
sub get_bucket_parameter { 0 }
sub get_bucket_word_list { () }
sub create_bucket { 1 }
sub delete_bucket { }
sub rename_bucket { }
sub clear_bucket { }
sub set_bucket_color { }
sub get_magnet_types { () }
sub get_buckets_with_magnets { () }
sub get_magnet_types_in_bucket { () }
sub get_magnets { () }
sub create_magnet { }
sub delete_magnet { }
sub remove_message_from_bucket { }
sub add_message_to_bucket { }
sub classify { 'ham' }
sub mangle_word { lc($_[1]) }
sub get_word_colors { () }
sub history_obj { undef }
sub bayes { undef }
sub get_stopword_list { () }
sub add_stopword { 1 }
sub remove_stopword { }
sub get_stopword_candidates { () }

package StubMQ;
sub post { }
sub register { }

package main;

require POPFile::API;
require POPFile::Configuration;

my $mq = bless {}, 'StubMQ';
my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $mock_svc = bless {}, 'MockSvc';

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($mock_svc);

my $app = $ui->build_app($mock_svc, 'test-session');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

my $root = abs_path("$Bin/..");
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
    ok(defined $en,            'English entry present');
    is($en->{name}, 'English', 'native name is English');
};

done_testing;
