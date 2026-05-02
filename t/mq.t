#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

my ($config, $stub_mq, $tmpdir) = TestHelper::setup();

my $mq = TestHelper::make_module('POPFile::MQ', $config, $stub_mq);
$mq->start();

# Build a minimal waiter object for use in tests
sub make_waiter {
    my ($name, $received) = @_;
    my $w = bless { name => $name, received => $received }, 'TestMQWaiter';
    return $w
}

{
    package TestMQWaiter;
    sub deliver { my ($self, $type, @msg) = @_; push $self->{received}->@*, { type => $type, msg => \@msg } }
    sub name    { $_[0]->{name} }
}

# -----------------------------------------------------------------------
subtest 'post without registered waiter is dropped silently' => sub {
    $mq->post('TICKD');
    $mq->service();
    ok( 1, 'posting unregistered type does not die' );
};

# -----------------------------------------------------------------------
subtest 'register and deliver on service' => sub {
    my @received;
    my $waiter = make_waiter('w1', \@received);

    $mq->register('TICKD', $waiter);
    $mq->post('TICKD', 'ping');
    is( scalar @received, 0, 'message not delivered before service()' );

    $mq->service();
    is( scalar @received, 1,      'waiter received one message after service()' );
    is( $received[0]{type}, 'TICKD', 'type is TICKD' );
    is( $received[0]{msg}[0], 'ping',  'first arg is "ping"' );
};

# -----------------------------------------------------------------------
subtest 'multiple messages queued and all delivered' => sub {
    my @received;
    my $waiter = make_waiter('w2', \@received);

    $mq->register('LOGIN', $waiter);
    $mq->post('LOGIN', 'alice');
    $mq->post('LOGIN', 'bob');

    $mq->service();
    is( scalar @received, 2,       'both LOGIN messages delivered' );
    is( $received[0]{msg}[0], 'alice', 'first message is alice' );
    is( $received[1]{msg}[0], 'bob',   'second message is bob' );
};

# -----------------------------------------------------------------------
subtest 'multiple waiters for same type all receive' => sub {
    my (@r1, @r2);
    my $w1 = make_waiter('w3', \@r1);
    my $w2 = make_waiter('w4', \@r2);

    $mq->register('COMIT', $w1);
    $mq->register('COMIT', $w2);
    $mq->post('COMIT', 'slot42');

    $mq->service();
    is( scalar @r1, 1, 'first waiter received COMIT' );
    is( scalar @r2, 1, 'second waiter received COMIT' );
    is( $r1[0]{msg}[0], 'slot42', 'first waiter got correct payload' );
    is( $r2[0]{msg}[0], 'slot42', 'second waiter got correct payload' );
};

# -----------------------------------------------------------------------
$mq->stop();

done_testing;
