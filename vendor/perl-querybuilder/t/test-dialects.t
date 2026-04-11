use v5.40;
use Test2::V0;
use lib 'lib';
use Query::Builder;

# Test PostgreSQL Dialect
subtest 'PostgreSQL Dialect' => sub {
    my $qb = Query::Builder->new(dialect => 'pg');

    # Test compare
    my $equals = $qb->compare(name => 'Hansi');
    is $equals->as_sql(), 'name = ?';
    is [$equals->params()], ['Hansi'];

    # Test multi-value compare (PostgreSQL uses ANY)
    my $multi = $qb->compare(name => [qw(Hansi Franz)]);
    is $multi->as_sql(), 'name = ANY(?)';
    is [$multi->params()], [qw(Hansi Franz)];

    # Test negated compare (single value)
    my $negated = $qb->compare(name => 'Hansi', negated => 1);
    is $negated->as_sql(), 'name <> ?';
    is [$negated->params()], ['Hansi'];

    # Test negated compare (multiple values - uses != ALL)
    my $negated_multi = $qb->compare(name => [qw(Hansi Franz)], negated => 1);
    is $negated_multi->as_sql(), 'name != ALL(?)';
    is [$negated_multi->params()], [qw(Hansi Franz)];

    # Test combine_and
    my $and_expr = $qb->combine_and(
        $qb->compare(name => 'Hansi'),
        $qb->compare(age => '30', comparator => '>'));
    is $and_expr->as_sql(), 'name = ? AND age > ?';
    is [$and_expr->params()], ['Hansi', '30'];

    # Test combine_or
    my $or_expr = $qb->combine_or(
        $qb->compare(name => 'Hansi'),
        $qb->compare(name => 'Franz'));
    is $or_expr->as_sql(), 'name = ? OR name = ?';
    is [$or_expr->params()], ['Hansi', 'Franz'];

    # Test is_true - PostgreSQL uses TRUE (no column)
    my $true_expr = $qb->is_true();
    is $true_expr->as_sql(), 'TRUE';
    is [$true_expr->params()], [];

    # Test is_false - PostgreSQL uses FALSE (no column)
    my $false_expr = $qb->is_false();
    is $false_expr->as_sql(), 'FALSE';
    is [$false_expr->params()], [];

    # Test is_true with column
    my $true_col = $qb->is_true('is_active');
    is $true_col->as_sql(), 'is_active';
    is [$true_col->params()], [];

    # Test is_false with column (negates)
    my $false_col = $qb->is_false('is_active');
    is $false_col->as_sql(), 'NOT ( is_active )';
    is [$false_col->params()], [];

    # Test ILIKE (case-insensitive, default)
    my $like = $qb->like(name => '%Hans%');
    is $like->as_sql(), 'name ILIKE ?';
    is [$like->params()], ['%Hans%'];

    # Test LIKE (case-sensitive)
    my $like_cs = $qb->like(name => '%Hans%', case_sensitive => 1);
    is $like_cs->as_sql(), 'name LIKE ?';
    is [$like_cs->params()], ['%Hans%'];

    # Test negated LIKE
    my $not_like = $qb->like(name => '%Hans%', negated => 1);
    is $not_like->as_sql(), 'NOT ( name ILIKE ? )';
    is [$not_like->params()], ['%Hans%'];

    # Test complex combination
    my $complex = $qb->combine_and(
        $qb->combine_or(
            $qb->compare(name => 'Hansi'),
            $qb->like(name => '%Franz%')),
        $qb->compare(age => '18', comparator => '>='));
    is $complex->as_sql(), '( name = ? OR name ILIKE ? ) AND age >= ?';
    is [$complex->params()], ['Hansi', '%Franz%', '18'];

    # Test PostgreSQL-specific ANY/ALL
    my $any_compare = $qb->compare(status => ['active', 'pending', 'verified']);
    is $any_compare->as_sql(), 'status = ANY(?)';
    is [$any_compare->params()], ['active', 'pending', 'verified'];

    my $all_negated = $qb->compare(status => ['deleted', 'banned'], negated => 1);
    is $all_negated->as_sql(), 'status != ALL(?)';
    is [$all_negated->params()], ['deleted', 'banned'];
};

