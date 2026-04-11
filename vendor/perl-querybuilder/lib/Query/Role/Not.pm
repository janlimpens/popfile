use v5.40;
use Object::Pad;
role Query::Role::Not;

field $not :param=false;

method not($really=true) {
    $not = true
        if $really;
    return $self
}

method not_as_sql($sql) {
    return $not ? "NOT $sql" : $sql
}
