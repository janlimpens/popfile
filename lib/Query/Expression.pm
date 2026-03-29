package Query::Expression;
use v5.40;
use Object::Pad;

class Query::Expression {
    use builtin qw(trim);
    
    field $parts :param;
    field $params :param = undef;
    field $joined_by :param = ' ';

    method to_string() {
        $parts = [$parts]
            unless ref $parts eq 'ARRAY';
        return join $joined_by, map { ref $_ ? $_->to_string() : trim($_) } $parts->@*
    }

    method params() {
        $parts = [$parts]
            unless ref $parts eq 'ARRAY';
        if (defined $params) {
            return ref $params eq 'ARRAY' ? $params : [$params]
        }
        my @p;
        for my $part ($parts->@*) {
            next unless ref $part && $part->can('params');
            my $sub = $part->params();
            push @p, ref $sub eq 'ARRAY' ? $sub->@* : $sub;
        }
        return \@p
    }
}

1;