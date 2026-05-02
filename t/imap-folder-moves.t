#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Log::Any::Test;
use Log::Any qw($log);
use TestHelper;

require Services::IMAP;

{
    package StubClassifier;
    sub new              { bless {}, shift }
    sub get_session_key  { 'session' }
    sub get_all_buckets  { ('work') }
    sub is_pseudo_bucket { 0 }
}

{
    package StubHistory;
    sub new { bless {}, shift }
    sub get_slot_from_hash { 'slot1' }
    sub get_slot_fields    { (undef) x 8, 'work' }
    sub get_message_hash   { 'deadbeef' }
    sub commit_history     {}
}

{
    package StubIMAPClient;
    sub new { bless { uv => {}, un => {}, uids => [], search_results => [], moves => [] }, shift }
    sub connected                       { 1 }
    sub get_mailbox_list                { () }
    sub status                          { { UIDNEXT => 10, UIDVALIDITY => 1 } }
    sub create_folder                   {}
    sub uid_validity                    { my ($s,$f,$v) = @_; $s->{uv}{$f} = $v if defined $v; $s->{uv}{$f} }
    sub uid_next                        { my ($s,$f,$v) = @_; $s->{un}{$f} = $v if defined $v; $s->{un}{$f} }
    sub uid_nexts                       { {} }
    sub uid_validities                  { {} }
    sub check_uidvalidity               { 1 }
    sub load_uid_state                  {}
    sub noop                            {}
    sub logout                          {}
    sub expunge                         {}
    sub move_message                    { my ($s,$uid,$dest) = @_; push $s->{moves}->@*, [$uid, $dest] }
    sub get_new_message_list_unselected { $_[0]->{uids}->@* }
    sub search_header_in_folder         { $_[0]->{search_results}->@* }
}

sub make_imap {
    my ($config, $mq) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->set_classifier(StubClassifier->new());
    $imap->set_history(StubHistory->new());
    $config->parameter('imap_enabled', 1);
    $config->parameter('imap_training_mode', 0);
    $config->parameter('imap_update_interval', 20);
    $config->parameter('imap_watched_folders', 'INBOX-->');
    $config->parameter('imap_bucket_folder_mappings', 'work-->Work-->');
    return ($imap, $config)
}

subtest 'request_folder_move without cached mid: uid_next reset when source_bucket given' => sub {
    my ($imap) = make_imap();
    $log->clear();

    $imap->request_folder_move('deadbeef', 'personal', 'work');

    my @reset_msgs = grep { /Scheduling uid_next reset/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @reset_msgs >= 1, 'uid_next reset scheduled for source folder when MID is not cached but source_bucket is given');
    my @warn_msgs = grep { /No Message-ID cached/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @warn_msgs >= 1, 'logs info that passive fallback is used');
};

subtest 'request_folder_move without cached mid: no uid_next reset without source_bucket' => sub {
    my ($imap) = make_imap();
    $log->clear();

    $imap->request_folder_move('deadbeef', 'personal');

    my @reset_msgs = grep { /Scheduling uid_next reset/ } map { $_->{message} } @{ $log->msgs() };
    ok(!@reset_msgs, 'no uid_next reset when neither MID nor source_bucket is available');
    my @warn_msgs = grep { /No Message-ID cached/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @warn_msgs >= 1, 'logs info that passive fallback is used');
};

subtest 'output folder is scanned for pending_folder_moves' => sub {
    my ($imap, $config) = make_imap();
    my $stub = StubIMAPClient->new();
    my @scanned;
    no warnings 'redefine', 'once';
    local *Services::IMAP::new_imap_client  = sub { $stub };
    local *Services::IMAP::scan_folder      = sub { push @scanned, $_[1] };

    $imap->_run_poll_work();

    my $inbox_scanned = grep { $_ eq 'INBOX' } @scanned;
    my $work_scanned  = grep { $_ eq 'Work'  } @scanned;
    ok($inbox_scanned, 'watched folder INBOX was scanned');
    ok($work_scanned,  'output folder Work was scanned');
};

subtest 'request_folder_rescan sets uid_next override for named folder' => sub {
    my ($imap) = make_imap();
    $log->clear();

    $imap->request_folder_rescan('INBOX');

    my @reset_msgs = grep { /Scheduling uid_next reset/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @reset_msgs >= 1, 'uid_next reset scheduled for rescan folder');
    my $inbox_reset = grep { /INBOX/ } @reset_msgs;
    ok($inbox_reset >= 1, 'uid_next reset is for INBOX');
};

subtest 'request_folder_move uses direct-move queue when mid is cached' => sub {
    my ($imap) = make_imap();
    my $stub = StubIMAPClient->new();
    $stub->{uids} = [42];
    $log->clear();
    no warnings 'redefine', 'once';
    local *Services::IMAP::new_imap_client = sub { $stub };
    local *Services::IMAP::get_hash = sub { ('deadbeef', '<msg@example.com>') };
    local *Services::IMAP::can_classify = sub { 0 };

    $imap->build_folder_list();
    $imap->connect_server();
    $imap->scan_folder('INBOX');

    $log->clear();
    $imap->request_folder_move('deadbeef', 'work', 'personal');

    my @reset_msgs = grep { /Scheduling uid_next reset/ } map { $_->{message} } @{ $log->msgs() };
    ok(!@reset_msgs, 'no uid_next reset when mid is cached');
    my @direct_msgs = grep { /Direct move queued/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @direct_msgs >= 1, 'direct move queued when mid is cached');
};

subtest '_drain_direct_moves moves message using SEARCH HEADER' => sub {
    my ($imap) = make_imap();
    my $stub = StubIMAPClient->new();
    $stub->{uids} = [42];
    $stub->{search_results} = [42];
    no warnings 'redefine', 'once';
    local *Services::IMAP::new_imap_client = sub { $stub };
    local *Services::IMAP::get_hash = sub { ('deadbeef', '<msg@example.com>') };
    local *Services::IMAP::can_classify = sub { 0 };

    $imap->build_folder_list();
    $imap->connect_server();
    $imap->scan_folder('INBOX');
    $imap->request_folder_move('deadbeef', 'work');

    my $result = { direct_moved_hashes => [] };
    $imap->_drain_direct_moves($result);

    ok(scalar @{ $result->{direct_moved_hashes} } == 1, 'drain adds hash to direct_moved_hashes');
    ok(scalar @{ $stub->{moves} } <= 1, 'move_message called at most once');
};

done_testing;
