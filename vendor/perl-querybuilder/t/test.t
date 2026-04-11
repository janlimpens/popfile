use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Builder;

# Create a PostgreSQL query builder
my $qb = Query::Builder->new(dialect => 'pg');

subtest 'basic compare' => sub {
    my $equals = $qb->compare(name => 'Hansi');
    is $equals->as_sql(), 'name = ?', 'simple equality SQL';
    is [$equals->params()], ['Hansi'], 'simple equality params';
};

subtest 'multi-value compare with ANY' => sub {
    my $multi = $qb->compare(name => [qw(Hansi Hansi2)]);
    is $multi->as_sql(), 'name = ANY(?)', 'ANY SQL';
    is [$multi->params()], [qw(Hansi Hansi2)], 'ANY params';
};

subtest 'negated compare - single value' => sub {
    my $negated = $qb->compare(name => 'Hansi', negated => 1);
    is $negated->as_sql(), 'name <> ?', 'negated SQL';
    is [$negated->params()], ['Hansi'], 'negated params';
};

subtest 'negated compare - multiple values with != ALL' => sub {
    my $negated_multi = $qb->compare(name => [qw(Hansi Hansi2)], negated => 1);
    is $negated_multi->as_sql(), 'name != ALL(?)', 'negated != ALL SQL';
    is [$negated_multi->params()], [qw(Hansi Hansi2)], 'negated != ALL params';
};

subtest 'combine_and' => sub {
    my $and_expr = $qb->combine_and(
        $qb->compare(name => 'Hansi'),
        $qb->compare(age => '30', comparator => '>'));
    is $and_expr->as_sql(), 'name = ? AND age > ?', 'AND SQL';
    is [$and_expr->params()], ['Hansi', '30'], 'AND params';
};

subtest 'combine_or' => sub {
    my $or_expr = $qb->combine_or(
        $qb->compare(name => 'Hansi'),
        $qb->compare(name => 'Franz'));
    is $or_expr->as_sql(), 'name = ? OR name = ?', 'OR SQL';
    is [$or_expr->params()], ['Hansi', 'Franz'], 'OR params';
};

subtest 'is_true - literal' => sub {
    my $true_expr = $qb->is_true();
    is $true_expr->as_sql(), 'TRUE', 'literal TRUE SQL';
    is [$true_expr->params()], [], 'literal TRUE params';
};

subtest 'is_false - literal' => sub {
    my $false_expr = $qb->is_false();
    is $false_expr->as_sql(), 'FALSE', 'literal FALSE SQL';
    is [$false_expr->params()], [], 'literal FALSE params';
};

subtest 'is_true - with column' => sub {
    my $true_col = $qb->is_true('is_active');
    is $true_col->as_sql(), 'is_active', 'column TRUE SQL';
    is [$true_col->params()], [], 'column TRUE params';
};

subtest 'is_false - with column (negated)' => sub {
    my $false_col = $qb->is_false('is_active');
    is $false_col->as_sql(), 'NOT ( is_active )', 'column FALSE SQL';
    is [$false_col->params()], [], 'column FALSE params';
};

subtest 'like - case insensitive (ILIKE)' => sub {
    my $like = $qb->like(name => '%Hans%');
    is $like->as_sql(), 'name ILIKE ?', 'ILIKE SQL';
    is [$like->params()], ['%Hans%'], 'ILIKE params';
};

subtest 'like - with % at start' => sub {
    my $like_start = $qb->like(name => '%Hans');
    is $like_start->as_sql(), 'name ILIKE ?', 'ILIKE start SQL';
    is [$like_start->params()], ['%Hans'], 'ILIKE start params';
};

subtest 'like - with % at end' => sub {
    my $like_end = $qb->like(name => 'Hans%');
    is $like_end->as_sql(), 'name ILIKE ?', 'ILIKE end SQL';
    is [$like_end->params()], ['Hans%'], 'ILIKE end params';
};

subtest 'like - negated' => sub {
    my $not_like = $qb->like(name => '%Hans%', negated => 1);
    is $not_like->as_sql(), 'NOT ( name ILIKE ? )', 'negated ILIKE SQL';
    is [$not_like->params()], ['%Hans%'], 'negated ILIKE params';
};

subtest 'like - case sensitive (LIKE)' => sub {
    my $like_cs = $qb->like(name => '%Hans%', case_sensitive => 1);
    is $like_cs->as_sql(), 'name LIKE ?', 'case sensitive LIKE SQL';
    is [$like_cs->params()], ['%Hans%'], 'case sensitive LIKE params';
};

subtest 'complex nested query' => sub {
    my $complex = $qb->combine_and(
        $qb->combine_or(
            $qb->compare(name => 'Hansi'),
            $qb->like(name => '%Franz%')),
        $qb->compare(age => '18', comparator => '>='));
    is $complex->as_sql(), '( name = ? OR name ILIKE ? ) AND age >= ?', 'complex SQL';
    is [$complex->params()], ['Hansi', '%Franz%', '18'], 'complex params';
};

subtest 'ANY with different comparators' => sub {
    my $any_gt = $qb->compare(score => [80, 90, 100], comparator => '>');
    is $any_gt->as_sql(), 'score > ANY(?)', 'ANY > SQL';
    is [$any_gt->params()], [80, 90, 100], 'ANY > params';
};

subtest 'negated with != ALL' => sub {
    my $not_any = $qb->compare(status => ['deleted', 'banned', 'suspended'], negated => 1);
    is $not_any->as_sql(), 'status != ALL(?)', 'negated != ALL SQL';
    is [$not_any->params()], ['deleted', 'banned', 'suspended'], 'negated != ALL params';
};

subtest 'string overload' => sub {
    my $q = $qb->compare(friend => 'Carlotta');
    my $sql = "SELECT * FROM suspects WHERE $q";
    is $sql, 'SELECT * FROM suspects WHERE friend = ?', 'string overload SQL';
};

subtest clone => sub {
    my $q = $qb->compare(friend => 'Carlotta');
    my $clone = $q->clone();
    is $clone->as_sql(), 'friend = ?', 'clone SQL';
    is $clone->as_sql(), $q->as_sql(), 'clone SQL 2';
    is [$clone->params()], ['Carlotta'], 'clone params';
    $clone->value('Hansi');
    is $clone->as_sql(), 'friend = ?', 'clone SQL 3';
    is [$clone->params()], ['Hansi'], 'clone params 2';
    is $q->value(), 'Carlotta', 'orignal query kept param';
};

done_testing();
