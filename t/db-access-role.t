#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Classifier::Bayes;
use POPFile::History;

ok(Classifier::Bayes->DOES('POPFile::Role::DBConnect'), 'Bayes composes POPFile::Role::DBConnect');
ok(POPFile::History->DOES('POPFile::Role::DBConnect'),  'History composes POPFile::Role::DBConnect');

for my $class (qw(Classifier::Bayes POPFile::History)) {
    ok($class->can('db'),           "$class has db()");
    ok($class->can('mojo'),         "$class has mojo()");
    ok($class->can('_connect'),     "$class has _connect()");
    ok($class->can('_disconnect'),  "$class has _disconnect()");
}

done_testing;
