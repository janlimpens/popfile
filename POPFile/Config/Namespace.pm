# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Features;

class POPFile::Config::Namespace;

=head1 NAME

POPFile::Config::Namespace — read-only view of one module's config keys

=head1 DESCRIPTION

Returned by C<< POPFile::Config->namespace($name) >>.  Provides a single
method C<get($key)> that returns C<undef> when the key has no value.

=cut

field $_store :param;
field $_prefix :param;

method get($key) {
    $_store->{$_prefix . $key}
}

1;
