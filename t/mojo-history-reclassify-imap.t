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
use TestMocks;

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
my $file_uncl1 = _make_msg_file('ham message for uncl1', 'mid-uncl1@example.com');
my $file_uncl2 = _make_msg_file('spam message for uncl2', 'mid-uncl2@example.com');
my $file_uncl3 = _make_msg_file('ham message for uncl3', undef);

my %buckets = (ham => '#aaffaa', spam => '#ffaaaa', archive => '#cccccc');
my %slots;

sub _reset_slots () {
    %slots = (
        1 => { fields => [1, 'alice@example.com', 'bob@example.com', '', 'Test', '2024-01-01', 'hash1', time(), 'ham', undef, 1, '', 100, 'abc123@example.com'], file => $file_with_mid, bucket => 'ham' },
        2 => { fields => [2, 'spammer@evil.com', 'bob@example.com', '', 'Win', '2024-01-02', 'hash2', time(), 'spam', undef, 2, '', 200, undef], file => $file_no_mid, bucket => 'spam' },
        3 => { fields => [3, 'bad@evil.com', 'bob@example.com', '', 'Bad', '2024-01-03', 'hash3', time(), 'ham', undef, 3, '', 300, undef], file => $file_bad, bucket => 'ham' });
}
_reset_slots();

my $mock_hist = TestMocks::MockHist->new(slots => \%slots);
$mock_hist->{mid_log} = [];
my $mock_imap = TestMocks::MockImap->new();
my $mock_svc  = TestMocks::MockSvc->new(buckets => \%buckets, hist => $mock_hist);
$mock_svc->{remove_log} = [];
$mock_svc->{add_log} = [];

require POPFile::API;
require POPFile::Configuration;

my $mq = TestMocks::StubMQ->new();
my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_classifier_service($mock_svc);
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
    $ui_no_imap->set_classifier_service($mock_svc);
    my $app2 = $ui_no_imap->build_app($mock_svc, 'test-session');
    $app2->log->level('fatal');
    my $t2 = Test::Mojo->new($app2);
    $t2->post_ok('/api/v1/history/1/reclassify', json => { bucket => 'spam' })
        ->status_is(200)
        ->json_is('/ok', 1);
    pass('reclassify succeeds without IMAP service');
};

sub _uncl_slots () {
    %slots = (
        10 => { fields => [10, 'alice@example.com', 'bob@example.com', '', 'Ham-U', '2024-06-01', 'uhash1', time(), 'unclassified', undef, 0, '', 150, 'mid-uncl1@example.com'], file => $file_uncl1, bucket => 'unclassified' },
        11 => { fields => [11, 'spammer@evil.com', 'bob@example.com', '', 'Spam-U', '2024-06-02', 'uhash2', time(), 'unclassified', undef, 0, '', 250, 'mid-uncl2@example.com'], file => $file_uncl2, bucket => 'unclassified' },
        12 => { fields => [12, 'bob@example.com', 'alice@example.com', '', 'No-MID-U', '2024-06-03', 'uhash3', time(), 'unclassified', undef, 0, '', 50, undef], file => $file_uncl3, bucket => 'unclassified' });
}

sub _classified_slots () {
    %slots = (
        20 => { fields => [20, 'alice@example.com', 'bob@example.com', '', 'Ham-C', '2024-07-01', 'chash1', time(), 'ham', undef, 1, '', 150, 'mid-uncl1@example.com'], file => $file_uncl1, bucket => 'ham' },
        21 => { fields => [21, 'spammer@evil.com', 'bob@example.com', '', 'Spam-C', '2024-07-02', 'chash2', time(), 'spam', undef, 2, '', 250, 'mid-uncl2@example.com'], file => $file_uncl2, bucket => 'spam' },
        22 => { fields => [22, 'bob@example.com', 'alice@example.com', '', 'No-MID-C', '2024-07-03', 'chash3', time(), 'ham', undef, 3, '', 50, undef], file => $file_uncl3, bucket => 'ham' });
}

subtest 'reclassify_unclassified trains messages and requests IMAP moves' => sub {
    mock_reset();
    _uncl_slots();
    $t->post_ok('/api/v1/history/reclassify-unclassified')
        ->status_is(200)
        ->json_has('/total')
        ->json_has('/updated');
    my $adds = $mock_svc->{add_log};
    is(scalar $adds->@*, 3, 'all three unclassified messages added to buckets');
    my @buckets = sort map { $_->{bucket} } $adds->@*;
    my @expected_buckets = qw(ham ham ham);
    is(\@buckets, \@expected_buckets, 'all reclassified to ham via MockSvc->classify');
    my $removes = $mock_svc->{remove_log};
    is(scalar $removes->@*, 0, 'no remove_message_from_bucket calls for unclassified messages');
    my $moves = $mock_imap->{move_requests};
    is(scalar $moves->@*, 3, 'three IMAP moves requested');
    my @move_hashes = sort map { $_->{hash} } $moves->@*;
    my @expected_hashes = sort qw(uhash1 uhash2 uhash3);
    is(\@move_hashes, \@expected_hashes, 'all three hashes triggered moves');
    for my $move ($moves->@*) {
        is($move->{target_bucket}, 'ham', 'target bucket is ham');
        is($move->{source_bucket}, 'unclassified', 'source bucket is unclassified');
    }
    my $mids = $mock_hist->{mid_log};
    is(scalar $mids->@*, 2, 'MIDs persisted for messages with Message-ID only');
    my @mid_slots = sort map { $_->{slot} } $mids->@*;
    my @expected_mid_slots = sort qw(10 11);
    is(\@mid_slots, \@expected_mid_slots, 'MID persisted for slots 10 and 11');
};

