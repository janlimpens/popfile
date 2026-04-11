use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Builder;
use Query::Expression::Comparison;
use DDP;

subtest construct => sub {
    my $c = Query::Expression::Comparison->new(
        column => 'foo',
        value => 'bar' );
    is $c, 'foo = ?', 'query';
    is [$c->params()], ['bar'];
};

subtest 'equals' => sub {
    ok 1;
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cmp = $qb->compare(foo => 'bar');
    is $cmp, 'foo = ?', 'as sql';
    is [$cmp->params()], ['bar'];
    $cmp->negate();
    is $cmp, 'foo <> ?', 'as sql negated';
};

subtest 'null' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cmp = $qb->compare(foo => undef);
    is $cmp, 'foo IS NULL', 'as sql';
    is [$cmp->params()], [], 'no params';
    $cmp->negate();
    is $cmp, 'foo IS NOT NULL', 'as sql negated';
};

subtest 'literals' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cmp = $qb->compare(foo => \'bar');
    is $cmp, 'foo = bar', 'as sql';
    is [$cmp->params()], [], 'no params';
    $cmp->negate();
    is $cmp, 'foo <> bar', 'as sql negated';
};

subtest 'arrays' => sub{
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cmp = $qb->compare(foo => [1, 2, 3]);
    is $cmp, 'foo IN (?, ?, ?)', 'as sql';
    is [$cmp->params()], [1, 2, 3];
    $cmp->negate();
    is $cmp, 'foo NOT IN (?, ?, ?)', 'as sql negated';
};

subtest 'in with subselect' => sub{
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $sub = $qb->select('bar')->from('baz');
    my $cmp = $qb->compare(foo => $sub, comparator => 'IN');
    is $cmp, 'foo IN ( SELECT bar FROM baz )', 'as sql';
    is [$cmp->params()], [];
    $cmp->negate();
    is $cmp, 'foo NOT IN ( SELECT bar FROM baz )', 'as sql negated';
};

subtest 'unhandled' => sub{
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cmp = $qb->compare(foo => 'bar', comparator => '&&');
    is $cmp, 'foo && ?', 'as sql';
    is [$cmp->params()], ['bar'];
    $cmp->negate();
    is $cmp, 'NOT ( foo && ? )', 'as sql negated';
};

subtest wrap => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cmp = $qb->compare(foo => 'bar', comparator => '&&');
    $cmp ->wrap();
    is $cmp, '( foo && ? )', 'as sql';
    $cmp->negate();
    is $cmp, 'NOT ( foo && ? )', 'as sql with not';
    $cmp->as('baz');
    is $cmp, 'NOT ( foo && ? ) AS baz', 'as sql with custom as';
};

done_testing();
