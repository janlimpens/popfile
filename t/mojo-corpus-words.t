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

my @words_spam = (
    { word => 'invoice',  count => 142, total => 143, accuracy => 0.993 },
    { word => 'payment',  count => 80,  total => 82,  accuracy => 0.976 },
    { word => 'offer',    count => 30,  total => 60,  accuracy => 0.5 },
);

my $removed;
my $moved;

package MockSvc;
sub get_all_buckets { ('spam', 'ham', 'unclassified') }
sub is_bucket { my $b = $_[1]; grep { $_ eq $b } qw(spam ham) }
sub is_pseudo_bucket { $_[1] eq 'unclassified' }
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
sub get_words_for_bucket {
    my ($self, $session, $bucket, %opts) = @_;
    return { words => [], total => 0 }
        unless $bucket eq 'spam';
    my $page = $opts{page} // 1;
    my $per_page = $opts{per_page} // 50;
    return {
        words => [@words_spam],
        total => scalar @words_spam };
}
sub remove_word_from_bucket {
    my ($self, $session, $bucket, $word) = @_;
    $removed = { bucket => $bucket, word => $word };
}
sub move_word_between_buckets {
    my ($self, $session, $from, $to, $word) = @_;
    $moved = { from => $from, to => $to, word => $word };
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

subtest 'GET /api/v1/corpus/:bucket/words returns correct structure' => sub {
    $t->get_ok('/api/v1/corpus/spam/words')
      ->status_is(200)
      ->json_has('/words')
      ->json_has('/total')
      ->json_has('/page')
      ->json_has('/per_page');
    my $body = $t->tx->res->json;
    is($body->{total}, 3, 'total is 3');
    is($body->{page}, 1, 'page defaults to 1');
    is(scalar $body->{words}->@*, 3, 'three words returned');
    my $first = $body->{words}[0];
    ok(exists $first->{word},     'word key present');
    ok(exists $first->{count},    'count key present');
    ok(exists $first->{total},    'total key present');
    ok(exists $first->{accuracy}, 'accuracy key present');
    is($first->{word}, 'invoice', 'first word is invoice');
    ok($first->{accuracy} > 0.99, 'accuracy is high for invoice');
};

subtest 'GET /api/v1/corpus/:bucket/words accepts page and per_page params' => sub {
    $t->get_ok('/api/v1/corpus/spam/words?page=2&per_page=10')
      ->status_is(200)
      ->json_is('/page', 2)
      ->json_is('/per_page', 10);
};

subtest 'GET /api/v1/corpus/:bucket/words for unknown bucket returns empty' => sub {
    $t->get_ok('/api/v1/corpus/noexist/words')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is($body->{total}, 0, 'total is 0 for unknown bucket');
    is(scalar $body->{words}->@*, 0, 'no words for unknown bucket');
};

subtest 'DELETE /api/v1/corpus/:bucket/word/:word' => sub {
    $t->delete_ok('/api/v1/corpus/spam/word/invoice')
      ->status_is(200)
      ->json_is('/ok', 1);
    is($removed->{bucket}, 'spam', 'remove called with correct bucket');
    is($removed->{word}, 'invoice', 'remove called with correct word');
};

subtest 'POST /api/v1/corpus/:bucket/word/:word/move' => sub {
    $t->post_ok('/api/v1/corpus/spam/word/invoice/move',
        json => { to => 'ham' })
      ->status_is(200)
      ->json_is('/ok', 1);
    is($moved->{from}, 'spam', 'move from correct bucket');
    is($moved->{to},   'ham',  'move to correct bucket');
    is($moved->{word}, 'invoice', 'correct word moved');
};

subtest 'POST /api/v1/corpus/:bucket/word/:word/move missing to returns 400' => sub {
    $t->post_ok('/api/v1/corpus/spam/word/invoice/move', json => {})
      ->status_is(400)
      ->json_has('/error');
};

done_testing;
