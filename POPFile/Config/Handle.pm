# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

class POPFile::Config::Handle;

=head1 NAME

POPFile::Config::Handle — read-only config handle for one namespace

=head1 DESCRIPTION

Returned by C<Role::Config>.  Provides C<get($key)> against the Config
singleton.  Fallback to module defaults is handled by the consumer.

=cut

field $namespace :param;

method get($key) {
    POPFile::Config->instance()->get($namespace, $key)
}

1;
