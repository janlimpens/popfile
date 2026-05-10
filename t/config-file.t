#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use File::Temp qw(tempdir);

my $tmpdir = tempdir(CLEANUP => 1);
my $json_path = "$tmpdir/test.json";

sub make_cf {
    require POPFile::ConfigFile;
    return POPFile::ConfigFile->new()
}

subtest 'save and load basic values' => sub {
    my $cf = make_cf();
    my $data = { version => 2, test => { key => 'value' } };
    $cf->save($json_path, $data);
    ok(-e $json_path, 'JSON file written');
    my $loaded = $cf->load($json_path);
    is($loaded->{test}{key}, 'value', 'string value round-trip');
};

subtest 'save and load numbers and booleans' => sub {
    my $cf = make_cf();
    my $data = { version => 2, s => { num => 42, flag => 1, zero => 0 } };
    $cf->save($json_path, $data);
    my $loaded = $cf->load($json_path);
    is($loaded->{s}{num}, 42, 'integer round-trip');
    is($loaded->{s}{flag}, 1, 'truthy value round-trip');
    is($loaded->{s}{zero}, 0, 'zero round-trip');
};

subtest 'save and load UTF-8 special characters' => sub {
    my $cf = make_cf();
    my $data = { version => 2, imap => { hostname => "m\x{e4}il.example.com" } };
    $cf->save($json_path, $data);
    my $loaded = $cf->load($json_path);
    is($loaded->{imap}{hostname}, "m\x{e4}il.example.com", 'UTF-8 umlaut round-trip');
};

subtest 'save and load empty values' => sub {
    my $cf = make_cf();
    my $data = { version => 2, s => { empty_str => '' } };
    $cf->save($json_path, $data);
    my $loaded = $cf->load($json_path);
    is($loaded->{s}{empty_str}, '', 'empty string survives round-trip');
};

subtest 'save replaces existing file' => sub {
    my $cf = make_cf();
    $cf->save($json_path, { version => 2, a => { x => 1 } });
    $cf->save($json_path, { version => 2, b => { y => 2 } });
    my $loaded = $cf->load($json_path);
    ok(!exists $loaded->{a}, 'old key removed');
    is($loaded->{b}{y}, 2, 'new value present');
};

done_testing;
