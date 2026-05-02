package Query::Builder;
use v5.40;
use Object::Pad;
use Query::Dialect::PostgreSQL;
use Query::Dialect::MySQL;
use Query::Dialect::SQLite;

class Query::Builder {
    field $dialect :param;
    field $dialect_impl;

    ADJUST {
        die 'dialect required'
            unless $dialect;
        $dialect_impl = $self->_create_dialect($dialect);
    }

    method _create_dialect($name) {
        $name = lc($name);
        return Query::Dialect::PostgreSQL->new()
            if $name eq 'pg' || $name eq 'postgresql';
        return Query::Dialect::MySQL->new()
            if $name eq 'mysql';
        return Query::Dialect::SQLite->new()
            if $name eq 'sqlite';
        die "Unknown dialect: $name. Supported: pg, mysql, sqlite"
    }

    # Delegate to dialect implementation
    method compare($column, $value, %args) {
        return $dialect_impl->compare($column, $value, %args)
    }

    method like($column, $pattern, %args) {
        return $dialect_impl->like($column, $pattern, %args)
    }

    method combine_and(@expressions) {
        return $dialect_impl->combine_and(@expressions)
    }

    method combine_or(@expressions) {
        return $dialect_impl->combine_or(@expressions)
    }

    method is_true($column = undef) {
        return $dialect_impl->is_true($column)
    }

    method is_false($column = undef) {
        return $dialect_impl->is_false($column)
    }

    method negate(@expressions) {
        return $dialect_impl->negate(@expressions)
    }

    method combine($link, @expressions) {
        return $dialect_impl->combine($link, @expressions)
    }

    method into($table, $columns, $values_or_expression) {
        return $dialect_impl->into($table, $columns, $values_or_expression)
    }

    method set(%columns_and_values) {
        return $dialect_impl->set(%columns_and_values)
    }

    method select(@columns) {
        return $dialect_impl->select()->columns(@columns)
    }

    method with(@expressions) {
        return $dialect_impl->with(@expressions)
    }

    method join($table, %args) {
        return $dialect_impl->join($table, %args)
    }

    method order_by($column, $direction=undef) {
        return $dialect_impl->order_by($column, $direction)
    }

    method relation($name) {
            return $dialect_impl->relation($name)
    }

    method exists($subquery) {
        return $dialect_impl->exists($subquery)
    }

}

1;
