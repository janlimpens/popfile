#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);

use Test2::V0;

my $lang_dir = "$Bin/../languages";

sub parse_keys {
    my ($file) = @_;
    open my $fh, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!";
    my %keys;
    while (<$fh>) {
        chomp;
        next if /^\s*#/ || /^\s*$/;
        $keys{$1} = 1 if /^(\S+)/;
    }
    close $fh;
    return %keys
}

my %en = parse_keys("$lang_dir/en.msg");

# Full files must have all keys, override files inherit from their base
my @full = ('de.msg', 'pt.msg');
my @overrides = (
    ['pt-BR.msg', 'pt.msg'],
);

for my $file (@full) {
    my %lang = parse_keys("$lang_dir/$file");
    my @missing = sort grep { !exists $lang{$_} } keys %en;
    is(\@missing, [], "No keys missing from $file");
}

for my $pair (@overrides) {
    my ($ov_file, $base_file) = @$pair;
    my %ov = parse_keys("$lang_dir/$ov_file");
    my %base = parse_keys("$lang_dir/$base_file");
    my @extra = sort grep { !exists $base{$_} } keys %ov;
    is(\@extra, [], "$ov_file contains no extra keys beyond $base_file");
}

done_testing;
