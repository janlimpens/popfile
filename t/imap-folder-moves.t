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
    sub new { bless { uv => {}, un => {} }, shift }
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
    sub get_new_message_list_unselected { () }
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

subtest 'request_folder_move schedules uid_next reset for watched folder' => sub {
    my ($imap) = make_imap();
    $log->clear();

    $imap->request_folder_move('deadbeef', 'work');

    my @reset_msgs = grep { /Scheduling uid_next reset/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @reset_msgs >= 1, 'uid_next reset scheduled for at least one folder');
};

subtest 'request_folder_move resets output folder when message is in history' => sub {
    my ($imap) = make_imap();
    $log->clear();

    $imap->request_folder_move('deadbeef', 'personal');

    my @reset_msgs = grep { /Scheduling uid_next reset/ } map { $_->{message} } @{ $log->msgs() };
    my $reset_for_work = grep { /Work/ } @reset_msgs;
    ok($reset_for_work >= 1, 'uid_next reset scheduled for output folder Work');
};

subtest 'output folder is scanned for pending_folder_moves' => sub {
    my ($imap, $config) = make_imap();
    my $stub = StubIMAPClient->new();
    my @scanned;
    no warnings 'redefine';
    local *Services::IMAP::new_imap_client  = sub { $stub };
    local *Services::IMAP::scan_folder      = sub { push @scanned, $_[1] };

    $imap->_run_poll_work();

    my $inbox_scanned = grep { $_ eq 'INBOX' } @scanned;
    my $work_scanned  = grep { $_ eq 'Work'  } @scanned;
    ok($inbox_scanned, 'watched folder INBOX was scanned');
    ok($work_scanned,  'output folder Work was scanned');
};

done_testing;
