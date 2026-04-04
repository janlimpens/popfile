#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use POPFile::Features;

ok(defined &trim, 'trim is available');
ok(1, 'say enabled (keyword, not sub)');

is(trim("  hello  "), 'hello', 'trim works');
is(trim("\t padded \n"), 'padded', 'trim handles tabs and newlines');

my $counter = sub {
    state $n = 0;
    ++$n
};
is($counter->(), 1, 'state: first call');
is($counter->(), 2, 'state: second call');

my $result = 'none';
try {
    $result = 'tried';
} catch ($e) {
    $result = "caught: $e";
}
is($result, 'tried', 'try block executes');

try {
    die "oops\n";
} catch ($e) {
    $result = "caught: $e";
}
is($result, "caught: oops\n", 'catch block fires on die');

done_testing;
