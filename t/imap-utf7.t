#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;

use Services::IMAP::Folder;

# Test the UTF-7 round-trip for full folder names
subtest 'ASCII folder names pass through unchanged' => sub {
    my $f = Services::IMAP::Folder->new(name => 'INBOX');
    is($f->to_imap_name(), 'INBOX', 'INBOX unchanged');
    is($f->name(), 'INBOX', 'name preserved');
    
    my $f2 = Services::IMAP::Folder->new(name => 'Sent');
    is($f2->to_imap_name(), 'Sent', 'Sent unchanged');
    
    my $f3 = Services::IMAP::Folder->new(name => 'Archive.2024');
    is($f3->to_imap_name(), 'Archive.2024', 'dots preserved');
};

subtest 'German umlauts encoded correctly (RFC 3501 examples)' => sub {
    # These are the classic IMAP Modified UTF-7 examples
    my $f = Services::IMAP::Folder->new(name => "Entw\x{fc}rfe");
    is($f->to_imap_name(), 'Entw&APw-rfe', 'Entwürfe encoded');
    
    my $f2 = Services::IMAP::Folder->new(name => "Gel\x{f6}scht");
    is($f2->to_imap_name(), 'Gel&APY-scht', 'Gelöscht encoded');
    
    my $f3 = Services::IMAP::Folder->new(name => "Pers\x{f6}nlich");
    is($f3->to_imap_name(), 'Pers&APY-nlich', 'Persönlich encoded');
};

subtest 'Ampersand in folder name is escaped' => sub {
    my $f = Services::IMAP::Folder->new(name => 'A&B');
    is($f->to_imap_name(), 'A&-B', 'ampersand escaped as &-');
    
    my $f2 = Services::IMAP::Folder->new(name => 'a&b&c');
    is($f2->to_imap_name(), 'a&-b&-c', 'multiple ampersands');
};

subtest 'from_imap_name decodes encoded names back to UTF-8' => sub {
    my $f = Services::IMAP::Folder::from_imap_name('Entw&APw-rfe');
    is($f->name(), "Entw\x{fc}rfe", 'Entwürfe decoded');
    is($f->imap_name(), 'Entw&APw-rfe', 'original IMAP name preserved');
    
    my $f2 = Services::IMAP::Folder::from_imap_name('INBOX');
    is($f2->name(), 'INBOX', 'INBOX decoded');
    is($f2->imap_name(), 'INBOX', 'original preserved');
    
    my $f3 = Services::IMAP::Folder::from_imap_name('A&-B');
    is($f3->name(), 'A&B', 'ampersand decoded');
};

subtest 'Round trip: encode then decode' => sub {
    my @names = (
        'INBOX',
        'Junk',
        'Entwürfe',
        'Gelöscht',
        "Spa\x{df}",
        'A&B',
        'Test.Folder',
        'Café',
    );
    for my $name (@names) {
        my $f = Services::IMAP::Folder->new(name => $name);
        my $encoded = $f->to_imap_name();
        my $f2 = Services::IMAP::Folder::from_imap_name($encoded);
        is($f2->name(), $name, "round-trip: $name");
    }
};

subtest 'CJK characters encoded correctly' => sub {
    my $f = Services::IMAP::Folder->new(name => "\x{65e5}\x{672c}\x{8a9e}");
    my $encoded = $f->to_imap_name();
    my $f2 = Services::IMAP::Folder::from_imap_name($encoded);
    is($f2->name(), "\x{65e5}\x{672c}\x{8a9e}", 'CJK round-trip');
};

subtest 'Mixed ASCII and non-ASCII' => sub {
    my $f = Services::IMAP::Folder->new(name => "INBOX.Entw\x{fc}rfe.2024");
    is($f->to_imap_name(), 'INBOX.Entw&APw-rfe.2024', 'mixed section encoding');
    
    my $f2 = Services::IMAP::Folder::from_imap_name('INBOX.Entw&APw-rfe.2024');
    is($f2->name(), "INBOX.Entw\x{fc}rfe.2024", 'mixed section decoded');
};

subtest '_imap_utf7_to_utf8 handles edge cases' => sub {
    is(Services::IMAP::Folder::_imap_utf7_to_utf8(''), '', 'empty string');
    is(Services::IMAP::Folder::_imap_utf7_to_utf8(undef), '', 'undef returns empty');
    is(Services::IMAP::Folder::_imap_utf7_to_utf8('&-'), '&', 'escaped ampersand');
};

done_testing;
