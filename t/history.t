#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

# Regression test for issue #97: POPFile::History::service() crashed on first
# call because $commit_list was initialised to undef.  commit_history() did
# `unless (@{$commit_list})` which is fatal when the value is undef.
# Fixed in commit 2c1745b: initialise to [] instead.

subtest 'service() survives before any COMIT messages' => sub {
    my ($config, $mq, $tmpdir) = TestHelper::setup();

    require POPFile::History;
    my $history = POPFile::History->new();
    TestHelper::wire($history, $config, $mq);
    $history->initialize();

    my $result;
    ok(
        lives { $result = $history->service() },
        'service() does not die with empty commit list',
    );
    is($result, 1, 'service() returns 1');
};

done_testing;
