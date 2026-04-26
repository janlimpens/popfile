# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::Log::Adapter;

use POPFile::Features;
use Log::Any::Adapter::Base;
use Log::Any::Adapter::Util qw(logging_methods);
use POSIX qw(strftime);

our @ISA = ('Log::Any::Adapter::Base');

=head1 NAME

POPFile::Log::Adapter — Log::Any adapter that writes to file and/or stdout

=head1 DESCRIPTION

C<POPFile::Log::Adapter> is a L<Log::Any> adapter that formats and routes log
lines for POPFile.  It is installed by L<POPFile::Logger> via
C<< Log::Any::Adapter->set('+POPFile::Log::Adapter') >>.

Each log line is prefixed with a timestamp (C<YYYY/MM/DD HH:MM:SS>) followed
by the process ID and the message body.  The delimiter between fields is
configurable (space, tab, or comma).

Sensitive information is masked: C<USER>/C<PASS> command arguments are
replaced with C<XXXXXX>, and non-printable bytes are escaped as C<[XX]>.

A rolling ten-line ring buffer of recent output is maintained and exposed via
C<ring()> for the web UI.

The adapter maps Log::Any severity levels to POPFile's numeric level scale
(0 = error, 1 = info/notice/warning, 2 = debug/trace) and suppresses messages
below the configured C<popfile_level>.

=head1 METHODS

=head2 configure(%args)

Class method.  Updates the adapter's runtime configuration.  Accepted keys:

=over 4

=item C<to_file> — write to the log file (boolean)

=item C<to_stdout> — write to standard output (boolean)

=item C<filename> — path of the log file to append to

=item C<popfile_level> — minimum POPFile severity level to emit (0–2)

=item C<format> — timestamp delimiter: C<'default'> (space), C<'tabbed'>, or C<'csv'>

=back

=head2 ring()

Class method.  Returns the arrayref of the last ten log lines.

=cut

my %cfg = (
    to_file => 1,
    to_stdout => 0,
    filename => '',
    popfile_level => 0,
    log_sql => 0,
    format => 'default',
    ring => [],
);

my %_required_popfile_level = (
    trace => 2,
    debug => 2,
    info => 1,
    notice => 1,
    warning => 1,
    error => 0,
    critical => 0,
    alert => 0,
    emergency => 0,
);

sub configure($, %args) { $cfg{$_} = $args{$_} for keys %args }

sub ring() { $cfg{ring} }

for my $method (logging_methods()) {
    my $min_level = $_required_popfile_level{$method} // 0;
    no strict 'refs';
    *{$method} = sub($self, $msg) {
        return unless $cfg{to_file} || $cfg{to_stdout};
        return if $min_level > $cfg{popfile_level};
        _write($msg);
    };
    *{"is_$method"} = sub { 1 };
}

sub _write($msg) {
    return if $msg =~ /\[SQL\]/ && !$cfg{log_sql};
    $msg =~ s/((--)?)(USER|PASS)\s+\S*(\1)/"$`$1$3 XXXXXX$4"/ei;
    $msg =~ s/([\x00-\x1f])/sprintf("[%2.2x]", ord($1))/eg;
    my $delim = $cfg{format} eq 'tabbed' ? "\t"
              : $cfg{format} eq 'csv'    ? ','
              :                            ' ';
    my $ts = strftime("%Y/%m/%d${delim}%H:%M:%S", localtime);
    my $line = "$ts${delim}$$:${delim}$msg\n";
    if ($cfg{to_file} && $cfg{filename}) {
        if (open my $fh, '>>', $cfg{filename}) {
            print $fh $line;
            close $fh;
        }
    }
    print $line if $cfg{to_stdout};
    push $cfg{ring}->@*, $line;
    shift $cfg{ring}->@*
        if $cfg{ring}->@* > 10;
}

1;
