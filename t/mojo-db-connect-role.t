#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use File::Temp qw(tempfile);
use POPFile::Database;

my ($fh, $tmpfile) = tempfile(SUFFIX => '.db', UNLINK => 1);
close $fh;

my $db = POPFile::Database->instance(
    dbconnect => 'dbi:SQLite:dbname=$dbname',
    database => $tmpfile);

subtest 'get_handle returns a live DBI handle' => sub {
    my $dbh = $db->get_handle();
    ok(defined $dbh, 'get_handle returns defined value');
    ok($dbh->ping(), 'handle is alive');
};

subtest 'get_handle returns cached handle' => sub {
    my $dbh1 = $db->get_handle();
    my $dbh2 = $db->get_handle();
    is($dbh1, $dbh2, 'same handle on repeated calls');
};

subtest 'disconnect clears handle' => sub {
    $db->disconnect();
    my $dbh = $db->get_handle(database => ':memory:');
    ok(defined $dbh, 'reconnect after disconnect works');
    ok($dbh->ping(), 'reconnected handle is alive');
};

done_testing;
