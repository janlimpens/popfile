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

my %buckets = (
    ham  => { color => '#00cc00', word_count => 42, pseudo => 0, fpcount => 1, fncount => 2 },
    spam => { color => '#cc0000', word_count => 17, pseudo => 0, fpcount => 0, fncount => 0 },
    unclassified => { color => '#666666', word_count => 0, pseudo => 1, fpcount => 0, fncount => 0 },
);

my %words = (
    ham  => [ ['hello', 5], ['world', 3] ],
    spam => [ ['buy', 10], ['now', 7] ],
);

package MockSvc;
sub get_all_buckets { sort keys %buckets }
sub is_bucket { my (undef, $n) = @_; exists $buckets{$n} && !$buckets{$n}{pseudo} }
sub is_pseudo_bucket { my (undef, $n) = @_; $buckets{$n} && $buckets{$n}{pseudo} ? 1 : 0 }
sub get_bucket_word_count { my (undef, $n) = @_; $buckets{$n}{word_count} // 0 }
sub get_bucket_color { my (undef, $n) = @_; $buckets{$n}{color} // '#666666' }
sub get_bucket_parameter {
    my (undef, $n, $key) = @_;
    $buckets{$n}{$key} // 0
}
sub get_bucket_word_list {
    my (undef, $n, $prefix) = @_;
    my @w = @{ $words{$n} // [] };
    return $prefix ? grep { $_->[0] =~ /^\Q$prefix/ } @w : @w;
}
sub create_bucket {
    my (undef, $n) = @_;
    return 0 if exists $buckets{$n};
    $buckets{$n} = { color => '#666666', word_count => 0, pseudo => 0, fpcount => 0, fncount => 0 };
    return 1;
}
sub delete_bucket { my (undef, $n) = @_; delete $buckets{$n} }
sub rename_bucket {
    my (undef, $old, $new) = @_;
    $buckets{$new} = delete $buckets{$old};
}
sub clear_bucket { my (undef, $n) = @_; $buckets{$n}{word_count} = 0 if exists $buckets{$n} }
sub set_bucket_color { my (undef, $n, $c) = @_; $buckets{$n}{color} = $c if exists $buckets{$n} }
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

subtest 'GET /api/v1/buckets returns all buckets' => sub {
    $t->get_ok('/api/v1/buckets')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, 3, 'three buckets returned');
    my ($ham) = grep { $_->{name} eq 'ham' } @$body;
    is($ham->{color}, '#00cc00', 'ham color correct');
    is($ham->{word_count}, 42, 'ham word_count correct');
    is($ham->{pseudo}, 0, 'ham not pseudo');
};

subtest 'GET /api/v1/buckets/:name found' => sub {
    $t->get_ok('/api/v1/buckets/ham')
      ->status_is(200)
      ->json_is('/name', 'ham')
      ->json_is('/color', '#00cc00')
      ->json_is('/word_count', 42)
      ->json_is('/fpcount', 1)
      ->json_is('/fncount', 2);
};

subtest 'GET /api/v1/buckets/:name pseudo bucket found' => sub {
    $t->get_ok('/api/v1/buckets/unclassified')
      ->status_is(200)
      ->json_is('/name', 'unclassified')
      ->json_is('/pseudo', 1);
};

subtest 'GET /api/v1/buckets/:name not found' => sub {
    $t->get_ok('/api/v1/buckets/nosuchbucket')
      ->status_is(404)
      ->json_has('/error');
};

subtest 'POST /api/v1/buckets success' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'newbucket' })
      ->status_is(200)
      ->json_is('/ok', 1);
    ok(exists $buckets{newbucket}, 'bucket created in mock');
};

subtest 'POST /api/v1/buckets with color' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'coloredbucket', color => '#ff0000' })
      ->status_is(200)
      ->json_is('/ok', 1);
    is($buckets{coloredbucket}{color}, '#ff0000', 'color set on creation');
};

subtest 'POST /api/v1/buckets missing name' => sub {
    $t->post_ok('/api/v1/buckets', json => {})
      ->status_is(400)
      ->json_has('/error');
};

subtest 'POST /api/v1/buckets invalid chars in name' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'UPPERCASE' })
      ->status_is(422)
      ->json_has('/error');
};

subtest 'POST /api/v1/buckets already exists' => sub {
    $t->post_ok('/api/v1/buckets', json => { name => 'ham' })
      ->status_is(409)
      ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:name' => sub {
    $buckets{tobedeleted} = { color => '#000000', word_count => 0, pseudo => 0, fpcount => 0, fncount => 0 };
    $t->delete_ok('/api/v1/buckets/tobedeleted')
      ->status_is(200)
      ->json_is('/ok', 1);
    ok(!exists $buckets{tobedeleted}, 'bucket removed from mock');
};

subtest 'PUT /api/v1/buckets/:name/rename' => sub {
    $buckets{oldbucket} = { color => '#111111', word_count => 5, pseudo => 0, fpcount => 0, fncount => 0 };
    $t->put_ok('/api/v1/buckets/oldbucket/rename', json => { new_name => 'renamedto' })
      ->status_is(200)
      ->json_is('/ok', 1);
    ok(!exists $buckets{oldbucket}, 'old name removed');
    ok(exists $buckets{renamedto}, 'new name exists');
};

subtest 'PUT /api/v1/buckets/:name/rename missing new_name' => sub {
    $t->put_ok('/api/v1/buckets/ham/rename', json => {})
      ->status_is(400)
      ->json_has('/error');
};

subtest 'DELETE /api/v1/buckets/:name/words' => sub {
    $buckets{ham}{word_count} = 42;
    $t->delete_ok('/api/v1/buckets/ham/words')
      ->status_is(200)
      ->json_is('/ok', 1);
    is($buckets{ham}{word_count}, 0, 'word count cleared');
};

subtest 'PUT /api/v1/buckets/:name/params color' => sub {
    $t->put_ok('/api/v1/buckets/spam/params', json => { color => '#0000ff' })
      ->status_is(200)
      ->json_is('/ok', 1);
    is($buckets{spam}{color}, '#0000ff', 'color updated');
};

subtest 'GET /api/v1/buckets/:name/words' => sub {
    $t->get_ok('/api/v1/buckets/ham/words')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, 2, 'two words returned');
    is($body->[0]{word}, 'hello', 'first word');
    is($body->[0]{count}, 5, 'first word count');
};

subtest 'GET /api/v1/buckets/:name/words with prefix' => sub {
    $t->get_ok('/api/v1/buckets/ham/words?prefix=hel')
      ->status_is(200);
    my $body = $t->tx->res->json;
    is(scalar @$body, 1, 'one word matches prefix');
    is($body->[0]{word}, 'hello', 'matched word');
};

done_testing;
