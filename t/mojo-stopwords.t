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

my @stopwords = ('test', 'example');
my @candidates = (
    { word => 'common', min_count => 10, max_count => 11, ratio => 1.1 },
    { word => 'also',   min_count => 5,  max_count => 9,  ratio => 1.8 },
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
sub history_obj { undef }
sub bayes { undef }
sub get_stopword_list { @stopwords }
sub add_stopword {
    my ($self, $w) = @_;
    push @stopwords, $w;
    return 1;
}
sub remove_stopword {
    my ($self, $w) = @_;
    @stopwords = grep { $_ ne $w } @stopwords;
}
sub get_stopword_candidates {
    my ($self, $ratio, $limit) = @_;
    return grep { $_->{ratio} < $ratio } @candidates;
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

subtest 'GET /api/v1/stopwords' => sub {
    $t->get_ok('/api/v1/stopwords')
      ->status_is(200)
      ->json_is('/0', 'example')
      ->json_is('/1', 'test');
};

subtest 'POST /api/v1/stopwords' => sub {
    $t->post_ok('/api/v1/stopwords', json => { word => 'newword' })
      ->status_is(200)
      ->json_is('/ok', 1);
    $t->get_ok('/api/v1/stopwords')
      ->status_is(200)
      ->json_has('/2');
};

subtest 'POST /api/v1/stopwords missing word' => sub {
    $t->post_ok('/api/v1/stopwords', json => {})
      ->status_is(400)
      ->json_has('/error');
};

subtest 'DELETE /api/v1/stopwords/:word' => sub {
    $t->delete_ok('/api/v1/stopwords/newword')
      ->status_is(200)
      ->json_is('/ok', 1);
};

subtest 'GET /api/v1/stopword-candidates' => sub {
    $t->get_ok('/api/v1/stopword-candidates?ratio=2.0')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, 2, 'both candidates below ratio 2.0');
    is($body->[0]{word}, 'common', 'first candidate is common');
};

subtest 'GET /api/v1/stopword-candidates narrow ratio' => sub {
    $t->get_ok('/api/v1/stopword-candidates?ratio=1.5')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, 1, 'only one candidate below ratio 1.5');
    is($body->[0]{word}, 'common', 'candidate is common');
};

done_testing;
