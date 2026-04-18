#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use POPFile::Role::SQL;
use Classifier::Bayes;
use POPFile::History;

ok(Classifier::Bayes->DOES('POPFile::Role::SQL'), 'Bayes composes POPFile::Role::SQL');
ok(POPFile::History->DOES('POPFile::Role::SQL'),  'History composes POPFile::Role::SQL');

for my $class (qw(Classifier::Bayes POPFile::History)) {
    ok($class->can('normalize_sql'), "$class has normalize_sql()");
    ok($class->can('validate_sql_prepare_and_execute'), "$class has validate_sql_prepare_and_execute()");
    ok($class->can('qb'), "$class has qb()");
}

{
    package TestSQL;
    use Object::Pad;
    use lib 'vendor/perl-querybuilder/lib';
    use POPFile::Role::SQL;
    class TestSQL :does(POPFile::Role::SQL);
    method db() { return undef }
}

my $obj = TestSQL->new();
is($obj->normalize_sql("  SELECT  *  FROM   foo  "), 'SELECT * FROM foo',
    'normalize_sql strips and collapses whitespace');
is($obj->normalize_sql("SELECT\n*\nFROM\tfoo"), 'SELECT * FROM foo',
    'normalize_sql handles tabs and newlines');

done_testing;
