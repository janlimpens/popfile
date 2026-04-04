# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::Log::Adapter;

use POPFile::Features;
use Log::Any::Adapter::Base;
use Log::Any::Adapter::Util qw(logging_methods);
use POSIX qw(strftime);

our @ISA = ('Log::Any::Adapter::Base');

my %cfg = (
    to_file => 1,
    to_stdout => 0,
    filename => '',
    popfile_level => 0,
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

sub configure { my (undef, %args) = @_; $cfg{$_} = $args{$_} for keys %args }

sub ring() { $cfg{ring} }

for my $method (logging_methods()) {
    my $min_level = $_required_popfile_level{$method} // 0;
    no strict 'refs';
    *{$method} = sub {
        my ($self, $msg) = @_;
        return unless $cfg{to_file} || $cfg{to_stdout};
        return if $min_level > $cfg{popfile_level};
        _write($msg);
    };
    *{"is_$method"} = sub { 1 };
}

sub _write($msg) {
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
