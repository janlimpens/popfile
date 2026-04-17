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

my %magnets;
my %types = (1 => 'From', 2 => 'Subject', 3 => 'To');

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

sub get_magnet_types { %types }

sub get_buckets_with_magnets { keys %magnets }

sub get_magnet_types_in_bucket {
    my ($self, $bucket) = @_;
    return exists $magnets{$bucket} ? keys $magnets{$bucket}->%* : ()
}

sub get_magnets {
    my ($self, $bucket, $type) = @_;
    return exists $magnets{$bucket}{$type} ? $magnets{$bucket}{$type}->@* : ()
}

sub create_magnet {
    my ($self, $bucket, $type, $value) = @_;
    push $magnets{$bucket}{$type}->@*, $value;
}

sub delete_magnet {
    my ($self, $bucket, $type, $value) = @_;
    return unless exists $magnets{$bucket}{$type};
    $magnets{$bucket}{$type} = [grep { $_ ne $value } $magnets{$bucket}{$type}->@*];
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

subtest 'GET /api/v1/magnet-types returns type hash' => sub {
    $t->get_ok('/api/v1/magnet-types')
      ->status_is(200)
      ->json_is('/1', 'From')
      ->json_is('/2', 'Subject')
      ->json_is('/3', 'To');
};

subtest 'GET /api/v1/magnets empty when no magnets exist' => sub {
    $t->get_ok('/api/v1/magnets')
      ->status_is(200)
      ->json_is({});
};

subtest 'POST /api/v1/magnets returns 400 for missing or empty fields' => sub {
    $t->post_ok('/api/v1/magnets', json => {})
      ->status_is(400)
      ->json_has('/error');

    $t->post_ok('/api/v1/magnets', json => { bucket => 'spam' })
      ->status_is(400)
      ->json_has('/error');

    $t->post_ok('/api/v1/magnets', json => { bucket => 'spam', type => 'From' })
      ->status_is(400)
      ->json_has('/error');

    $t->post_ok('/api/v1/magnets',
        json => { bucket => '', type => 'From', value => 'evil@example.com' })
      ->status_is(400)
      ->json_has('/error');
};

subtest 'POST /api/v1/magnets creates a magnet' => sub {
    $t->post_ok('/api/v1/magnets',
        json => { bucket => 'spam', type => 'From', value => 'evil@example.com' })
      ->status_is(200)
      ->json_is('/ok', 1);
};

subtest 'GET /api/v1/magnets reflects created magnet' => sub {
    $t->get_ok('/api/v1/magnets')
      ->status_is(200)
      ->json_is('/spam/From/0', 'evil@example.com');
};

subtest 'DELETE /api/v1/magnets removes a magnet' => sub {
    $t->delete_ok('/api/v1/magnets',
        json => { bucket => 'spam', type => 'From', value => 'evil@example.com' })
      ->status_is(200)
      ->json_is('/ok', 1);

    $t->get_ok('/api/v1/magnets')
      ->status_is(200)
      ->json_is({});
};

done_testing;
