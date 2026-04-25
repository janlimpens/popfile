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

my %en = parse_keys("$lang_dir/English.msg");
my @enforced = ('Deutsch.msg', 'Portugues.msg', 'Portugues-do-Brasil.msg');

for my $file (@enforced) {
    my %lang = parse_keys("$lang_dir/$file");
    my @missing = sort grep { !exists $lang{$_} } keys %en;
    is(\@missing, [], "No keys missing from $file");
}

done_testing;
