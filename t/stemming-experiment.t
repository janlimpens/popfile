#!/usr/bin/perl
# Stemming experiment: compare classification accuracy with and without
# stemming on a real corpus.
#
# Skipped by default — run with TEST_STEMMING=1 and a corpus directory:
#
#   TEST_STEMMING=1 CORPUS_DIR=/path/to/messages carton exec prove t/stemming-experiment.t
#
# CORPUS_DIR must contain sub-directories named after buckets, each holding
# raw email files (one message per file).  At least 1000 messages total are
# needed for meaningful results.
#
# The test reports accuracy for each bucket and overall, but does not
# pass/fail on the numbers.

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use List::Util qw(sum0 shuffle);
use File::Find qw(find);
use TestHelper;

unless ($ENV{TEST_STEMMING}) {
    plan skip_all => 'Set TEST_STEMMING=1 to run the stemming experiment';
}

my $corpus_dir = $ENV{CORPUS_DIR} // "$Bin/../messages";

unless (-d $corpus_dir) {
    plan skip_all => "CORPUS_DIR $corpus_dir not found";
}

my @all_messages;
find(
    sub {
        return unless -f $_;
        my $bucket = (split m{/}, $File::Find::dir)[-1];
        push @all_messages, { file => $File::Find::name, bucket => $bucket };
    },
    $corpus_dir
);

if (@all_messages < 1000) {
    plan skip_all => sprintf 'Need at least 1000 messages, found %d', scalar @all_messages;
}

note sprintf "Corpus: %d messages in %s", scalar @all_messages, $corpus_dir;

sub run_experiment {
    my ($stemming_on) = @_;

    my ($config, $mq, $tmpdir) = TestHelper::setup();

    my $bayes = TestHelper::make_module('Classifier::Bayes', $config, $mq);
    $bayes->config('stemming', $stemming_on ? 1 : 0);
    my $session = $bayes->get_session_key('admin', '');

    my @shuffled = shuffle @all_messages;
    my $split = int(@shuffled * 0.7);
    my @train = @shuffled[0 .. $split - 1];
    my @test  = @shuffled[$split .. $#shuffled];

    for my $msg (@train) {
        if (open my $fh, '<', $msg->{file}) {
            my $content = do { local $/; <$fh> };
            close $fh;
            $bayes->add_message_to_bucket($session, $msg->{bucket}, \$content);
        }
    }

    my (%correct, %total);
    for my $msg (@test) {
        if (open my $fh, '<', $msg->{file}) {
            my $content = do { local $/; <$fh> };
            close $fh;
            my $predicted = $bayes->classify($session, \$content);
            $total{$msg->{bucket}}++;
            $correct{$msg->{bucket}}++ if defined $predicted && $predicted eq $msg->{bucket};
        }
    }

    my $total_correct = sum0 values %correct;
    my $total_all = sum0 values %total;
    my $accuracy = $total_all ? $total_correct / $total_all : 0;

    return {
        accuracy => $accuracy,
        per_bucket => {
            map {
                $_ => ($total{$_} ? $correct{$_} // 0 / $total{$_} : 0)
            } keys %total
        },
        total => $total_all,
        correct => $total_correct,
    };
}

note "Running without stemming...";
my $no_stem = run_experiment(0);
note sprintf "  Overall accuracy: %.1f%% (%d/%d)",
    $no_stem->{accuracy} * 100, $no_stem->{correct}, $no_stem->{total};

note "Running with stemming...";
my $with_stem = run_experiment(1);
note sprintf "  Overall accuracy: %.1f%% (%d/%d)",
    $with_stem->{accuracy} * 100, $with_stem->{correct}, $with_stem->{total};

my $delta = ($with_stem->{accuracy} - $no_stem->{accuracy}) * 100;
note sprintf "Delta (stemming - no stemming): %+.1f%%", $delta;

ok 1, 'experiment completed (no accuracy assertions)';

done_testing;
