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

subtest 'pipe machinery removed' => sub {
    ok(!$mq->can('forked'), 'forked removed');
    ok(!$mq->can('postfork'), 'postfork removed');
    ok(!$mq->can('reaper'), 'reaper removed');
    ok(!$mq->can('flush_child_data'), 'flush_child_data removed');
    ok(!$mq->can('read_pipe'), 'read_pipe removed');
};

subtest 'in-process pub/sub works' => sub {
    my @received;
    my $waiter = bless { received => \@received }, 'TestInprocWaiter';

    $mq->register('TICKD', $waiter);
    $mq->post('TICKD', 'ts123');

    is(scalar @received, 0, 'not delivered before service()');
    $mq->service();
    is(scalar @received, 1, 'delivered after service()');
    is($received[0]{type}, 'TICKD', 'type correct');
    is($received[0]{msg}[0], 'ts123', 'payload correct');
};

subtest 'post drops unregistered type silently' => sub {
    $mq->post('NOSUB', 'data');
    $mq->service();
    ok(1, 'no exception for unregistered type');
};

{
    package TestInprocWaiter;
    sub deliver { my ($self, $type, @msg) = @_; push @{$self->{received}}, { type => $type, msg => \@msg } }
    sub name    { 'inproc-waiter' }
}

$mq->stop();
done_testing;
