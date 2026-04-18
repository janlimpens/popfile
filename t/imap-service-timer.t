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
    my ($config, $mq, $tmpdir) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $config->parameter('imap_enabled', 0);
    $config->parameter('imap_training_mode', 0);
    $config->parameter('imap_update_interval', 20);
    return $imap
}

subtest 'start() registers a recurring IOLoop timer' => sub {
    my $imap = make_imap();
    my $poll_count = 0;
    no warnings 'redefine';
    local *Services::IMAP::poll = sub { $poll_count++ };
    $imap->start();
    Mojo::IOLoop->timer(0.15 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    ok($poll_count == 0, "poll() not called while disabled (count=$poll_count)");
    $imap->stop();
};

subtest 'stop() removes the timer so poll() is not called after stop' => sub {
    my $imap = make_imap();
    my $poll_count = 0;
    no warnings 'redefine';
    local *Services::IMAP::poll = sub { $poll_count++ };
    $imap->start();
    $imap->stop();
    Mojo::IOLoop->timer(0.15 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    is($poll_count, 0, 'poll() not called after stop()');
};

subtest 'recurring timer fires poll() with short interval' => sub {
    my ($config, $mq) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $config->parameter('imap_enabled', 0);
    $config->parameter('imap_training_mode', 0);
    $config->parameter('imap_update_interval', 0);
    my $poll_count = 0;
    no warnings 'redefine';
    local *Services::IMAP::poll = sub { $poll_count++ };
    $imap->start();
    Mojo::IOLoop->timer(0.15 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    ok($poll_count >= 1, "poll() called at least once (count=$poll_count)");
    $imap->stop();
};

done_testing;
