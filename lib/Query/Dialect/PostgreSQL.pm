package Query::Dialect::PostgreSQL;
use v5.40;
use Object::Pad;
use Query::Expression;

class Query::Dialect::PostgreSQL {
    use builtin qw(trim);

    method is_true($column = undef) {
        return Query::Expression->new(
            parts => 'TRUE',
            params => []) unless defined $column;

        return Query::Expression->new(
            parts => $column,
            params => []);
    }

    method is_false($column = undef) {
        return Query::Expression->new(
            parts => 'FALSE',
            params => []) unless defined $column;

        return $self->negate($self->is_true($column));
    }

    method like($column, $pattern, %args) {
        # PostgreSQL has ILIKE for case-insensitive
        my $operator = $args{case_sensitive} ? 'LIKE' : 'ILIKE';

        my $exp = Query::Expression->new(
            parts => [$column, $operator, '?'],
            params => $pattern);

        return $args{negated} ? $self->negate($exp) : $exp;
    }

    method negate(@expressions) {
        @expressions =
            map {
                Query::Expression->new(
                    parts => ['NOT (', $_, ')'],
                    params => $_->params())
            }
            @expressions;
        return $self->combine(OR => @expressions);
    }

    method combine($link, @expressions) {
        return $expressions[0]
            if @expressions < 2;
        $link = trim($link);

        # Wrap multi-part expressions in parentheses for clarity
        my @wrapped_expressions = map {
            if (ref $_ && $_->can('to_string') && $_->to_string() =~ / (AND|OR) /) {
                Query::Expression->new(
                    parts => ['(', $_, ')'],
                    params => $_->params())
            } else {
                $_
            }
        } @expressions;

        return Query::Expression->new(
            parts => \@wrapped_expressions,
            joined_by => " $link ");
    }

    method combine_and(@expressions) {
        return $self->combine(AND => @expressions);
    }

    method combine_or(@expressions) {
        return $self->combine(OR => @expressions);
    }

    method compare($column, $value, %args) {
        $value = [$value]
            unless ref $value eq 'ARRAY';
        my $comparator = $args{comparator} // '=';
        $comparator = trim($comparator);
        my $negated = $args{negated} // 0;

        # PostgreSQL: Use ANY/ALL for arrays instead of multiple comparisons
        if ($value->@* > 1) {
            # For multiple values, use PostgreSQL's ANY or ALL
            # = ANY is like IN
            # != ALL is like NOT IN
            # For negated: use ALL with negation
            # For non-negated: use ANY
            my $array_op = $negated ? 'ALL' : 'ANY';

            my $exp = Query::Expression->new(
                parts => [$column, $comparator, "$array_op(?)"],
                params => $value);

            return $negated ? $self->negate($exp) : $exp;
        }

        # Single value: use regular comparison
        my $exp = Query::Expression->new(
            parts => [$column, $comparator, '?'],
            params => $value->[0]);

        return $negated ? $self->negate($exp) : $exp;
    }
}

1;
