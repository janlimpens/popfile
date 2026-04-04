#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;
use Services::Database;

my $db = Services::Database->new();

ok($db->DOES('POPFile::Role::SQL'), 'Services::Database composes POPFile::Role::SQL');
ok($db->can('normalize_sql'), 'normalize_sql available');
ok($db->can('validate_sql_prepare_and_execute'), 'validate_sql_prepare_and_execute available');
ok($db->can('db'), 'db() method present');

is($db->normalize_sql("  SELECT  *  FROM   foo  "), 'SELECT * FROM foo', 'normalize_sql strips and collapses whitespace');
is($db->normalize_sql("SELECT\n*\nFROM\tfoo"), 'SELECT * FROM foo', 'normalize_sql handles tabs and newlines');

done_testing;
