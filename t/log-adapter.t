#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use File::Temp qw(tempfile);
use Test2::V0;

require POPFile::Log::Adapter;
require Log::Any::Adapter;
require Log::Any;

sub capture_stdout(&) {
    my ($code) = @_;
    my ($fh, $path) = tempfile(UNLINK => 1);
    open my $saved, '>&', \*STDOUT or die;
    open STDOUT, '>&', $fh or die;
    STDOUT->autoflush(1);
    $code->();
    open STDOUT, '>&', $saved or die;
    seek $fh, 0, 0;
    my @lines = <$fh>;
    close $fh;
    return @lines
}

sub capture_file(&) {
    my ($code) = @_;
    my ($fh, $path) = tempfile(UNLINK => 1);
    close $fh;
    $code->($path);
    open my $rfh, '<', $path or die;
    my @lines = <$rfh>;
    close $rfh;
    return @lines
}

sub fresh_adapter {
    my %args = @_;
    Log::Any::Adapter->set('+POPFile::Log::Adapter');
    POPFile::Log::Adapter->configure(
        to_file => 0,
        to_stdout => 0,
        log_sql => 0,
        popfile_level => 2,
        format => 'plain',
        filename => '',
        ring => [],
        %args,
    );
    return Log::Any->get_logger()
}

subtest 'log_sql=0: SQL filtered out regardless of destination' => sub {
    my $log = fresh_adapter(to_stdout => 1);
    my @lines = capture_stdout { $log->info('hello'); $log->info('[SQL] SELECT 1') };
    is scalar @lines, 1, 'SQL dropped';
    unlike $lines[0], qr/\[SQL\]/, 'only normal message present'
};

subtest 'log_sql=1 to_stdout=0: no stdout output (routing unchanged)' => sub {
    my $log = fresh_adapter(log_sql => 1);
    my @lines = capture_stdout {
        $log->info('normal message');
        $log->info('[SQL] SELECT 1');
    };
    is scalar @lines, 0, 'nothing on stdout when to_stdout=0'
};

subtest 'log_sql=1 to_stdout=1: SQL follows to_stdout routing' => sub {
    my $log = fresh_adapter(to_stdout => 1, log_sql => 1);
    my @lines = capture_stdout {
        $log->info('normal message');
        $log->info('[SQL] SELECT 1');
    };
    is scalar @lines, 2, 'both messages on stdout';
    ok( (grep { /\[SQL\]/ } @lines), 'SQL line present' )
};

subtest 'log_sql=1 to_file=1: SQL written to log file' => sub {
    my $log;
    my @file_lines = capture_file {
        my $path = shift;
        $log = fresh_adapter(to_file => 1, log_sql => 1, filename => $path);
        $log->info('normal message');
        $log->info('[SQL] SELECT 1');
    };
    my @stdout_lines = capture_stdout { };
    is scalar @file_lines, 2, 'both messages in file';
    ok( (grep { /\[SQL\]/ } @file_lines), 'SQL in file' );
    is scalar @stdout_lines, 0, 'nothing on stdout'
};

subtest 'popfile_level filters: info suppressed at level 0' => sub {
    my $log = fresh_adapter(to_stdout => 1, popfile_level => 0);
    my @lines = capture_stdout {
        $log->info('info message');
        $log->error('error message');
    };
    is scalar @lines, 1, 'only error makes it through';
    like $lines[0], qr/error message/, 'error message present'
};

subtest 'ring buffer captures last 10 lines' => sub {
    my $log = fresh_adapter(to_stdout => 1);
    capture_stdout { $log->info("msg $_") for 1..15 };
    my @ring = @{POPFile::Log::Adapter::ring()};
    is scalar @ring, 10, 'ring has exactly 10 entries';
    like $ring[-1], qr/msg 15/, 'last ring entry is newest'
};

done_testing;
