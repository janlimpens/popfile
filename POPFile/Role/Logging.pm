# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use Log::Any ();

role POPFile::Role::Logging;

=head1 NAME

POPFile::Role::Logging — structured logging via Log::Any

=head1 DESCRIPTION

Provides a single C<log_msg> method that maps POPFile's three-level numeric
severity scale to L<Log::Any> severity methods.  Any class that composes this
role gains consistent, category-tagged log output without depending directly
on a specific logging backend.

=head1 METHODS

=head2 log_msg($level, $message)

Emits C<$message> at the severity determined by C<$level>:

=over 4

=item 0 — error (C<< Log::Any->error >>)

=item 1 — info  (C<< Log::Any->info >>)

=item 2 (or any other value) — debug (C<< Log::Any->debug >>)

=back

The log category is set to the class name of the calling object
(C<ref($self)>).  The line number of the immediate caller is prepended to
the message text to aid tracing.

=cut

method log_msg ($level, $message) {
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
