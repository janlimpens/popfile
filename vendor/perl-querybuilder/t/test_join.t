use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Expression::Join;
use Query::Builder;

subtest 'build join' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $join = Query::Expression::Join->new(
        table => 'some_table',
        on => $qb->compare(column => 'abc') );
    is $join, 'JOIN some_table ON column = ?', 'join generated';
    is [$join->params()], ['abc'], 'params';
};

done_testing();
