#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

my ($config, $mq) = TestHelper::setup();

my $mod = TestHelper::make_module('POPFile::Configuration', $config, $mq);

subtest 'default health is ok with empty message' => sub {
    is($mod->health_status(), 'ok', 'default status is ok');
    is($mod->health_message(), '', 'default message is empty');
};

subtest 'set_health stores status and message' => sub {
    $mod->set_health('warning', 'test degraded');
    is($mod->health_status(), 'warning', 'status updated to warning');
    is($mod->health_message(), 'test degraded', 'message stored');
};

subtest 'set_health without message defaults to empty string' => sub {
    $mod->set_health('critical');
    is($mod->health_status(), 'critical', 'status set to critical');
    is($mod->health_message(), '', 'message defaults to empty');
};

subtest 'set_health posts HLTH_SET to MQ with name, status, message' => sub {
    $mq->{posted} = [];
    $mod->set_health('ok', 'recovered');
    my @health = grep { $_->{type} eq 'HLTH_SET' } $mq->{posted}->@*;
    ok(scalar @health == 1, 'one HLTH_SET message posted');
    is($health[0]{msg}[0], $mod->name(), 'first arg is module name');
    is($health[0]{msg}[1], 'ok', 'second arg is status');
    is($health[0]{msg}[2], 'recovered', 'third arg is message');
};

done_testing;
