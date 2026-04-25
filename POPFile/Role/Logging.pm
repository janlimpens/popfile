# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use Log::Any ();

role POPFile::Role::Logging;

use constant {
    LOG_ERROR => 0,
    LOG_INFO => 1,
    LOG_DEBUG => 2,
};

sub import {
    my $class = shift;
    my @names = @_ ? @_ : qw(LOG_ERROR LOG_INFO LOG_DEBUG);
    my $caller = caller;
    no strict 'refs';
    *{"${caller}::${_}"} = \&{"${class}::${_}"} for @names;
}

=head1 NAME

POPFile::Role::Logging — structured logging via Log::Any

=head1 DESCRIPTION

Provides a single C<log_msg> method that maps POPFile's three-level numeric
severity scale to L<Log::Any> severity methods.  Any class that composes this
role gains consistent, category-tagged log output without depending directly
on a specific logging backend.

Exports three constants via C<< use POPFile::Role::Logging qw(LOG_ERROR LOG_INFO LOG_DEBUG) >>:

=over 4

=item LOG_ERROR (0) — error (C<< Log::Any->error >>)

=item LOG_INFO (1) — info  (C<< Log::Any->info >>)

=item LOG_DEBUG (2) — debug (C<< Log::Any->debug >>)

=back

=head1 METHODS

=head2 log_msg($level, $message)

Emits C<$message> at the severity determined by C<$level>.
The log category is set to the class name of the calling object
(C<ref($self)>).  The line number of the immediate caller is prepended to
the message text to aid tracing.

=cut

method log_msg ($level, $message) {
    my $log = Log::Any->get_logger(category => ref($self));
    my (undef, undef, $line) = caller;
    my $msg = ref($self) . ": $line: $message";
    if ($level == LOG_ERROR) {
        $log->error($msg)
    } elsif ($level == LOG_INFO) {
        $log->info($msg)
    } else {
        $log->debug($msg)
    }
}

1;
