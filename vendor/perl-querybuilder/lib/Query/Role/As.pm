use v5.40;
use Object::Pad;
role Query::Role::As;

field $as :param=undef;

method as(@value) {
    return $as
        unless @value;
    $as = $value[0];
    return $self
}

method as_as_sql($sql) {
    return $as ? "$sql AS $as" : $sql
}
