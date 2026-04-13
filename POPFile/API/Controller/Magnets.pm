package POPFile::API::Controller::Magnets;

=head1 NAME

POPFile::API::Controller::Magnets - Email filtering rule (magnet) management endpoints

=head1 DESCRIPTION

Handles all C</api/v1/magnets> and C</api/v1/magnet-types> routes.
Magnets are email filtering rules that automatically classify messages based
on header patterns. Services are accessed via the Mojolicious helpers
registered in L<POPFile::API/build_app>: C<popfile_svc> and C<popfile_session>.

=cut

use Mojo::Base 'Mojolicious::Controller', -signatures;

sub list_magnet_types ($self) {
    my %types = $self->popfile_svc->get_magnet_types();
    $self->render(json => \%types);
}

sub list_magnets ($self) {
    my $svc = $self->popfile_svc;
    my %by_bucket;
    for my $b ($svc->get_buckets_with_magnets()) {
        for my $t ($svc->get_magnet_types_in_bucket($b)) {
            my @vals = $svc->get_magnets($b, $t);
            $by_bucket{$b}{$t} = \@vals if @vals;
        }
    }
    $self->render(json => \%by_bucket);
}

sub create_magnet ($self) {
    my $svc = $self->popfile_svc;
    my $body = $self->req->json // {};
    for my $k (qw(bucket type value)) {
        unless (defined $body->{$k} && $body->{$k} ne '') {
            return $self->render(status => 400,
                json => { error => "$k required" });
        }
    }
    $svc->create_magnet($body->{bucket}, $body->{type}, $body->{value});
    $self->render(json => { ok => \1 });
}

sub delete_magnet ($self) {
    my $svc = $self->popfile_svc;
    my $body = $self->req->json // {};
    $svc->delete_magnet(
        $body->{bucket} // '', $body->{type} // '', $body->{value} // '');
    $self->render(json => { ok => \1 });
}

__PACKAGE__
