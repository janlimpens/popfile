#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use File::Temp qw(tempfile);

my ($config, $mq, $tmpdir) = TestHelper::setup();

my ($db_fh, $db_file) = tempfile(DIR => $tmpdir, SUFFIX => '.db');
close $db_fh;
unlink $db_file;

$config->parameter('bayes_dbconnect', 'dbi:SQLite:dbname=$dbname');
$config->parameter('bayes_database', $db_file);

require Classifier::WordMangle;
my $wm = Classifier::WordMangle->new();
TestHelper::wire($wm, $config, $mq);
$wm->initialize();
$wm->start();

require Classifier::Bayes;
my $bayes = Classifier::Bayes->new();
TestHelper::wire($bayes, $config, $mq);
$bayes->set_history(bless {}, 'TestHelper::History');
$bayes->initialize();
$bayes->parser()->set_mangle($wm);
$bayes->start();

require POPFile::History;
my $history = POPFile::History->new();
TestHelper::wire($history, $config, $mq);
$history->set_classifier($bayes);
$history->initialize();

# -----------------------------------------------------------------------
subtest 'history start and stop cleanly' => sub {
    ok(lives { $history->start() }, 'history start does not die');
    ok(lives { $history->stop()  }, 'history stop does not die');
};

# -----------------------------------------------------------------------
subtest 'history start/stop cycle is idempotent' => sub {
    ok(lives { $history->start() }, 'second start does not die');
    ok(lives { $history->stop()  }, 'second stop does not die');
};

# -----------------------------------------------------------------------
subtest 'service completes without error' => sub {
    $history->start();
    ok(lives { $history->service() }, 'service() does not die');
    $history->stop();
};

# -----------------------------------------------------------------------
subtest 'reserve_slot allocates a numeric slot and file path' => sub {
    $history->start();

    my ($slot, $file);
    ok(lives { ($slot, $file) = $history->reserve_slot() }, 'reserve_slot does not die');
    ok(defined $slot && $slot =~ /^\d+$/, 'slot is a positive integer');
    ok(defined $file, 'file path is defined');

    $history->release_slot($slot);
    $history->stop();
};

# -----------------------------------------------------------------------
subtest 'commit_slot + service persists entry as valid slot' => sub {
    $history->start();

    my $session = $bayes->get_session_key('admin', '');
    $bayes->create_bucket($session, 'inbox');

    my ($slot, $file) = $history->reserve_slot();

    open my $fh, '>', $file
        or die "Cannot write slot file: $!";
    print $fh "From: sender\@example.com\r\nSubject: test\r\nDate: Mon, 1 Jan 2024 00:00:00 +0000\r\n\r\nBody\r\n";
    close $fh;

    $history->commit_slot($session, $slot, 'inbox', '');
    $history->service();

    ok($history->is_valid_slot($slot), 'slot appears in history after commit');

    $bayes->release_session_key($session);
    $history->stop();
};

# -----------------------------------------------------------------------
$bayes->stop();

done_testing;
