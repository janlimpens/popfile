package POPFile::API::Controller::Activity;
use Mojo::Base 'Mojolicious::Controller', -signatures;

=head1 NAME

POPFile::API::Controller::Activity — activity event API

=head1 DESCRIPTION

Serves recent activity events and an SSE stream of new events.

=cut

sub recent($self) {
    my $activity = $self->popfile_activity;
    return $self->render(status => 503, json => { error => 'Activity module not loaded' })
        unless defined $activity;
    my $since = $self->param('since') // 0;
    my $level = $self->param('level');
    my $events = $activity->recent_events($since, $level);
    $self->render(json => $events)
}

sub stream($self) {
    my $activity = $self->popfile_activity;
    return $self->render(status => 503, json => { error => 'Activity module not loaded' })
        unless defined $activity;
    $self->res()->headers()->content_type('text/event-stream');
    $self->res()->headers()->cache_control('no-cache');
    $self->res()->headers()->header('Connection' => 'keep-alive');
    $self->res()->headers()->header('X-Accel-Buffering' => 'no');
    $self->inactivity_timeout(0);
    $self->write(': connected');
    my $tx = $self->tx();
    $activity->add_sse_client($tx);
    $tx->on(finish => sub { $activity->remove_sse_client($tx) });
}

1;
