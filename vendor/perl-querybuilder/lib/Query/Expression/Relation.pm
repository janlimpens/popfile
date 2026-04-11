use v5.40;
use Object::Pad;

class Query::Expression::Relation
    :isa(Query::Expression)
    :does(Query::Role::As);

field $schema :param=undef;
field $name :param;
field $table :param=undef;
field $type :param=undef;

method _build :override ()  {
    $self->reset();
    # table.name::type
    my $string = join '.', grep { $_ } ($schema, $table, $name);
    $string .= "::$type"
      if $type;
    $self->add_part($string);
    return $self
}

method _post_sql :override ($sql) {
    return $self->as_as_sql($sql)
}

method clone :override () {
    return Query::Expression::Relation->new(
        schema => $schema,
        name => $name,
        table => $table,
        type => $type )
}
