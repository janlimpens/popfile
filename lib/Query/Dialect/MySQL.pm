package Query::Dialect::MySQL;
use v5.40;
use Object::Pad;
use Query::Expression;
use Query::Expression::Select;

class Query::Dialect::MySQL;
inherit Query::Dialect;
use builtin ':5.40';

method is_true($column=undef) {
    return Query::Expression->new(
        parts => '1',
        params => [])
        unless defined $column;
    return Query::Expression->new(
        parts => $column,
        params => []);
}

method is_false($column=undef) {
    return Query::Expression->new(
        parts => '0',
        params => [])
        unless defined $column;
    return $self->is_true($column)->negate()
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
        params => [$pattern]);
    return $args{negated}
        ? $exp->negate()
        : $exp
}

method select() {
    return Query::Expression::Select->new()
}

1;
