# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::Config;

use Object::Pad;
use POPFile::Features;

class POPFile::Config;

my $instance;

field %store;

my $SCHEMA;

sub _load_schema() {
    return $SCHEMA
        if $SCHEMA;
    require Cpanel::JSON::XS;
    require File::Basename;
    my $dir = File::Basename::dirname($INC{'POPFile/Config.pm'});
    my $path = "$dir/config.schema.json";
    open my $fh, '<', $path or die "POPFile::Config: cannot read $path: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    $SCHEMA = Cpanel::JSON::XS->new()->utf8()->decode($content);
    return $SCHEMA
}

method schema_properties :common () {
    return _load_schema()->{properties}
}

method instance :common () {
    return $instance
        if $instance;
    $instance = POPFile::Config->new();
    my $path = POPFile::Config->resolve_path();
    $instance->load_file($path);
    return $instance
}

method resolve_path :common () {
    return $ENV{POPFILE_PATH}
        if $ENV{POPFILE_PATH};
    my $xdg = $ENV{XDG_CONFIG_HOME} // ($ENV{HOME} ? "$ENV{HOME}/.config" : undef);
    die "POPFile::Config: cannot resolve config path"
        unless $xdg;
    require File::Path;
    File::Path::make_path("$xdg/popfile")
        unless -d "$xdg/popfile";
    return "$xdg/popfile/config.json"
}

method load_file($path) {
    return
        unless -e $path;
    require POPFile::ConfigFile;
    my $data = POPFile::ConfigFile->new()->load($path);
    $self->_migrate_logger_level($data);
    $self->_strip_unknown($data, _load_schema()->{properties});
    $self->_coerce_types($data, _load_schema()->{properties});
    my $result = $self->_validate($data);
    die "POPFile::Config: invalid $path\n" . join("\n", $result->@*)
        unless $result->@* == 0;
    delete $data->{version};
    $self->_apply_defaults($data, _load_schema()->{properties});
    %store = $data->%*;
}

method _apply_defaults($node, $schema_node) {
    return
        unless ref $schema_node eq 'HASH';
    for my $key (keys $schema_node->%*) {
        my $prop = $schema_node->{$key};
        next
            unless ref $prop eq 'HASH';
        if (($prop->{type} // '') eq 'object' && $prop->{properties}) {
            $node->{$key} //= {};
            $self->_apply_defaults($node->{$key}, $prop->{properties});
        } elsif (exists $prop->{default}) {
            $node->{$key} //= $prop->{default};
        }
    }
}

my %_level_int_to_name = (0 => 'error', 1 => 'warn', 2 => 'info', 3 => 'debug', 4 => 'trace');

method _migrate_logger_level($data) {
    my $raw = $data->{logger}{level};
    return
        unless defined $raw && $raw =~ /^\d+$/;
    $data->{logger}{level} = $_level_int_to_name{$raw} // 'info';
}

method _coerce_types($node, $schema_node) {
    require JSON::PP;
    return
        unless ref $node eq 'HASH' && ref $schema_node eq 'HASH';
    for my $key (keys $node->%*) {
        my $prop_schema = $schema_node->{$key};
        next
            unless $prop_schema;
        my $val = $node->{$key};
        if (ref $val eq 'HASH' && ref $prop_schema->{properties} eq 'HASH') {
            $self->_coerce_types($val, $prop_schema->{properties});
        } elsif (!ref $val && defined $val) {
            my $type = $prop_schema->{type};
            next
                unless defined $type;
            if ($type eq 'boolean') {
                $node->{$key} = $val ? JSON::PP::true() : JSON::PP::false();
            } elsif ($type eq 'integer' && $val =~ /^-?\d+$/) {
                $node->{$key} = 0 + $val;
            }
        }
    }
}

method _validate($data) {
    require JSON::Schema::Modern;
    my $js = JSON::Schema::Modern->new();
    my $result = $js->evaluate($data, _load_schema());
    return []
        if $result->{valid};
    my @messages;
    for my $e ($result->{errors}->@*) {
        my $loc = $e->instance_location() || $e->keyword_location() || '/';
        push @messages, "$loc: $e->{error}";
    }
    return \@messages
}

method _strip_unknown($data, $schema_node) {
    return
        unless ref $data eq 'HASH' && ref $schema_node eq 'HASH';
    my %known_ns = map { $_ => 1 } grep { $_ ne 'version' } keys $schema_node->%*;
    delete $data->{$_}
        for grep { !$known_ns{$_} } keys $data->%*;
    for my $ns (keys %known_ns) {
        next
            unless ref $data->{$ns} eq 'HASH' && ref $schema_node->{$ns}{properties} eq 'HASH';
        my $ns_schema = $schema_node->{$ns}{properties};
        delete $data->{$ns}{$_}
            for grep { !exists $ns_schema->{$_} } keys $data->{$ns}->%*;
    }
}

=head2 validate_doc

    my @errors = POPFile::Config->validate_doc($data)->@*;

Class method for validating a config hash against the schema.
Used by the API controller before saving config changes.

=cut

method validate_doc :common ($data) {
    my $doc = +{version => 2, ($data // {})->%*};
    my $tmp = POPFile::Config->new();
    $tmp->_strip_unknown($doc, _load_schema()->{properties});
    $tmp->_coerce_types($doc, _load_schema()->{properties});
    my $result = $tmp->_validate($doc);
    die "POPFile::Config: invalid config\n" . join("\n", $result->@*)
        unless $result->@* == 0;
    return
}

method try_validate :common ($data) {
    my $doc = +{version => 2, ($data // {})->%*};
    my $tmp = POPFile::Config->new();
    $tmp->_strip_unknown($doc, _load_schema()->{properties});
    $tmp->_coerce_types($doc, _load_schema()->{properties});
    return $tmp->_validate($doc)
}

method get($ns, $key) {
    $store{$ns}{$key}
}

1;
