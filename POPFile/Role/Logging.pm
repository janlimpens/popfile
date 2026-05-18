# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use Log::Any ();

role POPFile::Role::Logging;

my %_dispatch = (
    error => 'error',
    warn  => 'warning',
    info  => 'info',
    debug => 'debug',
    trace => 'trace',
);

=head1 NAME

POPFile::Role::Logging — structured logging via Log::Any

=head1 DESCRIPTION

Provides a single C<log_msg> method that maps severity names directly to
L<Log::Any> methods.  Any class that composes this role gains consistent,
category-tagged log output without depending directly on a specific logging
backend.

    $self->log_msg(ERROR => "something went wrong");
    $self->log_msg(WARN  => "unusual condition");
    $self->log_msg(INFO  => "started up");
    $self->log_msg(DEBUG => "value is $x");
    $self->log_msg(TRACE => "raw bytes: $buf");

Level names are case-insensitive.  Unrecognised values (including bare
numbers) fall back to INFO.

=head1 METHODS

=head2 log_msg($level, $message)

Emits C<$message> at the resolved severity.  The log category is the class
name of the calling object (C<ref($self)>).  The caller's line number is
prepended to the message to aid tracing.

=cut

method log_msg ($level, $message) {
    my $method = $_dispatch{lc $level} // 'info';
    my $log = Log::Any->get_logger(category => ref($self));
    my (undef, undef, $line) = caller;
    $log->$method(ref($self) . ": $line: $message");
}

1;
