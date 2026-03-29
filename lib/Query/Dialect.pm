package Query::Dialect;
use v5.40;
use feature qw(class);
no warnings qw(experimental::class);

class Query::Dialect {
    use Query::Expression;
    use builtin qw(trim);

    method negate(@expressions) {
        @expressions =
            map {
                Query::Expression->new(
                    parts => ['NOT (', $_, ')'],
                    params => $_->params())
            }
            @expressions;
        return $self->combine(OR => @expressions)
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

    # These methods should be overridden by specific dialects
    method is_true() {
        die "is_true() must be implemented by dialect subclass";
    }

    method is_false() {
        die "is_false() must be implemented by dialect subclass";
    }

    method like($column, $pattern, %args) {
        die "like() must be implemented by dialect subclass";
    }
}

1;
