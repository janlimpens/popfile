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
    sub get_all_buckets  { () }
    sub is_pseudo_bucket { 0 }
}

{
    package StubIMAPClient;
    sub new                             { bless { uv => {}, un => {} }, shift }
    sub connected                       { 1 }
    sub get_mailbox_list                { () }
    sub status                          { { UIDNEXT => 99, UIDVALIDITY => 1 } }
    sub create_folder                   {}
    sub uid_validity                    { my ($s,$f,$v) = @_; $s->{uv}{$f} = $v if defined $v; $s->{uv}{$f} }
    sub uid_next                        { my ($s,$f,$v) = @_; $s->{un}{$f} = $v if defined $v; $s->{un}{$f} // 1 }
    sub check_uidvalidity               { 1 }
    sub noop                            {}
    sub logout                          {}
    sub expunge                         {}
    sub get_new_message_list_unselected { (42) }
}

sub make_imap {
    my ($config, $mq) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->set_classifier(StubClassifier->new());
    $config->parameter('imap_enabled', 1);
    $config->parameter('imap_training_mode', 0);
    $config->parameter('imap_update_interval', 20);
    return ($imap, $config)
}

subtest 'second poll within limit is skipped and logged' => sub {
    my ($imap) = make_imap();
    my $subprocess_calls = 0;
    $log->clear();
    no warnings 'redefine';
    local *Mojo::IOLoop::subprocess = sub { $subprocess_calls++ };

    $imap->poll();
    is($subprocess_calls, 1, 'first poll starts subprocess');

    $imap->poll();
    is($subprocess_calls, 1, 'second poll does not start another subprocess');

    my @skipped = grep { /poll skipped/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @skipped >= 1, 'skip is logged');
};

subtest 'watchdog resets guard when age exceeds 3x interval' => sub {
    my ($imap, $config) = make_imap();
    $config->parameter('imap_update_interval', 1);
    my $subprocess_calls = 0;
    $log->clear();
    no warnings 'redefine';
    local *Mojo::IOLoop::subprocess = sub { $subprocess_calls++ };
    local *Services::IMAP::_poll_age = sub { 999 };

    $imap->poll();
    is($subprocess_calls, 1, 'first poll starts subprocess');

    $imap->poll();
    my @watchdog = grep { /watchdog/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @watchdog >= 1, 'watchdog log emitted when age exceeds 3x interval');
    is($subprocess_calls, 2, 'watchdog allows next poll to run');
};

subtest 'classify_message failure is logged in scan_folder' => sub {
    my ($imap, $config) = make_imap();
    $config->parameter('imap_watched_folders', 'INBOX-->');

    my $stub = StubIMAPClient->new();
    $log->clear();
    no warnings 'redefine';
    local *Services::IMAP::new_imap_client  = sub { $stub };
    local *Services::IMAP::get_hash         = sub { 'fakehash' };
    local *Services::IMAP::can_classify     = sub { 1 };
    local *Services::IMAP::classify_message = sub { return undef };

    $imap->build_folder_list();
    $imap->connect_server();
    $imap->scan_folder('INBOX');

    my @failed = grep { /classify_message failed/ } map { $_->{message} } @{ $log->msgs() };
    ok(scalar @failed >= 1, 'classify_message failure logged with UID and folder');
};

done_testing;
