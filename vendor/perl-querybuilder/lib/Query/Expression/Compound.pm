use v5.40;
use Object::Pad;

class Query::Expression::Compound
    :isa(Query::Expression)
    :does(Query::Role::As);

my %junctors = (
    AND => 1,
    OR => 1 );
 # mysql has xor, postgres allows $a <> $b

field $junctor :reader :param||='AND';
field $expressions :reader :param||=[];

ADJUST {
    $junctor = trim(uc $junctor);
    die "Invalid junctor: $junctor"
        unless $junctors{$junctor};
    $self->joined_by(" $junctor ");
}

method add_expression(@expressions) {
    push $expressions->@*, @expressions;
    return $self
}

method clear_expressions() {
    $expressions = [];
    return $self
}

method should_wrap() {
    return $junctor eq 'OR' && $expressions->@* > 1
}

method _build() {
    $self->reset();
    my @expr = $expressions->@*;
    return
        unless @expr;
    if (@expr == 1) {
        $self->add_part($expr[0]);
        return
    }
    for (@expr) {
        $_->wrap()
            if $_ isa Query::Expression::Compound && $_->should_wrap();
        $self->add_part($_)
    }
    return
}

method clone :override () {
    return Query::Expression::Compound->new(
        junctor => $junctor,
        expressions => $expressions )
}
