#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use feature 'try';
no warnings 'experimental::try';

my $loaded = do {
    try { require POPFile::Activity; 1 } catch($e) { 0 } };
ok($loaded, 'POPFile::Activity loaded') or BAIL_OUT('POPFile::Activity failed to load');

# Minimal unit test: Activity ring buffer and event validation
# (no full module lifecycle — tested in isolation)

# Construct with minimal wiring
my $activity = POPFile::Activity->new();
ok($activity, 'Activity instance created');
is($activity->name(), 'activity', 'default name is activity');

# add_event
my $evt = $activity->add_event({
    level => 'info',
    module => 'test',
    task => 'Testing',
    message => 'Hello activity' });
ok($evt, 'add_event returns event');
is($evt->{id}, 1, 'first event has id 1');
ok($evt->{ts} > 0, 'event has timestamp');

# parent_id validation
my $child = $activity->add_event({
    level => 'info',
    module => 'test',
    task => 'Child',
    message => 'I am a child',
    parent_id => 1 });
ok($child, 'event with valid parent_id succeeds');
is($child->{parent_id}, 1, 'parent_id is stored');

my $orphan = $activity->add_event({
    level => 'info',
    module => 'test',
    task => 'Orphan',
    message => 'No parent',
    parent_id => 999 });
ok(!$orphan, 'event with invalid parent_id returns undef');

# recent_events
my $recent = $activity->recent_events(0);
is(scalar $recent->@*, 2, 'two events in buffer (orphan rejected)');

my $since = $activity->recent_events(1);
is(scalar $since->@*, 1, 'one event after since=1');

my $warn = $activity->recent_events(0, 'warn');
is(scalar $warn->@*, 0, 'no warn-level events');

$activity->add_event({
    level => 'error',
    module => 'test',
    task => 'Error',
    message => 'Something broke' });
my $errors = $activity->recent_events(0, 'error');
is(scalar $errors->@*, 1, 'one error-level event');

# buffer overflow
for my $i (1..600) {
    $activity->add_event({
        level => 'info',
        module => 'flood',
        task => "Item $i",
        message => 'overflow test' });
}
my $all = $activity->recent_events(0);
cmp_ok(scalar $all->@*, '<=', 500, 'buffer capped at max size');

done_testing;
