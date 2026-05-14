# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Features;
use POPFile::Config::Namespace;

my $_instance;

class POPFile::Config;

=head1 NAME

POPFile::Config — read-only configuration singleton

=head1 DESCRIPTION

Loaded once at startup from the POPFile C<Configuration> module, then
provides namespace-scoped read access for the lifetime of the process.
Changes to the backing store after loading are ignored.

    my $ns = POPFile::Config->instance()->namespace('bayes');
    my $val = $ns->get('database');

Cross-module access is explicit:

    my $db = $self->config('bayes')->get('database');

=cut

field $_store = {};

method instance :common () {
    $_instance //= __PACKAGE__->new();
    return $_instance
}

method load($configuration) {
    %$_store = $configuration->config_hash()->%*;
}

method namespace($name) {
    POPFile::Config::Namespace->new(
        store => $_store,
        prefix => $name . '_');
}

1;
