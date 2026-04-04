package Query::Expression;
use v5.40;
use Object::Pad ':experimental(inherit_field)';
use overload '""' => \&as_sql;
class Query::Expression;

use builtin ':5.40';

field $parts :inheritable :param = [];
field $params :inheritable :param = [];
# this is what defines ane xpressin, it is a joined_by context
field $joined_by :param //= ' ';
field $brackets :inheritable :param = undef;

ADJUST {
    die 'parts are required'
        unless defined $parts;
    $parts = [ $parts ]
        unless ref $parts eq 'ARRAY';
    $params = [ $params ]
        unless ref $params eq 'ARRAY';
}

method as_sql {
    # no signature because "" overload comes with 3 args
    $self->_build();
    my $sql = join $joined_by,
        map { $_ isa Query::Expression ? $_->as_sql() : trim($_) }
        $parts->@*;
    if ($brackets) {
        my ($open, $close) = split //, $brackets;
        my ($o, $c) = map { quotemeta $_ } ($open, $close);
        $sql = "$open $sql $close"
            unless $sql =~ /^$o.+$c$/g;
    }
    return $self->_post_sql($sql)
}

method _post_sql($sql) { $sql }

method params() {
    $self->_build();
    my @params = $params && ref $params eq 'ARRAY' ? $params->@* : ();
    push @params, $params
        if $params && ref $params ne 'ARRAY';
    for my $part ($parts->@*) {
        next
            unless $part isa Query::Expression;
        push @params, $part->params();
    }
    return @params
}

method add_param($param) {
    push $params->@*, $param;
    return $self
}

method add_part(@parts) {
    push $parts->@*, grep { defined $_} @parts;
    return $self
}

method parts() {
    $self->_build();
    my @parts = $parts->@*;
    return @parts
}

method reset() {
    $parts = [];
    $params = [];
    return $self
}

# wrapable role?
method wrap($new_brackets//='()') {
    $brackets = $new_brackets;
    return $self
}

# too specific: move to a comparison expression
method negate($really=true) {
    return $self
        unless $really;
    return Query::Expression->new(
        parts => ['NOT', $self->wrap()],
        joined_by => ' ',
        params => [])
}

method _build {}

1;
