#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";
BEGIN { push @INC, "$FindBin::Bin/../lib" }

use Test2::V0;

use Query::Builder;
use Query::Expression;

my $qb_sqlite = Query::Builder->new(dialect => 'sqlite');
my $qb_mysql  = Query::Builder->new(dialect => 'mysql');

subtest 'SQLite multi-value non-negated uses OR' => sub {
    my $expr = $qb_sqlite->compare('word', ['foo', 'bar']);
    like $expr->to_string(), qr/OR/, 'non-negated multi-value uses OR';
    unlike $expr->to_string(), qr/\bAND\b/, 'non-negated multi-value does not use AND';
    is scalar($expr->params()->@*), 2, 'two bind params';
};

subtest 'SQLite multi-value negated uses AND' => sub {
    my $expr = $qb_sqlite->compare('word', ['foo', 'bar'], negated => 1);
    like $expr->to_string(), qr/AND/, 'negated multi-value uses AND';
    is scalar($expr->params()->@*), 2, 'two bind params';
};

subtest 'MySQL multi-value non-negated uses OR' => sub {
    my $expr = $qb_mysql->compare('col', ['a', 'b', 'c']);
    like $expr->to_string(), qr/OR/, 'non-negated multi-value uses OR';
    is scalar($expr->params()->@*), 3, 'three bind params';
};

subtest 'History search: bindings not in SQL string' => sub {
    my $pat = '%hello%';
    my $expr = $qb_sqlite->combine_or(
        $qb_sqlite->like('hdr_from', $pat),
        $qb_sqlite->like('hdr_subject', $pat));
    unlike $expr->to_string(), qr/hello/, 'search term not in SQL string';
    like $expr->to_string(), qr/\?/, 'SQL uses placeholders';
    my @params = $expr->params()->@*;
    is scalar(@params), 2, 'two bind params';
    is $params[0], $pat, 'first param is search pattern';
    is $params[1], $pat, 'second param is search pattern';
};

subtest 'Bayes word lookup: correct SQL and params for SQLite' => sub {
    my @words = qw(alpha beta gamma);
    my $expr = $qb_sqlite->compare('word', \@words);
    like $expr->to_string(), qr/OR/, 'multiple words use OR';
    unlike $expr->to_string(), qr/alpha|beta|gamma/, 'words not in SQL string';
    my @params = $expr->params()->@*;
    is scalar(@params), 3, 'three bind params for three words';
    is [sort @params], [sort @words], 'params match word list';
};

subtest 'Single value compare uses plain equality' => sub {
    my $expr = $qb_sqlite->compare('buckets.name', 'inbox');
    like $expr->to_string(), qr/buckets\.name = \?/, 'single value equality';
    is scalar($expr->params()->@*), 1, 'one bind param';
    is $expr->params()->[0], 'inbox', 'param is the filter value';
};

subtest 'IN-list pattern: multi-value compare as OR' => sub {
    my @words = qw(alpha beta gamma);
    my $expr = $qb_sqlite->compare('word', \@words);
    like $expr->to_string(), qr/OR/, 'multi-value uses OR';
    unlike $expr->to_string(), qr/alpha|beta|gamma/, 'words not in SQL string';
    my @params = $expr->params()->@*;
    is scalar(@params), 3, 'three bind params for three words';
    is [sort @params], [sort @words], 'params match word list';
};

subtest 'IN-list pattern: single word is plain equality' => sub {
    my @words = ('only');
    my $expr = $qb_sqlite->compare('word', \@words);
    like $expr->to_string(), qr/word = \?/, 'single word uses equality';
    is $expr->params()->[0], 'only', 'param matches word';
};

done_testing;
