#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Encode qw(decode);
use MIME::Base64 qw(decode_base64);
use feature 'signatures';
no warnings 'experimental::signatures';

# Test the _imap_utf7_decode helper directly by duplicating its logic.
# Services::IMAP::Client cannot be loaded standalone (Object::Pad class
# that requires the full POPFile runtime), so we test the decode logic here.

sub imap_utf7_decode ($chunk) {
    return '&' if $chunk eq '';
    (my $b = $chunk) =~ tr/+/\//;
    return decode('UTF-16BE', decode_base64($b))
}

sub decode_folder ($name) {
    $name =~ s{&([^-]*)-}{imap_utf7_decode($1)}ge;
    return $name
}

is(decode_folder('INBOX'),         'INBOX',             'plain ASCII unchanged');
is(decode_folder('Gesendet'),      'Gesendet',          'plain German ASCII unchanged');
is(decode_folder('&-'),            '&',                 'escaped ampersand');
is(decode_folder('Entw&APw-rfe'),  "Entw\x{fc}rfe",    'ü decoded (Entwürfe)');
is(decode_folder('Gel&APY-scht'),  "Gel\x{f6}scht",    'ö decoded (Gelöscht)');
is(decode_folder('Spa&AM8-m'),     "Spa\x{cf}m",       'non-ASCII mid-word');

done_testing;
