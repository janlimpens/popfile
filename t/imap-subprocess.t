#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Cpanel::JSON::XS;
use Mojo::IOLoop;
use TestHelper;

our $test_cache_called = 0;

require Services::IMAP;

sub make_imap {
    my ($config, $mq) = TestHelper::setup();
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    TestHelper::set_config($config, 'imap_enabled' => 1);
    TestHelper::set_config($config, 'imap_training_mode' => 0);
    TestHelper::set_config($config, 'imap_update_interval' => 60);
    TestHelper::load_singleton($config);
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
    $imap->start();
    Mojo::IOLoop->next_tick(sub { $imap->poll() });
    Mojo::IOLoop->timer(0.3 => sub { $imap->poll() });
    Mojo::IOLoop->timer(0.8 => sub { Mojo::IOLoop->stop() });
    Mojo::IOLoop->start();
    my @imap_done = grep { $_->{type} eq 'IMAP_DONE' } $mq->{posted}->@*;
    ok(scalar(@imap_done) >= 2, "IMAP_DONE posted at least twice (guard reset between polls) (count=" . scalar(@imap_done) . ")");
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

subtest 'worker loop calls db_update_cache before processing poll' => sub {
    my ($imap, $config, $mq) = make_imap();
    $test_cache_called = 0;
    my $run_poll_called = 0;
    {
        package TestClassifier;
        sub new { bless {}, shift }
        sub get_session_key { 'test-session' }
        sub get_all_buckets { ('spam', 'ham') }
        sub is_pseudo_bucket { 0 }
        sub db_update_cache { $main::test_cache_called++; return 1 }
        sub can { 1 }
    }
    my $classifier = TestClassifier->new();
    $imap->set_classifier($classifier);
    pipe(my $reader, my $writer);
    $writer->autoflush(1);
    my $msg = Cpanel::JSON::XS::->new->encode({
        cmd => 'poll',
        training_mode => 0,
        train_buckets => [],
        pending_folder_moves => {},
        pending_direct_moves => {},
        uid_next_overrides => {},
        folder_change_flag => 0,
    });
    syswrite($writer, $msg . "\n");
    syswrite($writer, "quit\n");
    close($writer);
    my $fake_sub = bless {}, 'Mojo::Subprocess';
    my $progress_called = 0;
    my $cache_before_poll = 0;
    no warnings 'redefine';
    local *Services::IMAP::_run_poll_work = sub {
        $run_poll_called++;
        $cache_before_poll = $test_cache_called;
        return { trained => 0, uid_nexts => {}, training_done => 0, error => undef };
    };
    local *Mojo::Subprocess::progress = sub { $progress_called++ };
    $imap->_imap_worker_loop($fake_sub, $reader);
    ok($test_cache_called > 0, 'db_update_cache was called in worker loop');
    ok($cache_before_poll > 0, 'db_update_cache was called before _run_poll_work');
    ok($run_poll_called > 0, '_run_poll_work was called');
    ok($progress_called > 0, 'progress was emitted after poll');
    $imap->stop();
};

done_testing;
