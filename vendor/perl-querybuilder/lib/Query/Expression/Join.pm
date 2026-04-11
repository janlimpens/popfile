use v5.40;
use Object::Pad;

class Query::Expression::Join
    :isa(Query::Expression);

field $table :param=undef;
field $as :param=undef;
field $type :param='';
field $on :param=undef;
field $using :param=undef;

field %types = (
    '' => '',
    INNER => '',
    LEFT => 'LEFT',
    'LEFT OUTER' => 'LEFT',
    RIGHT => 'RIGHT',
    'RIGHT OUTER' => 'RIGHT',
    FULL => 'FULL',
    CROSS => 'CROSS' );

method _build :override ()  {
    $self->reset();
    $type = $types{uc trim($type)} // die "type $type not recognized";
    die 'no table specified'
        unless $table;
    $self->add_part($type||(), 'JOIN', $table);
    $self->add_part(AS => $as)
        if $as;
    if ($on && $using) { die 'both on and using specified'; }
    elsif ($on) { $self->add_part(ON => $on); }
    elsif ($using) { $self->add_part(USING => '(', $using, ')'); }
    else { die 'no join condition specified'; }
    return
}

method type($value//='') {
    $type = $types{uc trim($value)} // die "type $value not recognized";
    return $self
}

method as($value) {
    $as = $value;
    return $self
}

method on($value) {
    $on = $value;
    return $self
}

method using($value) {
    $using = $value;
    return $self
}

method clone :override () {
    return Query::Expression::Join->new(
        table => $table,
        as => $as,
        type => $type,
        on => $on,
        using => $using )
}