subtest 'reclassify_unclassified without IMAP service still succeeds' => sub {
    my $ui_no_imap = POPFile::API->new();
    $ui_no_imap->set_configuration($config);
    $ui_no_imap->set_mq($mq);
    $ui_no_imap->initialize();
    $ui_no_imap->set_classifier_service($mock_svc);
    my $app2 = $ui_no_imap->build_app($mock_svc, 'test-session');
    $app2->log->level('fatal');
    my $t2 = Test::Mojo->new($app2);
    mock_reset();
    _uncl_slots();
    $t2->post_ok('/api/v1/history/reclassify-unclassified')
        ->status_is(200)
        ->json_has('/updated');
    my $adds = $mock_svc->{add_log};
    is(scalar $adds->@*, 3, 'messages still added to buckets without IMAP');
    pass('reclassify_unclassified succeeds without IMAP service');
};

subtest 'verify_folder_placement queues moves for classified messages with MID' => sub {
    mock_reset();
    _classified_slots();
    $t->post_ok('/api/v1/imap/verify-folders')
        ->status_is(200)
        ->json_has('/total')
        ->json_has('/processed');
    my $moves = $mock_imap->{move_requests};
    my @move_hashes = sort map { $_->{hash} } $moves->@*;
    my @expected = sort qw(chash1 chash2);
    is(\@move_hashes, \@expected, 'moves queued for messages with MID');
    my @targets = sort map { $_->{target_bucket} } $moves->@*;
    my @expected_targets = sort qw(ham spam);
    is(\@targets, \@expected_targets, 'correct target buckets');
    my $mids = $mock_hist->{mid_log};
    is(scalar $mids->@*, 2, 'MIDs persisted for messages with Message-ID');
    my $cached = $mock_imap->{cached_mids};
    ok(defined $cached->{chash1}, 'MID cached for chash1');
    ok(defined $cached->{chash2}, 'MID cached for chash2');
};

subtest 'verify_folder_placement skips messages without Message-ID' => sub {
    mock_reset();
    _classified_slots();
    $t->post_ok('/api/v1/imap/verify-folders')
        ->status_is(200);
    my $moves = $mock_imap->{move_requests};
    my @hashes = map { $_->{hash} } $moves->@*;
    ok(!(grep { $_ eq 'chash3' } @hashes), 'no move queued for message without MID');
};

subtest 'verify_folder_placement returns 503 when IMAP not available' => sub {
    mock_reset();
    _classified_slots();
    my $ui_no_imap = POPFile::API->new();
    $ui_no_imap->set_configuration($config);
    $ui_no_imap->set_mq($mq);
    $ui_no_imap->initialize();
    $ui_no_imap->set_classifier_service($mock_svc);
    my $app2 = $ui_no_imap->build_app($mock_svc, 'test-session');
    $app2->log->level('fatal');
    my $t2 = Test::Mojo->new($app2);
    $t2->post_ok('/api/v1/imap/verify-folders')
        ->status_is(503);
};

subtest 'verify_folder_mismatches returns messages not belonging to folder' => sub {
    mock_reset();
    _classified_slots();
    $t->get_ok('/api/v1/imap/verify-folders/INBOX.spam')
        ->status_is(200)
        ->json_is('/folder', 'INBOX.spam')
        ->json_has('/messages')
        ->json_has('/total');
    my $msgs = $t->tx->res->json->{messages};
    my @buckets = sort map { $_->{bucket} } $msgs->@*;
    my @expected = qw(ham ham);
    is(\@buckets, \@expected, 'ham messages flagged as not belonging to spam folder');
    my @targets = sort map { $_->{target_folder} } $msgs->@*;
    my @expected_targets = qw(INBOX.ham INBOX.ham);
    is(\@targets, \@expected_targets, 'target folder is INBOX.ham');
};

subtest 'verify_folder_mismatches returns empty when all messages belong' => sub {
    mock_reset();
    _classified_slots();
    $t->get_ok('/api/v1/imap/verify-folders/INBOX.ham')
        ->status_is(200)
        ->json_is('/total', 1);
};

subtest 'move_messages queues moves for selected messages' => sub {
    mock_reset();
    _classified_slots();
    $t->post_ok('/api/v1/imap/move-messages', json => {
        moves => [
            { hash => 'chash1', bucket => 'ham', mid => 'mid-uncl1@example.com' },
            { hash => 'chash2', bucket => 'spam' },
        ]})
        ->status_is(200)
        ->json_is('/queued', 2);
    my $moves = $mock_imap->{move_requests};
    is(scalar $moves->@*, 2, 'two moves queued');
    is($moves->[0]{hash}, 'chash1', 'first move hash correct');
    is($moves->[0]{target_bucket}, 'ham', 'first move target correct');
    is($moves->[1]{hash}, 'chash2', 'second move hash correct');
    is($moves->[1]{target_bucket}, 'spam', 'second move target correct');
    my $cached = $mock_imap->{cached_mids};
    ok(defined $cached->{chash1}, 'MID cached when provided');
    ok(!defined $cached->{chash2}, 'no MID cached when not provided');
};

subtest 'move_messages returns 503 when IMAP not available' => sub {
    my $ui_no_imap = POPFile::API->new();
    $ui_no_imap->set_configuration($config);
    $ui_no_imap->set_mq($mq);
    $ui_no_imap->initialize();
    $ui_no_imap->set_classifier_service($mock_svc);
    my $app2 = $ui_no_imap->build_app($mock_svc, 'test-session');
    $app2->log->level('fatal');
    my $t2 = Test::Mojo->new($app2);
    $t2->post_ok('/api/v1/imap/move-messages', json => { moves => [{ hash => 'x', bucket => 'ham' }] })
        ->status_is(503);
};

done_testing;
