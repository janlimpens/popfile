use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Builder;
use Query::Expression::Compound;
use DDP;

subtest 'and' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $compound = Query::Expression::Compound->new(
        expressions => ['foo', 'bar'] );
    is $compound, 'foo AND bar';
    my @parts = $compound->parts();
};

subtest 'and and or' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $compound = Query::Expression::Compound->new(
        expressions => ['foo', 'bar', Query::Expression::Compound->new(
            junctor => 'OR',
            expressions => ['baz', 'qux'],
        )] );
    is $compound, 'foo AND bar AND ( baz OR qux )', 'parens added in mixed or and and';
};

done_testing();
