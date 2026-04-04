#!/usr/bin/env perl
# SPDX-License-Identifier: GPL-3.0-or-later
use strict;
use warnings;
use feature 'say';
use Path::Tiny;

my $root = $ENV{POPFILE_ROOT} // '.';
my $cfg = path($root)->child('popfile.cfg');

my $host = $ENV{POP3_SERVER} // 'localhost';
my $port = $ENV{POP3_SERVER_PORT} // 10110;
my $ssl = $ENV{POP3_SERVER_SSL} // 0;

my %overrides = (
    pop3_port => 1110,
    pop3_server => $host,
    pop3_server_port => $port,
    pop3_server_ssl => $ssl,
    pop3_local => 1,
    pop3_enabled => 1,
);

my %params;

if ($cfg->exists) {
    for ($cfg->lines) {
        chomp;
        my ($key, $val) = split ' ', $_, 2;
        $params{$key} = $val // '';
    }
}

$params{$_} = $overrides{$_}
    for keys %overrides;

$cfg->spew(join "\n", map { "$_ $params{$_}" } sort keys %params);
$cfg->append("\n");

say "Written: $cfg";
