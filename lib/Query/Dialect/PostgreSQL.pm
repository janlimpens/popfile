package Query::Dialect::PostgreSQL;
use v5.40;
use Object::Pad;
use Query::Expression;
use Query::Expression::Select;

class Query::Dialect::PostgreSQL;
inherit Query::Dialect;

use builtin ':5.40';

method is_true($column = undef) {
    return Query::Expression->new(
        parts => 'TRUE',
        params => [])
        unless defined $column;
    return Query::Expression->new(
        parts => $column,
        params => [])
}

method is_false($column = undef) {
    return Query::Expression->new(
        parts => 'FALSE',
        params => [])
        unless defined $column;
    return $self->is_true($column)->negate()
}

method like($column, $pattern, %args) {
    my $operator = $args{case_sensitive} ? 'LIKE' : 'ILIKE';
    my $exp = Query::Expression->new(
        parts => [$column, $operator, '?'],
        params => [$pattern]);
    return $args{negated} ? $exp->negate() : $exp;
}

method compare($column, $value, %args) {
    return $self->SUPER::compare($column, $value, %args)
        unless ref $value eq 'ARRAY';
    my $comparator = $args{comparator} // '=';
    $comparator = trim($comparator);
    my $negated = $args{negated} // 0;

    if ($negated) {
        # For negated: use negated comparator with ALL
        # e.g., col != ALL(?) is equivalent to NOT IN
        my $neg_comparator = $self->negation_for($comparator) // "NOT $comparator";
        return Query::Expression->new(
            parts => [$column, $neg_comparator, "ALL(?)"],
            params => $value);
    } else {
        # For non-negated: use = ANY (equivalent to IN)
        return Query::Expression->new(
            parts => [$column, $comparator, "ANY(?)"],
            params => $value);
    }
}

method select() {
    return Query::Expression::Select->new()
}

1;
