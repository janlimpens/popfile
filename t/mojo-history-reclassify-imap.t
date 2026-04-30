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

sub _make_msg_file ($text_body, $mid) {
    my ($fh, $file) = tempfile(DIR => $tmpdir, SUFFIX => '.msg');
    my $msg = "From: alice\@example.com\r\n"
        . "To: bob\@example.com\r\n"
        . "Subject: Test Message\r\n"
        . "Date: Thu, 01 Jan 2024 00:00:00 +0000\r\n";
    $msg .= "Message-ID: <$mid>\r\n"
        if defined $mid;
    $msg .= "\r\n$text_body\r\n";
    print $fh $msg;
    close $fh;
    return $file
}

sub _make_msg_no_headers ($text_body) {
    my ($fh, $file) = tempfile(DIR => $tmpdir, SUFFIX => '.msg');
    print $fh "$text_body\r\n";
    close $fh;
    return $file
}

my $file_with_mid = _make_msg_file('ham message', 'abc123@example.com');
my $file_no_mid = _make_msg_file('ham message', undef);
my $file_bad = _make_msg_no_headers('raw text');

my %buckets = (ham => '#aaffaa', spam => '#ffaaaa', archive => '#cccccc');
my %slots;

sub _reset_slots () {
    %slots = (
        1 => { fields => [1, 'alice@example.com', 'bob@example.com', '', 'Test', '2024-01-01', 'hash1', time(), 'ham', undef, 1, '', 100], file => $file_with_mid, bucket => 'ham' },
        2 => { fields => [2, 'spammer@evil.com', 'bob@example.com', '', 'Win', '2024-01-02', 'hash2', time(), 'spam', undef, 2, '', 200], file => $file_no_mid, bucket => 'spam' },
        3 => { fields => [3, 'bad@evil.com', 'bob@example.com', '', 'Bad', '2024-01-03', 'hash3', time(), 'ham', undef, 3, '', 300], file => $file_bad, bucket => 'ham' });
}
_reset_slots();

my $mock_hist = bless {
    slots => \%slots,
    queries => {},
    next_qid => 1,
    mid_log => [] }, 'MockHist';

my $mock_imap = bless {
    cached_mids => {},
    move_requests => [] }, 'MockImap';

my $mock_svc = bless {
    hist => $mock_hist,
    buckets => \%buckets,
    remove_log => [],
    add_log => [] }, 'MockSvc';

require POPFile::API;
require POPFile::Configuration;

my $mq = bless {}, 'StubMQ';
my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($mock_svc);
$ui->set_imap($mock_imap);

my $app = $ui->build_app($mock_svc, 'test-session');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

sub mock_reset () {
    $mock_imap->{move_requests} = [];
    $mock_imap->{cached_mids} = {};
    $mock_hist->{mid_log} = [];
    $mock_svc->{remove_log} = [];
    $mock_svc->{add_log} = [];
}

subtest 'reclassify with Message-ID in file caches MID and requests folder move' => sub {
    mock_reset();
    _reset_slots();
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
    my $cached = $mock_imap->{cached_mids};
    ok(defined $cached->{hash1}, 'Message-ID cached for hash1');
    is($cached->{hash1}, 'abc123@example.com', 'cached MID is correct');
    my $moves = $mock_imap->{move_requests};
    is(scalar $moves->@*, 1, 'one move requested');
    is($moves->[0]{hash}, 'hash1', 'move request hash is hash1');
    is($moves->[0]{target_bucket}, 'spam', 'target bucket is spam');
    is($moves->[0]{source_bucket}, 'ham', 'source bucket is old bucket');
    my $mids = $mock_hist->{mid_log};
    is(scalar $mids->@*, 1, 'set_message_id called once');
    is($mids->[0]{slot}, 1, 'MID persisted for slot 1');
    is($mids->[0]{mid}, 'abc123@example.com', 'persisted MID is correct');
};

