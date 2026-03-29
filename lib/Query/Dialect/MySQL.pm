package Query::Dialect::MySQL;
use v5.40;
use Object::Pad;
use Query::Expression;

class Query::Dialect::MySQL {
    use builtin qw(trim);

    method is_true($column = undef) {
        return Query::Expression->new(
            parts => '1',
            params => []) unless defined $column;

        return Query::Expression->new(
            parts => $column,
            params => []);
    }

    method is_false($column = undef) {
        return Query::Expression->new(
            parts => '0',
            params => []) unless defined $column;

        return $self->negate($self->is_true($column));
    }

    method like($column, $pattern, %args) {
        # MySQL LIKE is case-insensitive by default (with default collation)
        # For case-sensitive, we need to use BINARY
        my $operator = 'LIKE';

        my $column_expr = $args{case_sensitive}
            ? "BINARY $column"
            : $column;

        my $exp = Query::Expression->new(
            parts => [$column_expr, $operator, '?'],
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

        my @expressions =
            map {
                my $exp = Query::Expression->new(
                    parts => [$column, $comparator, '?'],
                    params => $_ );
                $negated ? $self->negate($exp) : $exp
            }
            $value->@*;
        return @expressions == 1
            ? $expressions[0]
            : $self->combine($negated ? 'AND' : 'OR' => @expressions);
    }
}

1;
