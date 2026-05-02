use v5.40;
use Test2::V0 -target => 'Query::Builder';

subtest 'EXISTS expression' => sub {
    my $qb = $CLASS->new(dialect => 'sqlite');
    my $sub = $qb->select('1')
        ->from('matrix mf')
        ->joins($qb->join('buckets bf', on => $qb->combine_and(
            $qb->compare('bf.id', \'mf.bucketid'),
            $qb->compare('bf.name', 'mybucket'))))
        ->where($qb->compare('mf.wordid', \'w.id'));
    my $exists = $qb->exists($sub);
    my $sql = $exists->as_sql();
    like($sql, qr/EXISTS\s*\(\s*SELECT\s+1\s+FROM\s+matrix mf/, 'EXISTS wraps subquery');
    like($sql, qr/bf\.name\s*=\s*\?/, 'parameter in subquery');
    my @params = $exists->params();
    is(scalar @params, 1, 'EXISTS params');
    is($params[0], 'mybucket', 'EXISTS param value');
};

subtest 'EXISTS in WHERE' => sub {
    my $qb = $CLASS->new(dialect => 'sqlite');
    my $sub = $qb->select('1')
        ->from('words w2')
        ->where($qb->compare('w2.id', \'w.id'));
    my $where = $qb->combine_and(
        $qb->compare('w.word', 'test'),
        $qb->exists($sub));
    my $sql = $where->as_sql();
    like($sql, qr/EXISTS.*SELECT/, 'EXISTS combined in WHERE');
};

done_testing;
