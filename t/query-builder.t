#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";
BEGIN { push @INC, "$FindBin::Bin/../lib" }

use Test2::V0;

use Query::Builder;
use Query::Expression;

my $qb_sqlite = Query::Builder->new(dialect => 'sqlite');
my $qb_mysql  = Query::Builder->new(dialect => 'mysql');

subtest 'SQLite multi-value non-negated uses IN' => sub {
    my $expr = $qb_sqlite->compare('word', ['foo', 'bar']);
    like $expr->as_sql(), qr/\bIN\b/, 'non-negated multi-value uses IN';
    unlike $expr->as_sql(), qr/\bOR\b/, 'non-negated multi-value does not use OR';
    is scalar($expr->params()), 2, 'two bind params';
};

subtest 'SQLite multi-value negated uses NOT IN' => sub {
    my $expr = $qb_sqlite->compare('word', ['foo', 'bar'], negated => 1);
    like $expr->as_sql(), qr/NOT IN/, 'negated multi-value uses NOT IN';
    is scalar($expr->params()), 2, 'two bind params';
};

subtest 'MySQL multi-value non-negated uses IN' => sub {
    my $expr = $qb_mysql->compare('col', ['a', 'b', 'c']);
    like $expr->as_sql(), qr/\bIN\b/, 'non-negated multi-value uses IN';
    is scalar($expr->params()), 3, 'three bind params';
};

subtest 'History search: bindings not in SQL string' => sub {
    my $pat = '%hello%';
    my $expr = $qb_sqlite->combine_or(
        $qb_sqlite->like('hdr_from', $pat),
        $qb_sqlite->like('hdr_subject', $pat));
    unlike $expr->as_sql(), qr/hello/, 'search term not in SQL string';
    like $expr->as_sql(), qr/\?/, 'SQL uses placeholders';
    my @params = $expr->params();
    is scalar(@params), 2, 'two bind params';
    is $params[0], $pat, 'first param is search pattern';
    is $params[1], $pat, 'second param is search pattern';
};

subtest 'Bayes word lookup: correct SQL and params for SQLite' => sub {
    my @words = qw(alpha beta gamma);
    my $expr = $qb_sqlite->compare('word', \@words);
    like $expr->as_sql(), qr/\bIN\b/, 'multiple words use IN';
    unlike $expr->as_sql(), qr/alpha|beta|gamma/, 'words not in SQL string';
    my @params = $expr->params();
    is scalar(@params), 3, 'three bind params for three words';
    is [sort @params], [sort @words], 'params match word list';
};

subtest 'Single value compare uses plain equality' => sub {
    my $expr = $qb_sqlite->compare('buckets.name', 'inbox');
    like $expr->as_sql(), qr/buckets\.name = \?/, 'single value equality';
    is scalar($expr->params()), 1, 'one bind param';
    my ($p) = $expr->params();
    is $p, 'inbox', 'param is the filter value';
};

subtest 'IN-list pattern: multi-value compare uses IN' => sub {
    my @words = qw(alpha beta gamma);
    my $expr = $qb_sqlite->compare('word', \@words);
    like $expr->as_sql(), qr/\bIN\b/, 'multi-value uses IN';
    unlike $expr->as_sql(), qr/alpha|beta|gamma/, 'words not in SQL string';
    my @params = $expr->params();
    is scalar(@params), 3, 'three bind params for three words';
    is [sort @params], [sort @words], 'params match word list';
};

subtest 'IN-list pattern: single-element array uses IN' => sub {
    my @words = ('only');
    my $expr = $qb_sqlite->compare('word', \@words);
    like $expr->as_sql(), qr/word IN \(\?\)/, 'single-element array uses IN';
    my ($p) = $expr->params();
    is $p, 'only', 'param matches word';
};

subtest 'Expression stringifies automatically' => sub {
    my $expr = $qb_sqlite->compare('x', 'val');
    my $str = "$expr";
    like $str, qr/x = \?/, 'expression stringifies via overload';
};

done_testing;
