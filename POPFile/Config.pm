# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::Config;

use Object::Pad;
use builtin qw(true false);
use Scalar::Util qw(looks_like_number);
use POPFile::Features;

class POPFile::Config;

my $instance;

field %store;

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
    delete $data->{version};
    %store = $data->%*;
    $self->_normalize_tree(\%store);
}

method _normalize_tree($node) {
    return
        unless ref $node eq 'HASH';
    for my $key (keys $node->%*) {
        my $val = $node->{$key};
        if (ref $val eq 'HASH') {
            $self->_normalize_tree($val)
        } else {
            $node->{$key} = $self->_normalize_value($val)
        }
    }
}

method _normalize_value($value) {
    return $value
        unless defined $value && !ref $value;
    return 0 + $value
        if looks_like_number($value);
    return false
        if $value eq 'false';
    return true
        if $value eq 'true';
    return $value
}

method get($ns, $key) {
    $store{$ns}{$key}
}

1;
