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

my @all_buckets = ('news', 'spam', 'unclassified');
my %pseudo      = (unclassified => 1);
my %colors      = (news => '#aaffaa', spam => '#ffaaaa', unclassified => '#666666');
my %word_counts = (news => 10, spam => 20, unclassified => 0);

package MockSvc;
sub get_all_buckets        { @all_buckets }
sub is_bucket              { !$pseudo{$_[1]} && grep { $_ eq $_[1] } @all_buckets }
sub is_pseudo_bucket       { $pseudo{$_[1]} // 0 }
sub get_bucket_color       { $colors{$_[1]} // '#666666' }
sub get_bucket_word_count  { $word_counts{$_[1]} // 0 }
sub get_bucket_parameter   { 0 }
sub get_bucket_word_list   { () }
sub create_bucket          { 1 }
sub delete_bucket          { }
sub rename_bucket          { }
sub clear_bucket           { }
sub set_bucket_color       { }
sub get_magnet_types       { () }
sub get_buckets_with_magnets    { () }
sub get_magnet_types_in_bucket  { () }
sub get_magnets            { () }
sub create_magnet          { }
sub delete_magnet          { }
sub remove_message_from_bucket  { }
sub add_message_to_bucket  { }
sub classify               { 'ham' }
sub mangle_word            { lc($_[1]) }
sub get_word_colors        { () }
sub get_stopword_list      { () }
sub add_stopword           { 1 }
sub remove_stopword        { }
sub get_stopword_candidates { () }
sub history_obj            { undef }
sub bayes                  { undef }

package StubMQ;
sub post { }
sub register { }

package main;

require POPFile::API;
require POPFile::Configuration;

my $mq     = bless {}, 'StubMQ';
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

subtest 'GET /api/v1/buckets returns all buckets' => sub {
    $t->get_ok('/api/v1/buckets')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, 3, 'three buckets returned');
    my %by_name = map { $_->{name} => $_ } @$body;
    ok($by_name{spam},          'spam bucket present');
    ok($by_name{news},          'news bucket present');
    ok($by_name{unclassified},  'unclassified bucket present');
    is($by_name{spam}{word_count},          20,         'spam word_count correct');
    is($by_name{news}{color},               '#aaffaa',  'news color correct');
    is($by_name{unclassified}{pseudo} + 0,  1,          'unclassified is pseudo');
    is($by_name{spam}{pseudo} + 0,          0,          'spam is not pseudo');
};

subtest 'GET /api/v1/buckets/:name returns single bucket' => sub {
    $t->get_ok('/api/v1/buckets/spam')
      ->status_is(200)
      ->json_is('/name', 'spam')
      ->json_is('/word_count', 20)
      ->json_is('/color', '#ffaaaa');
};

subtest 'GET /api/v1/buckets/:name unknown bucket returns 404' => sub {
    $t->get_ok('/api/v1/buckets/noexist')
      ->status_is(404)
      ->json_has('/error');
};

subtest 'POST /api/v1/buckets creates bucket' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'ham' })
      ->status_is(200)
      ->json_is('/ok', 1);
};

subtest 'POST /api/v1/buckets missing name returns 400' => sub {
    $t->post_ok('/api/v1/buckets', json => {})
      ->status_is(400)
      ->json_has('/error');
};

subtest 'POST /api/v1/buckets invalid name returns 422' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'Bad Name!' })
      ->status_is(422)
      ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:name' => sub {
    $t->delete_ok('/api/v1/buckets/spam')
      ->status_is(200)
      ->json_is('/ok', 1);
};

done_testing;
