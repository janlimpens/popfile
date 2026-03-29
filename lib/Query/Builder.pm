package Query::Builder;
use v5.40;
use Object::Pad;
use Query::Dialect::PostgreSQL;
use Query::Dialect::MySQL;
use Query::Dialect::SQLite;

class Query::Builder {
    field $dialect :param = 'pg';
    field $dialect_impl;

    ADJUST {
        $dialect_impl = $self->_create_dialect($dialect);
    }

    method _create_dialect($name) {
        return Query::Dialect::PostgreSQL->new() if $name eq 'pg' || $name eq 'postgresql';
        return Query::Dialect::MySQL->new() if $name eq 'mysql';
        return Query::Dialect::SQLite->new() if $name eq 'sqlite';
        die "Unknown dialect: $name. Supported: pg, mysql, sqlite";
    }

    # Delegate to dialect implementation
    method compare($column, $value, %args) {
        return $dialect_impl->compare($column, $value, %args);
    }

    method like($column, $pattern, %args) {
        return $dialect_impl->like($column, $pattern, %args);
    }

    method combine_and(@expressions) {
        return $dialect_impl->combine_and(@expressions);
    }

    method combine_or(@expressions) {
        return $dialect_impl->combine_or(@expressions);
    }

    method is_true($column = undef) {
        return $dialect_impl->is_true($column);
    }

    method is_false($column = undef) {
        return $dialect_impl->is_false($column);
    }

    method negate(@expressions) {
        return $dialect_impl->negate(@expressions);
    }

    method combine($link, @expressions) {
        return $dialect_impl->combine($link, @expressions);
    }
}

1;
