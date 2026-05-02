use v5.40;
use Object::Pad;

class Query::Expression::Exists
    :isa(Query::Expression);

field $subquery :param;

ADJUST {
    die 'subquery (expression) required'
        unless defined $subquery;
    die 'subquery must be a Query::Expression'
        unless $subquery isa Query::Expression;
};

method _build :override ()  {
    $self->reset();
    $self->add_part('EXISTS', $subquery->wrap());
    return
}

method subquery() { $subquery }

method clone :override () {
    return Query::Expression::Exists->new(
        subquery => $subquery->clone())
}
