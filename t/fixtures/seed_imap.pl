#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use FindBin qw($Bin);
use Getopt::Long;
use Mail::IMAPClient;
use Path::Tiny;

my $teardown = 0;
GetOptions('teardown' => \$teardown);

my $host = $ENV{IMAP_HOST} // 'localhost';
my $port = $ENV{IMAP_PORT} // 10143;
my $user = $ENV{IMAP_USER} // 'test';
my $pass = $ENV{IMAP_PASS} // 'test';
my $count = $ENV{SEED_COUNT} // 100;

my $imap = Mail::IMAPClient->new(
    Server => $host,
    Port => $port,
    User => $user,
    Password => $pass,
    Uid => 1,
) or die "Cannot connect: $@";

my @templates = (
    (map { path($_)->slurp } glob("$Bin/ham/*.eml")),
    (map { path($_)->slurp } glob("$Bin/spam/*.eml")),
);

if ($teardown) {
    $imap->select('INBOX')
        or die "Cannot select INBOX: " . $imap->LastError;
    my @uids = $imap->search('ALL')
        or do { $imap->logout; say "Done."; exit 0 };
    $imap->set_flag('\\Deleted', @uids)
        or die "Cannot flag messages: " . $imap->LastError;
    $imap->expunge()
        or die "Cannot expunge: " . $imap->LastError;
    say "Expunged " . scalar(@uids) . " messages from INBOX";
    $imap->logout;
    say "Done.";
    exit 0;
}

unless ($imap->exists('INBOX')) {
    $imap->create('INBOX')
        or die "Cannot create INBOX: " . $imap->LastError;
    say "Created folder: INBOX";
}
for my $i (1 .. $count) {
    my $msg = $templates[$i % scalar @templates];
    $msg =~ s/^(Date:)[^\n]*/Date: ${\scalar localtime}/m;
    my $mid = sprintf('<seed-%d-%d@popfile.test>', $i, time());
    if ( $msg =~ /^Message-ID:/mi ) {
        $msg =~ s/^(Message-ID:)[^\n]*/$1 $mid/mi;
    } else {
        $msg = "Message-ID: $mid\n$msg";
    }
    $imap->append('INBOX', $msg)
        or die "Cannot append to INBOX: " . $imap->LastError;
}
say "Seeded $count messages into INBOX";

$imap->logout;
say "Done.";
