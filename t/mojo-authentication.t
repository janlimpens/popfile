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
use File::Temp qw(tempdir tempfile);

my $tmpdir = tempdir(CLEANUP => 1);
my ($fh, $fixture_file) = tempfile(DIR => $tmpdir, SUFFIX => '.msg');
print $fh "From: alice\@example.com\r\nSubject: Test\r\n\r\nham\r\n";
close $fh;

my %slots = (
    1 => { fields => [1, 'alice@example.com', 'bob@example.com', '', 'Test', '2024-01-01', 'abc', time(), 'ham', undef, 1, '', 100], file => $fixture_file, bucket => 'ham' },
);

my %buckets = (ham => '#aaffaa', spam => '#ffaaaa');

my $mock_hist = bless {
    slots => \%slots,
    queries => {},
    next_qid => 1 }, 'MockHist';

my $mock_svc = bless {
    hist => $mock_hist,
    buckets => \%buckets }, 'MockSvc';

require POPFile::API;
require POPFile::Configuration;

sub _build_app ($password = '') {
    my $mq = bless {}, 'StubMQ';
    my $config = POPFile::Configuration->new();
    $config->set_configuration($config);
    $config->set_mq($mq);
    $config->initialize();
    $config->set_started(1);
    $config->parameter('api_local', 1);
    my $ui = POPFile::API->new();
    $ui->set_configuration($config);
    $ui->set_mq($mq);
    $ui->initialize();
    $ui->set_service($mock_svc);
    $config->parameter('api_password', $password)
        if $password ne '';
    my $app = $ui->build_app($mock_svc, 'test-session');
    $app->log->level('fatal');
    return $app
}

subtest 'no password set — API is open without token' => sub {
    my $t = Test::Mojo->new(_build_app(''));
    $t->get_ok('/api/v1/buckets')
        ->status_is(200)
        ->json_has('/0/name');
};

subtest 'password set — API rejects requests without token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets')
        ->status_is(401)
        ->json_is('/error', 'Unauthorized');
};

subtest 'password set — API allows requests with correct token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200)
        ->json_has('/0/name');
};

subtest 'password set — API rejects wrong token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'wrong' })
        ->status_is(401);
};

subtest 'password set — POST requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->post_ok('/api/v1/buckets', json => { name => 'test' })
        ->status_is(401);
    $t->post_ok('/api/v1/buckets' => { 'X-POPFile-Token' => 'sekret' }, json => { name => 'test' })
        ->status_is(200);
};

subtest 'password set — static files still served without token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/index.html')
        ->status_is(200);
};

subtest 'no password — history reclassify works without token' => sub {
    my $t = Test::Mojo->new(_build_app(''));
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'password set — history reclassify requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(401);
    $t->post_ok('/api/v1/history/1/reclassify' => { 'X-POPFile-Token' => 'sekret' }, json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
};

subtest 'password set — config read/write requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/config')
        ->status_is(401);
    $t->get_ok('/api/v1/config' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200);
    $t->put_ok('/api/v1/config' => { 'X-POPFile-Token' => 'sekret' }, json => {})
        ->status_is(200);
};

subtest 'password set — IMAP endpoints require token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/imap/folders')
        ->status_is(401);
    $t->get_ok('/api/v1/imap/folders' => { 'X-POPFile-Token' => 'sekret' })
        ->status_is(200);
};

subtest 'password set — health endpoint requires token' => sub {
    my $t = Test::Mojo->new(_build_app('sekret'));
    $t->get_ok('/api/v1/health')
        ->status_is(401);
};

done_testing;

package MockHist;

sub get_search_queries ($self, %args) {
    my @ids = sort { $a <=> $b } keys $self->{slots}->%*;
    my @rows = map {
        my $f = $self->{slots}{$_}{fields};
        { slot => $f->[0], from => $f->[1], to => $f->[2], cc => $f->[3],
            subject => $f->[4], date => $f->[5], hash => $f->[6],
            inserted => $f->[7], bucket => $f->[8], usedtobe => $f->[9],
            bucket_id => $f->[10], magnet => $f->[11], size => $f->[12] }
    } @ids;
    return (scalar @ids, \@rows)
}

sub get_slot_file ($self, $slot) {
    return $self->{slots}{$slot}{file}
        if $self->{slots}{$slot};
    return undef
}

sub get_slot_fields ($self, $slot) {
    return ()
        unless $self->{slots}{$slot};
    return $self->{slots}{$slot}{fields}->@*
}

sub change_slot_classification ($self, $slot, $class, $session, $undo) {
    return
        unless $self->{slots}{$slot};
    $self->{slots}{$slot}{fields}[8] = $class;
    $self->{slots}{$slot}{bucket} = $class;
}

sub set_message_id ($self, $slot, $mid) { }

package MockSvc;

sub history_obj ($self) { $self->{hist} }
sub bayes ($self) { undef }
sub get_all_buckets ($self) { keys $self->{buckets}->%* }
sub is_bucket ($self, $name) { 1 }
sub is_pseudo_bucket ($self, $name) { 0 }
sub get_bucket_color ($self, $name) { '#666666' }
sub get_bucket_word_count ($self, $name) { 0 }
sub get_bucket_parameter ($self, $name, $param) { 0 }
sub get_bucket_word_list ($self, $name, $prefix) { () }
sub create_bucket ($self, $name) {
    return 0 if exists $self->{buckets}{$name};
    $self->{buckets}{$name} = '#666666';
    return 1
}
sub delete_bucket ($self, $name) { }
sub rename_bucket ($self, $old, $new) { }
sub clear_bucket ($self, $name) { }
sub set_bucket_color ($self, $name, $color) { }
sub get_magnet_types ($self) { () }
sub get_buckets_with_magnets ($self) { () }
sub get_magnet_types_in_bucket ($self, $name) { () }
sub get_magnets ($self, $name, $type) { () }
sub create_magnet ($self, $bucket, $type, $val) { }
sub delete_magnet ($self, $bucket, $type, $val) { }
sub remove_message_from_bucket ($self, $bucket, $file) { }
sub add_message_to_bucket ($self, $bucket, $file) { }
sub classify ($self, $file) { 'ham' }
sub mangle_word ($self, $word) { lc($word) }
sub get_word_colors ($self, @words) { () }
sub get_words_for_bucket ($self, $bucket, %opts) { { words => [], total => 0 } }
sub search_words_cross_bucket ($self, $prefix, %opts) { { words => [], total => 0 } }
sub add_stopword ($self, $word) { 1 }
sub get_stopword_list ($self) { () }
sub remove_stopword ($self, $word) { }
sub get_stopword_candidates ($self, $ratio, $limit) { () }

package StubMQ;
sub post ($self, $type, @msg) { }
sub register ($self, $type, $obj) { }
