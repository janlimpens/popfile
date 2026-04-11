use v5.40;
use Object::Pad;

class Query::Expression::OrderBy :isa(Query::Expression);

field $column :param=undef;
field $direction :param='';
field $collation :param=undef;

field %directions = (
    '' => '',
    ASC => 'ASC',
    DESC => 'DESC');

method direction($dir) {
    $direction = $dir;
    return $self
}

method column($col) {
    $column = $col;
    return $self
}

method collate($c) {
    $collation = $c;
    return $self
}

method _build :override ()  {
    $self->reset();
    $self->add_part($column);
    my $dir = $directions{uc $direction} // die "direction $direction not recognized";
    $self->add_part($dir)
        if $dir;
    $self->add_part('COLLATE', $collation)
        if $collation;
    return
}

method clone :override () {
    return Query::Expression::OrderBy->new(
        column => $column,
        direction => $direction,
        collation => $collation )
}
