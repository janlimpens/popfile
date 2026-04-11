use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Builder;

subtest 'new order' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $order_by = $qb->order_by('stuff')->direction('desc');
    is $order_by, 'stuff DESC', 'order by generated';
};

done_testing();
