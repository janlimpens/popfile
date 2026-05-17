# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::Config;

use POPFile::Config;

=head1 NAME

POPFile::Role::Config — read-only config access for modules

=head1 DESCRIPTION

Modules that consume this role get a C<config()> method that returns a
read-only handle for the module's namespace.  An explicit C<$ns> argument
allows cross-module reads but emits a warning.

    my $port = $self->config->get('port') // $self->defaults->{port};

=cut

method config($ns = undef) {
    my $namespace = $ns // $self->name();
    warn "config: cross-module read '$namespace' from " . $self->name()
        if defined $ns && $ns ne $self->name() && $ns ne 'GLOBAL';
    require POPFile::Config::Handle;
    return POPFile::Config::Handle->new(
        namespace => $namespace,
    )
}

1;
