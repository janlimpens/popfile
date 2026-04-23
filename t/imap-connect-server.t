#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

require Services::IMAP;

{
    package StubIMAPClient;
    sub new               { bless { uid_validity => {}, uid_next => {} }, shift }
    sub connected         { 1 }
    sub get_mailbox_list  { () }
    sub status            { { UIDNEXT => 1, UIDVALIDITY => 42 } }
    sub create_folder     {}
    sub uid_validity      { my ($self, $f, $v) = @_; $self->{uid_validity}{$f} = $v if defined $v; $self->{uid_validity}{$f} }
    sub uid_next          { my ($self, $f, $v) = @_; $self->{uid_next}{$f} = $v if defined $v; $self->{uid_next}{$f} }
    sub check_uidvalidity { 1 }
    sub logout            {}
    sub noop              {}
}

{
    package StubClassifier;
    sub new              { bless {}, shift }
    sub get_session_key  { 'session' }
    sub get_all_buckets  { () }
    sub is_pseudo_bucket { 0 }
}

sub make_imap {
    my ($config, $mq) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->set_classifier(StubClassifier->new());
    $config->parameter('imap_enabled', 1);
    $config->parameter('imap_training_mode', 0);
    return ($imap, $config)
}

subtest 'all watched folders are scanned in a single poll cycle' => sub {
    my ($imap, $config) = make_imap();
    $config->parameter('imap_watched_folders', 'INBOX-->Spam-->Ham-->');

    my $stub = StubIMAPClient->new();
    my @scanned;
    no warnings 'redefine';
    local *Services::IMAP::new_imap_client = sub { $stub };
    local *Services::IMAP::scan_folder     = sub { push @scanned, $_[1] };

    my $result = $imap->_run_poll_work();

    ok(!defined $result->{error}, 'poll completed without error')
        or diag("error: $result->{error}");
    is(scalar @scanned, 3, 'scan_folder called for all three watched folders');
    ok((grep { $_ eq 'INBOX' } @scanned), 'INBOX was scanned');
    ok((grep { $_ eq 'Spam'  } @scanned), 'Spam was scanned');
    ok((grep { $_ eq 'Ham'   } @scanned), 'Ham was scanned');
};

subtest 'one shared IMAP connection is used for all folders' => sub {
    my ($imap, $config) = make_imap();
    $config->parameter('imap_watched_folders', 'INBOX-->Spam-->Ham-->');

    my $client_calls = 0;
    my $stub = StubIMAPClient->new();
    no warnings 'redefine';
    local *Services::IMAP::new_imap_client = sub { $client_calls++; $stub };
    local *Services::IMAP::scan_folder     = sub {};

    $imap->_run_poll_work();

    is($client_calls, 1, 'new_imap_client() called exactly once for three folders');
};

subtest 'two consecutive polls reuse the existing connection' => sub {
    my ($imap, $config) = make_imap();
    $config->parameter('imap_watched_folders', 'INBOX-->Spam-->');

    my $client_calls = 0;
    my $stub = StubIMAPClient->new();
    no warnings 'redefine';
    local *Services::IMAP::new_imap_client = sub { $client_calls++; $stub };
    local *Services::IMAP::scan_folder     = sub {};

    $imap->_run_poll_work();
    $imap->_run_poll_work();

    is($client_calls, 1, 'connection created only once across two polls');
};

done_testing;
