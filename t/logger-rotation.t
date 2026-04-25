#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use File::Temp qw(tempdir);
use Test2::V0;
use TestHelper;

require POPFile::Logger;

my $seconds_per_day = 86400;

sub make_logger {
    my ($config, $mq) = TestHelper::setup();
    my $logger = POPFile::Logger->new();
    TestHelper::wire($logger, $config, $mq);
    $logger->initialize();
    return ($logger, $config)
}

subtest 'active log file is named popfile.log' => sub {
    my ($logger, $config) = make_logger();
    my $dir = tempdir(CLEANUP => 1) . '/';
    $config->parameter('logger_logdir', $dir);
    $config->parameter('GLOBAL_debug', 0);

    my $t0 = 1_000_000;
    no warnings 'redefine';
    local *POPFile::Logger::time = sub { $t0 };

    $logger->calculate_today();
    like($logger->debug_filename(), qr{popfile\.log$}, 'filename is popfile.log');
};

subtest 'rotation renames old log with ISO date and opens fresh popfile.log' => sub {
    my ($logger, $config) = make_logger();
    my $dir = tempdir(CLEANUP => 1) . '/';
    $config->parameter('logger_logdir', $dir);
    $config->parameter('GLOBAL_debug', 0);

    my $day1 = int(1_750_000_000 / $seconds_per_day) * $seconds_per_day;
    my $day2 = $day1 + $seconds_per_day;

    no warnings 'redefine';
    local *POPFile::Logger::time = sub { $day1 };
    $logger->calculate_today();

    open my $fh, '>', $logger->debug_filename() or die $!;
    print $fh "day1 content\n";
    close $fh;

    local *POPFile::Logger::time = sub { $day2 };
    $logger->calculate_today();

    my @dated = glob("${dir}popfile-????-??-??.log");
    is(scalar @dated, 1, 'one dated archive file exists');
    like($dated[0], qr{popfile-\d{4}-\d{2}-\d{2}\.log$}, 'archive file has ISO date');
    ok($logger->debug_filename() =~ m{popfile\.log$}, 'active filename ends with popfile.log');
};

subtest 'remove_debug_files deletes files older than 3 days' => sub {
    my ($logger, $config) = make_logger();
    my $dir = tempdir(CLEANUP => 1) . '/';
    $config->parameter('logger_logdir', $dir);

    my $now = 1_750_000_000;
    no warnings 'redefine';
    local *POPFile::Logger::time = sub { $now };

    for my $delta (1, 4, 7) {
        my $date = do {
            my @t = localtime($now - $delta * $seconds_per_day);
            sprintf '%04d-%02d-%02d', $t[5] + 1900, $t[4] + 1, $t[3]
        };
        open my $fh, '>', "${dir}popfile-${date}.log" or die $!;
        close $fh;
    }

    $logger->remove_debug_files();

    my @remaining = glob("${dir}popfile-*.log");
    is(scalar @remaining, 1, 'only the file within 3 days survives');
    like($remaining[0], qr{popfile-\d{4}-\d{2}-\d{2}\.log$}, 'surviving file has ISO date');
};

done_testing;
