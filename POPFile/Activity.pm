# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use feature 'try';
no warnings 'experimental::try';

class POPFile::Activity :isa(POPFile::Module);

=head1 NAME

POPFile::Activity — in-memory event stream with SSE broadcast

=head1 DESCRIPTION

C<POPFile::Activity> maintains a configurable ring buffer of structured
activity events and broadcasts them in real time to connected web UI
clients via Server-Sent Events.

Each event has an C<id>, a C<parent_id> (or C<undef> for top-level events),
a timestamp, severity, source module, task label, and a human-readable
message.  The C<parent_id> must reference an existing event or be C<undef>,
enforcing a strict tree structure.

Events are flushed only on restart; the ring buffer exists purely in
memory — the real log files are the canonical record.

=head1 CONFIGURATION

=over

=item C<activity_buffer_size> — maximum number of events to retain (default 500)

=back

=head1 API ENDPOINTS

=over

=item C<GET /api/v1/activity> — recent events, optional C<since> and C<level> filters

=item C<GET /api/v1/activity/stream> — SSE stream of new events

=back

=cut

use Mojo::JSON qw(encode_json);

use constant DEFAULT_BUFFER_SIZE => 500;

field $events :reader = [];
field $max_size = DEFAULT_BUFFER_SIZE;
field $next_id = 0;
field @sse_clients;

BUILD {
    $self->set_name('activity');
}

method initialize() {
    $self->config(buffer_size => DEFAULT_BUFFER_SIZE);
    return 1
}

method start() {
    $max_size = $self->config('buffer_size') // DEFAULT_BUFFER_SIZE;
    $max_size = DEFAULT_BUFFER_SIZE
        if $max_size < 10;
    return 1
}

=head2 add_event($event)

Pushes a new event into the ring buffer and broadcasts it to all connected
SSE clients.  C<$event> must be a hashref with keys C<level>, C<module>,
C<task>, C<message>, and optionally C<parent_id>.  Missing C<parent_id>
defaults to C<undef>.

C<parent_id> is validated: it must be C<undef> or the C<id> of an existing
event in the buffer.

Returns the created event hashref (with C<id> and C<ts> filled in), or
C<undef> on validation failure.

=cut

method add_event($event) {
    my $parent_id = $event->{parent_id};
    if (defined $parent_id) {
        return
            unless $self->_event_exists($parent_id);
    }
    $event->{id} = ++$next_id;
    $event->{ts} = time();
    push $events->@*, $event;
    shift $events->@*
        while $events->@* > $max_size;
    $self->_broadcast_sse($event);
    return $event
}

method _event_exists($id) {
    return 0 unless defined $id;
    ($id) = grep { $_->{id} == $id } $events->@*;
    return defined $id ? 1 : 0
}

=head2 recent_events($since_id, $level_filter)

Returns an arrayref of events with C<id E<gt> $since_id>, optionally
filtered by C<$level_filter> (C<'info'>, C<'warn'>, C<'error'>).  When
C<$level_filter> is C<undef> or empty, all levels are returned.

=cut

method recent_events($since_id = 0, $level_filter = undef) {
    my @filtered = $level_filter
        ? grep { ($_->{level} // '') eq $level_filter } $events->@*
        : $events->@*;
    my @recent = grep { $_->{id} > $since_id } @filtered;
    return \@recent
}

=head2 add_sse_client($tx)

Registers a Mojo transaction for SSE broadcast.  The initial comment
is written by the controller via C<$c->write()> to start the chunked
response.

=cut

method add_sse_client($tx) {
    push @sse_clients, $tx;
}

=head2 remove_sse_client($tx)

Removes a previously registered SSE client.

=cut

method remove_sse_client($tx) {
    @sse_clients = grep { $_ != $tx } @sse_clients;
}

method _broadcast_sse($event) {
    return unless @sse_clients;
    my $payload = {
        type => 'activity',
        text => encode_json({
            id => $event->{id},
            parent_id => $event->{parent_id},
            ts => $event->{ts},
            level => $event->{level},
            module => $event->{module},
            task => $event->{task},
            message => $event->{message} }),
        id => $event->{id} };
    for my $tx (@sse_clients) {
        try {
            $tx->res()->content()->write_sse($payload);
            $tx->resume();
        } catch($e) {
            $self->log_msg(WARN => "SSE broadcast: $e");
        };
    }
    @sse_clients = grep { !$_->is_finished() } @sse_clients;
}

1;
