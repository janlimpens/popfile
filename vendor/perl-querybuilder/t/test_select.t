use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Builder;

subtest 'from readme' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $cte = $qb->select($qb->relation('id')->as('theater_id'), 'name', 'city')
        ->from('venues')
        ->as('theaters')
        ->where($qb->compare(type => 'theater'));
    my $join_1 = $qb->join('roles')
        ->type('LEFT')
        ->as('r')
        ->on( $qb->compare('r.actor_id', \'a.id') );
    my $join_2 = $qb->join('theaters')
        ->as('t')
        ->using('theater_id');
    my $sql = $qb->select(qw(id first_name last_name gender birthday r.title r.date t.name t.city))
        ->from('actors a')
        ->with($cte)
        ->joins($join_1, $join_2)
        ->where(
            $qb->combine(AND =>
                $qb->is_true('a.active'),
                $qb->compare('a.age', 30, comparator => '>')))
        ->order_by(
            $qb->order_by('a.birthday', 'DESC'),
            $qb->order_by('a.last_name'))
        ->limit(100)
        ->offset(100);
    is $sql, 'WITH ( SELECT id AS theater_id, name, city FROM venues WHERE type = ? ) AS theaters SELECT id, first_name, last_name, gender, birthday, r.title, r.date, t.name, t.city FROM actors a LEFT JOIN roles AS r ON r.actor_id = a.id JOIN theaters AS t USING ( theater_id ) WHERE a.active AND a.age > ? ORDER BY a.birthday DESC, a.last_name LIMIT ? OFFSET ?', 'got good sql';
};

subtest clone => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $q = $qb->select($qb->relation('id')->as('theater_id'), 'name', 'city')
        ->from('venues')
        ->where($qb->compare(type => 'theater'));
    my $count = $q->clone(columns => ['COUNT(*)']);
    is $count, 'SELECT COUNT(*) FROM venues WHERE type = ?', 'cloned successfully';
    is [$count->params()], ['theater'], 'params cloned successfully';
};

done_testing();
