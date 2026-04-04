package Query::Dialect;
use v5.40;
use Object::Pad;

class Query::Dialect :abstract;

use builtin ':5.40';
use Query::Expression;
use Query::Expression::Join;
use Query::Expression::OrderBy;
use Query::Expression::Relation;

method negation_for($comparator) {
    state %negations = do {
        my %cmps = (
            '=' => '!=',
            '>' => '<',
            '>=' => '<=');
        %cmps = ( %cmps, reverse %cmps );
        %cmps
    };
    return $negations{$comparator}
}

method negate(@expressions) {
    return
        unless @expressions;
    return $self->combine(OR => map { $_->negate() } @expressions)
}

method combine($link, @expressions) {
    return ()
        unless @expressions;
    return $expressions[0]
        if @expressions == 1;
    $link = trim($link);
    # Wrap expressions that contain AND/OR operators
    my @parts = map {
        ($_ isa Query::Expression && $_->as_sql() =~ / (AND|OR) /)
            ? $_->wrap()
            : $_
    } @expressions;
    return Query::Expression->new(
        joined_by => " $link ",
        parts => \@parts,
        params => [])
}

method combine_and(@expressions) {
    return $self->combine(AND => @expressions)
}

method combine_or(@expressions) {
    return $self->combine(OR => @expressions)
}

method compare($column, $value, %args) {
    my $comparator = $args{comparator} // '=';
    my $is_literal;
    if (not defined $value) {
        $value = 'NULL';
        $comparator = 'IS';
    } elsif (ref $value eq 'SCALAR') {
        $is_literal = true;
        $value = $value->$*;
    }
    $comparator = trim($comparator);
    my $negated = !!$args{negated};
    return Query::Expression->new(
        parts => [$column, $comparator, $is_literal ? $value : '?'],
        params => $value)->negate($negated)
        unless ref $value eq 'ARRAY';
    if ($comparator eq '=') {
        my $placeholders = join(', ', ('?') x $value->@*);
        my $operator = $negated ? 'NOT IN' : 'IN';
        return Query::Expression->new(
            parts => [$column, $operator, "($placeholders)"],
            params => [$value->@*]);
    }
}

method is_true($column);
method is_false($column);
method like($column, $pattern, %args);

method is_array_of_arrays($something) {
    return 0 unless ref $something eq 'ARRAY';
    return 0 unless $something->@*;
    return 0 unless ref $something->[0] eq 'ARRAY';
    return 1;
}

method into($table, $columns, $values_or_expression) {
    my $exp;
    if ($values_or_expression isa Query::Expression) {
        $exp = $values_or_expression;
    } elsif(ref $values_or_expression eq 'ARRAY') {
        my $value_lists = $values_or_expression;
        $value_lists = [$value_lists]
            unless $self->is_array_of_arrays($value_lists);
        my @exp;
        for my $value_list ($value_lists->@*) {
            my @parts;
            my @params;
            for my $v ($value_list->@*) {
                # ( 'x', \'NOW()', 'foo') => '(?, NOW(), ?)'
                my $is_ref = ref $v eq 'SCALAR';
                my $part = $is_ref ? $$v : '?';
                push @parts, $part;
                push @params, $v
                    unless $is_ref;
            }
            push @exp, Query::Expression->new(
                parts => \@parts,
                params => \@params,
                joined_by => ', ' )->wrap();
        }
        $exp = Query::Expression->new(
            parts => [ VALUES => Query::Expression->new(parts => \@exp) ]);
    } else {
        die 'into requires either an array (of arrays) of` values or an expression'
    }
    my $stm = sprintf "INTO %s (%s)",
        $table,
        join(', ', $columns->@*);
    return Query::Expression->new(parts => [$stm, $exp]);
}

method with(@selects) {
    for (@selects) {
        die 'expression must have an AS'
            unless $_->as()
    }
    return Query::Expression->new(
        parts => [ WITH =>
            Query::Expression->new(
                parts => [ @selects ],
                joined_by => ', ' ) ])
}

method set(%columns_and_values) {
    my @columns = sort keys %columns_and_values;
    my @values =
        map { $columns_and_values{$_} }
        grep { ! ref $columns_and_values{$_} }
        @columns;
    my $stm = sprintf "SET %s",
        join ', ',
            map {
                my $v = $columns_and_values{$_};
                ref $v ? "$_ = $$v" : "$_ = ?" }
            @columns;
    return Query::Expression->new(
        parts => [$stm],
        params => \@values)
}

method join($table, %args) {
    return Query::Expression::Join->new(
        table => $table,
        %args)
}

method order_by($column, $direction=undef) {
    die 'order_by requires a column'
        unless $column;
    my $ob = Query::Expression::OrderBy->new(
        column => $column);
    $ob->direction(uc $direction)
        if defined $direction;
    return $ob
}

method relation($name) {
    die 'relation requires a name'
        unless $name;
    return Query::Expression::Relation->new(
        name => $name)
}

method select();

1;
