# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::API::Controller::Health;
use Mojo::Base 'Mojolicious::Controller', -signatures;

=head1 NAME

POPFile::API::Controller::Health - GET /api/v1/health

=head1 DESCRIPTION

Returns aggregated health status for all POPFile modules that have reported
their status via C<set_health()> (which posts C<HLTH_SET> to the MQ bus,
collected by C<POPFile::Loader>).

Response JSON:

    {
      "status":  "ok" | "warning" | "critical",
      "modules": {
        "<module-name>": { "status": "...", "message": "..." },
        ...
      }
    }

=cut

sub get_health ($self) {
    my $loader = $self->popfile_loader;
    unless (defined $loader) {
        return $self->render(json => { error => 'health data not available' }, status => 503);
    }
    my %modules = $loader->module_health();
    my $overall = 'ok';
    for my $info (values %modules) {
        if ($info->{status} eq 'critical') { $overall = 'critical'; last }
        $overall = 'warning' if $info->{status} eq 'warning';
    }
    $self->render(json => { status => $overall, modules => \%modules })
}

1;