# Test MySQL Dialect
subtest 'MySQL Dialect' => sub {
    my $qb = Query::Builder->new(dialect => 'mysql');

    # Test compare
    my $equals = $qb->compare(name => 'Hansi');
    is $equals->as_sql(), 'name = ?';
    is [$equals->params()], ['Hansi'];

    # Test is_true - MySQL uses 1 (no column)
    my $true_expr = $qb->is_true();
    is $true_expr->as_sql(), '1';
    is [$true_expr->params()], [];

    # Test is_false - MySQL uses 0 (no column)
    my $false_expr = $qb->is_false();
    is $false_expr->as_sql(), '0';
    is [$false_expr->params()], [];

    # Test is_true with column
    my $true_col = $qb->is_true('is_active');
    is $true_col->as_sql(), 'is_active';
    is [$true_col->params()], [];

    # Test is_false with column (negates)
    my $false_col = $qb->is_false('is_active');
    is $false_col->as_sql(), 'NOT ( is_active )';
    is [$false_col->params()], [];

    # Test LIKE (case-insensitive by default in MySQL)
    my $like = $qb->like(name => '%Hans%');
    is $like->as_sql(), 'name LIKE ?';
    is [$like->params()], ['%Hans%'];

    # Test BINARY LIKE (case-sensitive)
    my $like_cs = $qb->like(name => '%Hans%', case_sensitive => 1);
    is $like_cs->as_sql(), 'BINARY name LIKE ?';
    is [$like_cs->params()], ['%Hans%'];

    # Test negated LIKE
    my $not_like = $qb->like(name => '%Hans%', negated => 1);
    is $not_like->as_sql(), 'NOT ( name LIKE ? )';
    is [$not_like->params()], ['%Hans%'];

    # Test complex combination
    my $complex = $qb->combine_and(
        $qb->combine_or(
            $qb->compare(name => 'Hansi'),
            $qb->like(name => '%Franz%')),
        $qb->compare(age => '18', comparator => '>='));
    is $complex->as_sql(), '( name = ? OR name LIKE ? ) AND age >= ?';
    is [$complex->params()], ['Hansi', '%Franz%', '18'];
};

# Test SQLite Dialect
subtest 'SQLite Dialect' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');

    # Test compare
    my $equals = $qb->compare(name => 'Hansi');
    is $equals->as_sql(), 'name = ?';
    is [$equals->params()], ['Hansi'];

    # Test is_true - SQLite uses 1 (no column)
    my $true_expr = $qb->is_true();
    is $true_expr->as_sql(), '1';
    is [$true_expr->params()], [];

    # Test is_false - SQLite uses 0 (no column)
    my $false_expr = $qb->is_false();
    is $false_expr->as_sql(), '0';
    is [$false_expr->params()], [];

    # Test is_true with column
    my $true_col = $qb->is_true('is_active');
    is $true_col->as_sql(), 'is_active';
    is [$true_col->params()], [];

    # Test is_false with column (negates)
    my $false_col = $qb->is_false('is_active');
    is $false_col->as_sql(), 'NOT ( is_active )';
    is [$false_col->params()], [];

    # Test LIKE (case-insensitive for ASCII by default)
    my $like = $qb->like(name => '%Hans%');
    is $like->as_sql(), 'name LIKE ?';
    is [$like->params()], ['%Hans%'];

    # Test GLOB (case-sensitive)
    my $like_cs = $qb->like(name => '*Hans*', case_sensitive => 1);
    is $like_cs->as_sql(), 'name GLOB ?';
    is [$like_cs->params()], ['*Hans*'];

    # Test negated LIKE
    my $not_like = $qb->like(name => '%Hans%', negated => 1);
    is $not_like->as_sql(), 'NOT ( name LIKE ? )';
    is [$not_like->params()], ['%Hans%'];

    # Test complex combination
    my $complex = $qb->combine_and(
        $qb->combine_or(
            $qb->compare(name => 'Hansi'),
            $qb->like(name => '%Franz%')),
        $qb->compare(age => '18', comparator => '>='));
    is $complex->as_sql(), '( name = ? OR name LIKE ? ) AND age >= ?';
    is [$complex->params()], ['Hansi', '%Franz%', '18'];
};

subtest into => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $into = $qb->into('films', [qw(title type created)], [['timbuktu', 'movie', \'NOW()']]);
    is $into, 'INTO films (title, type, created) VALUES ( ?, ?, NOW() )', 'into generated';
    is [$into->params()], [qw(timbuktu movie)], 'values in correct order';
};

subtest into_select => sub {
    # INSERT INTO archive_invoices (id, customer_id, amount)
    # SELECT id, customer_id, amount
    # FROM invoices
    # WHERE created_at < '2024-01-01'
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $query = Query::Expression->new( parts => [
        INSERT =>
        $qb->into(
            archive_invoices =>
            [qw(id customer_id amount)],
            Query::Expression->new( parts => [
                'SELECT id, customer_id, amount FROM invoices WHERE',
                $qb->compare(created_at => '2024-01-01', comparator => '<') ])
        )]);
    is $query, 'INSERT INTO archive_invoices (id, customer_id, amount) SELECT id, customer_id, amount FROM invoices WHERE created_at < ?', 'select generated';
    is [$query->params()], ['2024-01-01'], 'value ok';
};

subtest set => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $set = $qb->set(
        type => 'movie',
        title => 'timbuktu',
        updated => \'NOW()' );
    is $set, 'SET title = ?, type = ?, updated = NOW()', 'set generated';
    is [$set->params()], [qw(timbuktu movie)], 'values in correct order';
};

done_testing();