subtest 'reclassify without Message-ID in file still requests folder move' => sub {
    mock_reset();
    _reset_slots();
    $t->post_ok('/api/v1/history/2/reclassify', json => { bucket => 'ham' })
        ->status_is(200)
        ->json_is('/ok', 1);
    my $cached = $mock_imap->{cached_mids};
    is(scalar keys %$cached, 0, 'no MID cached when missing from file');
    my $moves = $mock_imap->{move_requests};
    is(scalar $moves->@*, 1, 'move still requested despite missing MID');
    is($moves->[0]{hash}, 'hash2', 'move request hash is hash2');
    is($moves->[0]{target_bucket}, 'ham', 'target bucket is ham');
    is($moves->[0]{source_bucket}, 'spam', 'source bucket is old bucket');
    my $mids = $mock_hist->{mid_log};
    is(scalar $mids->@*, 0, 'set_message_id not called when MID missing');
};

subtest 'reclassify with unparseable message file still requests folder move' => sub {
    mock_reset();
    _reset_slots();
    $t->post_ok('/api/v1/history/3/reclassify', json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
    my $moves = $mock_imap->{move_requests};
    is(scalar $moves->@*, 1, 'move still requested for unparseable file');
    is($moves->[0]{hash}, 'hash3', 'move request hash is hash3');
    my $mids = $mock_hist->{mid_log};
    is(scalar $mids->@*, 0, 'set_message_id not called for unparseable file');
};

subtest 'reclassify to same bucket skips IMAP move' => sub {
    mock_reset();
    _reset_slots();
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'ham' })
        ->status_is(200)
        ->json_is('/ok', 1);
    my $moves = $mock_imap->{move_requests};
    is(scalar $moves->@*, 0, 'no move requested when bucket unchanged');
    my $mids = $mock_hist->{mid_log};
    is(scalar $mids->@*, 0, 'no MID persisted when bucket unchanged');
};

subtest 'reclassify unknown bucket returns 422 with no side effects' => sub {
    mock_reset();
    _reset_slots();
    $t->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'nosuch' })
        ->status_is(422);
    is(scalar $mock_imap->{move_requests}->@*, 0, 'no move requested');
    is(scalar $mock_hist->{mid_log}->@*, 0, 'no MID persisted');
};

subtest 'reclassify invalid slot returns 400 with no side effects' => sub {
    mock_reset();
    $t->post_ok('/api/v1/history/garbage/reclassify', json => { bucket => 'spam' })
        ->status_is(400);
    is(scalar $mock_imap->{move_requests}->@*, 0, 'no move requested');
};

subtest 'bulk_reclassify with valid slots triggers moves for each' => sub {
    mock_reset();
    _reset_slots();
    $t->post_ok('/api/v1/history/bulk-reclassify', json => { slots => [1, 2], bucket => 'archive' })
        ->status_is(200)
        ->json_has('/updated');
    my $moves = $mock_imap->{move_requests};
    my @hashes = sort map { $_->{hash} } $moves->@*;
    is(scalar $moves->@*, 2, 'two moves requested');
    my @expected = sort qw(hash1 hash2);
    is(\@hashes, \@expected, 'both slots triggered moves');
    my $mids = $mock_hist->{mid_log};
    my @mid_slots = sort map { $_->{slot} } $mids->@*;
    is(scalar $mids->@*, 1, 'MID persisted for slot with Message-ID only');
    is($mid_slots[0], 1, 'MID persisted for slot 1');
};

subtest 'reclassify without IMAP service still succeeds' => sub {
    mock_reset();
    _reset_slots();
    my $ui_no_imap = POPFile::API->new();
    $ui_no_imap->set_configuration($config);
    $ui_no_imap->set_mq($mq);
    $ui_no_imap->initialize();
    $ui_no_imap->set_service($mock_svc);
    my $app2 = $ui_no_imap->build_app($mock_svc, 'test-session');
    $app2->log->level('fatal');
    my $t2 = Test::Mojo->new($app2);
    $t2->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
    pass('reclassify succeeds without IMAP service');
};

