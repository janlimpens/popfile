#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Mojo::IOLoop;

require POPFile::Loader;

# ---------------------------------------------------------------------------
# T3: CORE_register_timers() replaces the CORE_service() polling loop.
# These tests verify the IOLoop-based startup infrastructure.
# ---------------------------------------------------------------------------

subtest 'Loader has CORE_register_timers method' => sub {
    ok(POPFile::Loader->can('CORE_register_timers'),
        'CORE_register_timers() exists on Loader');
};

subtest 'IOLoop starts and stops cleanly' => sub {
    my $fired = 0;
    Mojo::IOLoop->timer(0.1 => sub {
        $fired = 1;
        Mojo::IOLoop->stop();
    });
    ok(lives { Mojo::IOLoop->start() }, 'IOLoop runs without error');
    ok($fired, 'IOLoop timer fired before stop');
};

subtest 'recurring timers fire inside IOLoop' => sub {
    my $count = 0;
    my $id = Mojo::IOLoop->recurring(0.05 => sub { $count++ });
    Mojo::IOLoop->timer(0.2 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    Mojo::IOLoop->remove($id);
    ok($count >= 2, "recurring timer fired $count times (expected >= 2)");
};

done_testing;
