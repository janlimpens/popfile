#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use File::Temp qw(tempfile);

{
    package TestDB;
    use Object::Pad;
    class TestDB :does(POPFile::Role::DBConnect);

    method config ($key, $default = undef) {
        return 'sqlite'
            if $key eq 'dbtype';
        return $default
    }
}

my ($fh, $tmpfile) = tempfile(SUFFIX => '.db', UNLINK => 1);
close $fh;

my $obj = TestDB->new();

subtest '_connect returns a DBI handle' => sub {
    my $dbh = $obj->_connect($tmpfile, sqlite_unicode => 1);
    ok(defined $dbh, '_connect returns defined value');
    ok($dbh->ping(), 'handle is alive after connect');
};

subtest 'db() returns the same live DBI handle' => sub {
    my $dbh = $obj->db();
    ok(defined $dbh, 'db() is defined');
    ok($dbh->ping(), 'db() handle is alive');
};

subtest 'mojo() returns a Mojo::SQLite instance' => sub {
    my $mojo = $obj->mojo();
    ok(defined $mojo, 'mojo() is defined');
    like(ref($mojo), qr/Mojo/, 'mojo() is a Mojo object');
};

subtest '_disconnect clears both db and mojo' => sub {
    $obj->_disconnect();
    ok(!defined $obj->db(), 'db() undef after disconnect');
    ok(!defined $obj->mojo(), 'mojo() undef after disconnect');
};

subtest 'reconnect after disconnect works' => sub {
    my ($fh2, $tmpfile2) = tempfile(SUFFIX => '.db', UNLINK => 1);
    close $fh2;
    my $dbh = $obj->_connect($tmpfile2);
    ok(defined $dbh, '_connect works after prior disconnect');
    ok($dbh->ping(), 'reconnected handle is alive');
};

done_testing;
