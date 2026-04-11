use v5.40;
use Object::Pad;

class Query::Expression::Comparison
    :isa(Query::Expression)
    :does(Query::Role::As)
    :does(Query::Role::Not);

field $column :param;
field $comparator :param||='=';
field $value :param=undef;
field $negated :param=false;
field %negations = (
    '=' => '<>',
    '!=' => '=',
    '=~' => '!~',
    'IS' => 'IS NOT',
    'IS NOT' => 'IS',
    '>' => '<',
    '>=' => '<',
    '<=' => '>',
    'IN' => 'NOT IN',
    'NOT IN' => 'IN',
    );

ADJUST {
    $comparator = trim(uc $comparator);
}

method negate($really=true) {
    return $comparator
        unless $really;
    if (my $negation = $negations{$comparator}) {
        $negated = !$negation;
        $comparator = $negation // $comparator;
    } else {
        $self->not();
        $self->wrap();
    }
    return $self
}

method _build :override ()  {
    $self->reset();
    $self->negate()
        if $negated;
    if (not defined $value) {
        $comparator = 'IS'
            if $comparator eq '=';
        $comparator = 'IS NOT'
            if $comparator eq '!=' || $comparator eq '<>';
        $self->add_part($column, $comparator, 'NULL');
        return $self;
    } elsif (ref $value eq 'SCALAR') {
        $self->add_part($column, $comparator, $value->$*);
        return $self;
    } elsif (ref $value eq 'ARRAY') {
        unless ($comparator =~ 'IN') {
            if ($comparator eq '!=' || $comparator eq '<>') {
                $comparator = 'NOT IN';
            } elsif($comparator eq '=') {
                $comparator = 'IN';
            }
        }
        my $placeholders = join(', ', map { ref $_ eq 'SCALAR' ? $_->$* : '?' } $value->@*);
        $self->add_part($column, $comparator, "($placeholders)");
        $self->add_param($_)
            for grep { ref $_ ne 'SCALAR' } $value->@*;
        return $self
    } elsif ($value isa Query::Expression) {
        $self->add_part($column, $comparator, $value);
        $value->wrap();
        return $self;
    }
    $self->wrap()
        if $negated;
    $self->add_part($column, $comparator, '?');
    $self->add_param($value);
    return $self
}

method _post_sql :override ($sql) {
    return $self->not_as_sql($self->as_as_sql($sql))
}

method clone :override () {
    return Query::Expression::Comparison->new(
        column => $column,
        comparator => $comparator,
        value => $value,
        negated => $negated )
}

method value(@value) {
    if (@value) {
        $value = $value[0];
        return $self;
    }
    return $value
}
