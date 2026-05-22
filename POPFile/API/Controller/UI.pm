# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::API::Controller::UI;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use Path::Tiny;

=head1 NAME

POPFile::API::Controller::UI — serve the Svelte SPA entry point

=head1 DESCRIPTION

Reads the built C<index.html> from the static directory and injects a
C<E<lt>base hrefE<gt>> tag when C<api.base_path> is configured, so the
app works behind a reverse proxy at a sub-path (e.g. C</popfile/>).

=cut

sub index ($self) {
    my $api = $self->popfile_api();
    my $base_path = $api->config()->get('base_path');
    my $static_dir = $api->config()->get('static_dir');
    my $html_file = $api->get_root_path($static_dir) . '/index.html';
    my $html = path($html_file)->slurp_utf8();
    if ($base_path) {
        $base_path =~ s{/+$}{};
        $html =~ s{<head>}{<head><base href="$base_path/">};
    }
    $self->render(text => $html, format => 'html');
    return
}

1;
