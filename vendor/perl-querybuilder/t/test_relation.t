use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Expression::Relation;
use Query::Builder;

subtest 'column name' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $rel = Query::Expression::Relation->new(
        table => 'table',
        name => 'name' );
    is $rel, 'table.name', 'mit table';
    $rel->as('column');
    is $rel, 'table.name AS column', 'mit alias';
};

done_testing();
