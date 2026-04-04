#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;
use Classifier::Bayes;
use POPFile::History;

ok(Classifier::Bayes->DOES('POPFile::Role::DBAccess'), 'Bayes composes POPFile::Role::DBAccess');
ok(POPFile::History->DOES('POPFile::Role::DBAccess'),  'History composes POPFile::Role::DBAccess');

for my $class (qw(Classifier::Bayes POPFile::History)) {
    ok($class->can('_db'),       "$class has _db()");
    ok($class->can('_set_db'),   "$class has _set_db()");
    ok($class->can('_clear_db'), "$class has _clear_db()");
    ok($class->can('db'),        "$class has public db()");
}

done_testing;
