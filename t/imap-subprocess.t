#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Mojo::IOLoop;
use TestHelper;

require Services::IMAP;

sub make_imap {
    my ($config, $mq) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $config->parameter('imap_enabled', 1);
    $config->parameter('imap_training_mode', 0);
    $config->parameter('imap_update_interval', 60);
    return ($imap, $config, $mq)
}

subtest 'poll() returns immediately without blocking the IOLoop' => sub {
    my ($imap, $config, $mq) = make_imap();
    my $timer_fired = 0;
    $imap->start();
    Mojo::IOLoop->next_tick(sub { $imap->poll() });
    Mojo::IOLoop->timer(0.3 => sub {
        $timer_fired = 1;
        Mojo::IOLoop->stop();
    });
    my $t0 = time();
    Mojo::IOLoop->start();
    my $elapsed = time() - $t0;
    ok($timer_fired, 'IOLoop timer fired while poll was running (not blocked)');
    ok($elapsed < 5, "elapsed time was $elapsed s (< 5 s expected)");
    $imap->stop();
};

subtest 'poll() does not run concurrently (guard flag)' => sub {
    my ($imap, $config, $mq) = make_imap();
    my $start_count = 0;
    no warnings 'redefine';
    local *Services::IMAP::_run_poll_work = sub { $start_count++ };
    $imap->start();
    Mojo::IOLoop->next_tick(sub {
        $imap->poll();
        $imap->poll();
    });
    Mojo::IOLoop->timer(0.5 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    ok($start_count <= 1, "subprocess started at most once despite double poll() ($start_count)");
    $imap->stop();
};

subtest 'poll() resets guard after subprocess completes' => sub {
    my ($imap, $config, $mq) = make_imap();
    my $start_count = 0;
    no warnings 'redefine';
    local *Services::IMAP::_run_poll_work = sub { $start_count++ };
    $imap->start();
    Mojo::IOLoop->next_tick(sub { $imap->poll() });
    Mojo::IOLoop->timer(0.3 => sub { $imap->poll() });
    Mojo::IOLoop->timer(0.8 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    ok($start_count >= 2, "subprocess started at least twice (guard reset after completion) (count=$start_count)");
    $imap->stop();
};

subtest 'IMAP_DONE is posted to MQ after poll completes' => sub {
    my ($imap, $config, $mq) = make_imap();
    no warnings 'redefine';
    local *Services::IMAP::_run_poll_work = sub { return { trained => 3, uid_nexts => {}, training_done => 0, error => undef } };
    $imap->start();
    Mojo::IOLoop->next_tick(sub { $imap->poll() });
    Mojo::IOLoop->timer(0.5 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    my @imap_done = grep { $_->{type} eq 'IMAP_DONE' } $mq->{posted}->@*;
    ok(scalar(@imap_done) >= 1, 'IMAP_DONE posted to MQ after poll');
    $imap->stop();
};

done_testing;
