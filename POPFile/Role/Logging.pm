# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use Log::Any ();

role POPFile::Role::Logging;

my %_level = (
    WARN => 0, ERROR => 0,
    INFO => 1,
    DEBUG => 2,
);

=head1 NAME

POPFile::Role::Logging — structured logging via Log::Any

=head1 DESCRIPTION

Provides a single C<log_msg> method that maps POPFile's severity levels to
L<Log::Any> severity methods.  Any class that composes this role gains
consistent, category-tagged log output without depending directly on a
specific logging backend.

The first argument is a severity indicator — either a numeric level or a
word.  Use the fat-comma form for readability:

    $self->log_msg(WARN  => "something went wrong");
    $self->log_msg(INFO  => "started up");
    $self->log_msg(DEBUG => "value is $x");

Numeric levels are also accepted for backwards compatibility:

=over 4

=item 0 / WARN / ERROR — C<< Log::Any->error >>

=item 1 / INFO — C<< Log::Any->info >>

=item 2 / DEBUG — C<< Log::Any->debug >>

=back

=head1 METHODS

=head2 log_msg($level, $message)

Emits C<$message> at the resolved severity.  The log category is the class
name of the calling object (C<ref($self)>).  The caller's line number is
prepended to the message to aid tracing.

=cut

method log_msg ($level, $message) {
    $level = $_level{$level} // 0
        unless $level =~ /^\d+$/;
    my $log = Log::Any->get_logger(category => ref($self));
    my (undef, undef, $line) = caller;
    my $msg = ref($self) . ": $line: $message";
    if ($level == 0) {
        $log->error($msg)
    } elsif ($level == 1) {
        $log->info($msg)
    } else {
        $log->debug($msg)
    }
}

1;
