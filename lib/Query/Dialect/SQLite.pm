package Query::Dialect::SQLite;
use v5.40;
use Object::Pad;
use Query::Expression;
use Query::Expression::Select;

class Query::Dialect::SQLite;
inherit Query::Dialect;

method is_true($column = undef) {
    return Query::Expression->new(
        parts => '1',
        params => [])
        unless defined $column;
    return Query::Expression->new(
        parts => $column,
        params => [])
}

method is_false($column = undef) {
    return Query::Expression->new(
        parts => '0',
        params => [])
        unless defined $column;
    return $self->is_true($column)->negate()
}

method like($column, $pattern, %args) {
    # SQLite LIKE is case-insensitive for ASCII by default
    # For case-sensitive, we use GLOB operator
    my $operator = $args{case_sensitive} ? 'GLOB' : 'LIKE';
    my $exp = Query::Expression->new(
        parts => [$column, $operator, '?'],
        params => [$pattern]);
    return $args{negated} ? $exp->negate() : $exp
}

method select() {
    return Query::Expression::Select->new()
}

1;
