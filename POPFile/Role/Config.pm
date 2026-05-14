# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::Config;

use POPFile::Config;

=head1 NAME

POPFile::Role::Config — thin wrapper around the Config singleton

=head1 DESCRIPTION

Modules that consume this role get a C<config($module)> method that
returns a read-only namespace proxy.

    my $ns  = $self->config;           # own module
    my $val = $ns->get('database');

    my $db  = $self->config('bayes')->get('database');  # cross-module

=cut

method config($module = undef) {
    POPFile::Config->instance()->namespace(
        $module // $self->name())
}

1;
