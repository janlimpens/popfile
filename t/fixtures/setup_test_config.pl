#!/usr/bin/env perl
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use strict;
use warnings;
use feature 'say';
use Path::Tiny;

my $root = $ENV{POPFILE_ROOT} // '.';
my $cfg = path($root)->child('popfile.cfg');

my $host = $ENV{IMAP_HOST} // 'localhost';
my $port = $ENV{IMAP_PORT} // 10143;
my $user = $ENV{IMAP_USER} // 'testuser';
my $pass = $ENV{IMAP_PASS} // 'testpass';

my %overrides = (
    imap_hostname => $host,
    imap_port => $port,
    imap_login => $user,
    imap_password => $pass,
    imap_enabled => 1,
    imap_training_mode => 1,
    imap_watched_folders => 'INBOX:INBOX.spam:',
    imap_use_ssl => 0,
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