done_testing;

package MockHist;

sub get_search_queries ($self, %args) {
    my $bucket = $args{bucket} // '';
    my $search = $args{search} // '';
    my $page = $args{page} // 1;
    my $per_page = $args{per_page} // 25;
    my @ids = sort { $a <=> $b } grep {
        my $s = $self->{slots}{$_};
        ($bucket eq '' || $s->{bucket} eq $bucket)
            && ($search eq '' || $s->{fields}[1] =~ /\Q$search\E/i
                || $s->{fields}[4] =~ /\Q$search\E/i)
    } keys $self->{slots}->%*;
    my $total = scalar @ids;
    my $offset = ($page - 1) * $per_page;
    my @page_ids = splice(@ids, $offset, $per_page);
    my @rows = map {
        my $f = $self->{slots}{$_}{fields};
        { slot => $f->[0], from => $f->[1], to => $f->[2], cc => $f->[3],
            subject => $f->[4], date => $f->[5], hash => $f->[6],
            inserted => $f->[7], bucket => $f->[8], usedtobe => $f->[9],
            bucket_id => $f->[10], magnet => $f->[11], size => $f->[12] }
    } @page_ids;
    return ($total, \@rows)
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

sub set_message_id ($self, $slot, $mid) {
    push $self->{mid_log}->@*, { slot => $slot, mid => $mid };
}

sub start_query ($self) {
    my $qid = $self->{next_qid}++;
    $self->{queries}{$qid} = { filter => '', search => '' };
    return $qid
}

sub stop_query ($self, $qid) { delete $self->{queries}{$qid} }

sub set_query ($self, $qid, $filter, $search, $sort, $not) {
    $self->{queries}{$qid}{filter} = $filter // '';
    $self->{queries}{$qid}{search} = $search // '';
}

sub get_query_size ($self, $qid) {
    my $filter = $self->{queries}{$qid}{filter} // '';
    my @matching = grep { $filter eq '' || $self->{slots}{$_}{bucket} eq $filter }
        keys $self->{slots}->%*;
    return scalar @matching
}

sub get_query_rows ($self, $qid, $start, $count) {
    my $filter = $self->{queries}{$qid}{filter} // '';
    my @ids = sort { $a <=> $b } grep {
        $filter eq '' || $self->{slots}{$_}{bucket} eq $filter
    } keys $self->{slots}->%*;
    my @page = splice(@ids, $start - 1, $count);
    return map { $self->{slots}{$_}{fields} } @page
}

package MockSvc;

sub history_obj ($self) { $self->{hist} }
sub bayes ($self) { undef }
sub get_all_buckets ($self) { keys $self->{buckets}->%* }
sub is_bucket ($self, $name) { exists $self->{buckets}{$name} ? 1 : 0 }
sub is_pseudo_bucket ($self, $name) { 0 }
sub get_bucket_color ($self, $name) { $self->{buckets}{$name} // '#666666' }
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
sub remove_message_from_bucket ($self, $bucket, $file) {
    push $self->{remove_log}->@*, { bucket => $bucket, file => $file };
}
sub add_message_to_bucket ($self, $bucket, $file) {
    push $self->{add_log}->@*, { bucket => $bucket, file => $file };
}
sub classify ($self, $file) { 'ham' }
sub mangle_word ($self, $word) { lc($word) }
sub get_word_colors ($self, @words) { () }

package MockImap;

sub cache_message_id ($self, $hash, $mid) {
    $self->{cached_mids}{$hash} = $mid;
}

sub request_folder_move ($self, $hash, $target_bucket, $source_bucket = undef) {
    push $self->{move_requests}->@*, {
        hash => $hash,
        target_bucket => $target_bucket,
        source_bucket => $source_bucket };
}

package StubMQ;
sub post ($self, $type, @msg) { }
sub register ($self, $type, $obj) { }
