#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

require Services::IMAP;

# Test that preview_reclassification calls classifier->classify() with
# correct arguments: ($session_key, $file) — NOT ($classifier_obj, ...)
{
    package StubClassifier;
    sub new              { bless {}, shift }
    sub get_session_key  { 'test-session-key' }
    sub get_all_buckets  { ('newsletter', 'unclassified') }
    sub is_pseudo_bucket { 0 }
    our ($called_session, $called_file);
    sub classify {
        my ($self, $session, $file) = @_;
        $called_session = $session;
        $called_file = $file;
        return 'newsletter';
    }
}

{
    package StubHistory;
    sub new { bless {}, shift }
    sub get_message_hash { 'hash-newsletter-42' }
}

my $email_text = <<'EMAIL';
From: newsletter@example.com
To: user@example.com
Subject: Weekly Digest
Date: Mon, 2 Jun 2026 10:00:00 +0000
Message-ID: <newsletter-42@example.com>

This is the weekly newsletter with updates and tips.
EMAIL

subtest 'preview_reclassification passes correct args to classifier->classify' => sub {
    my ($config, $mq) = TestHelper::setup();
    TestHelper::configure_db($config);
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->start();
    $imap->set_classifier(StubClassifier->new());
    $imap->set_history(StubHistory->new());
    TestHelper::set_config($config, 'imap_enabled' => 1);
    TestHelper::set_config($config, 'imap_update_interval' => 20);
    $imap->folder_for_bucket('unclassified', 'unclassified');
    TestHelper::load_singleton($config);

    my @raw_lines = split /\n/, $email_text;
    push @raw_lines, '';

    my $stub = bless {
        uidnext   => 10,
        uidvalid  => 1,
        uids      => [9],
        batch     => { 9 => \@raw_lines },
    }, 'StubIMAPClient';

    no warnings 'redefine', 'once';
    local *Services::IMAP::new_imap_client = sub { $stub };

    {
        package StubIMAPClient;
        sub status                { my $s = shift; { UIDNEXT => $s->{uidnext}, UIDVALIDITY => $s->{uidvalid} } }
        sub get_all_message_uids  { my ($s, $f, $lim) = @_; my @u = $s->{uids}->@*; splice @u, $lim if $lim && @u > $lim; return @u }
        sub fetch_messages_batch  { my ($s, $uids) = @_; my %b; $b{$_} = $s->{batch}{$_} for @$uids; return %b }
        sub logout                {}
    }

    my $preview = $imap->preview_reclassification('unclassified', 5);

    ok(defined $StubClassifier::called_session, 'classify was called');
    is($StubClassifier::called_session, 'test-session-key', 'session argument is the session key string');
    like($StubClassifier::called_file, qr/imap\.tmp/, 'file argument is a temp file path');
    unlike($StubClassifier::called_session, qr/StubClassifier/, 'session is NOT a classifier object');

    is(scalar($preview->{messages}->@*), 1, 'found one reclassification mismatch');
    is($preview->{messages}[0]{classified_bucket}, 'newsletter', 'classified as newsletter');
};

done_testing;
