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

my @buckets_list = ('ham', 'spam');
my %search_result = (
    words => [
        { word => 'font-size', buckets => { ham => 38, spam => 42 }, coverage => 2, is_stopword => \0 },
        { word => 'invoice', buckets => { ham => 1, spam => 80 }, coverage => 2, is_stopword => \0 },
    ],
    total => 2,
    buckets => \@buckets_list,
);

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
sub get_stopword_list { () }
sub add_stopword { 1 }
sub remove_stopword { }
sub get_stopword_candidates { () }
sub history_obj { undef }
sub bayes { undef }
sub get_words_for_bucket { { words => [], total => 0 } }
sub remove_word_from_bucket { }
sub move_word_between_buckets { }
sub search_words_cross_bucket {
    my ($self, $prefix, %opts) = @_;
    return \%search_result;
}

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

subtest 'GET /api/v1/words/search returns structure' => sub {
    $t->get_ok('/api/v1/words/search?q=font')
      ->status_is(200)
      ->json_has('/words')
      ->json_has('/total')
      ->json_has('/buckets');
    my $body = $t->tx->res->json;
    is $body->{total}, 2, 'total is 2';
    is scalar $body->{buckets}->@*, 2, 'two buckets';
    my $first = $body->{words}[0];
    ok exists $first->{word}, 'word key present';
    ok exists $first->{coverage}, 'coverage key present';
    ok exists $first->{is_stopword}, 'is_stopword key present';
    ok ref $first->{buckets} eq 'HASH', 'per-bucket hash present';
};

subtest 'GET /api/v1/words/search passes sort and dir params' => sub {
    $t->get_ok('/api/v1/words/search?q=&sort=coverage&dir=desc')
      ->status_is(200);
};

done_testing;
