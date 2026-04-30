#!/usr/bin/perl
BEGIN {
    @INC = grep { !/\/lib$/ && $_ ne 'lib' && !/thread-multi/ } @INC;
    require FindBin;
    require Cwd;
    my $root = Cwd::abs_path("$FindBin::Bin/..");
    require lib;
    lib->import("$root/local/lib/perl5");
    unshift @INC, "$FindBin::Bin/lib", $root;
}
use v5.38;
use warnings;

use Test2::V0;
use TestHelper;

require Services::IMAP;

sub make_imap(%extra) {
    my ($config, $mq, $tmpdir) = TestHelper::setup();
    $config->parameter('imap_enabled', 1);
    $config->parameter('imap_update_interval', 3600);
    my $srv = Services::IMAP->new();
    TestHelper::wire($srv, $config, $mq);
    $srv->initialize();
    $srv->set_classifier(bless({}, 'ImapPollSyncTest::StubClassifier'));
    $srv->set_history(bless({}, 'ImapPollSyncTest::StubHistory'));
    $srv->start();
    $srv->config($_, $extra{$_}) for keys %extra;
    return ($srv, $config, $mq, $tmpdir)
}

subtest 'poll_sync completes when poll is not running' => sub {
    my ($srv) = make_imap();
    ok(!$srv->poll_running(), 'not running before poll_sync');
    ok($srv->poll_sync(5), 'poll_sync returns true');
    ok(!$srv->poll_running(), 'not running after poll_sync');
    $srv->stop();
};

subtest 'poll_running is reader-accessible' => sub {
    my ($srv) = make_imap();
    ok(defined $srv->poll_running(), 'poll_running readable');
    is($srv->poll_running(), 0, 'poll_running starts false');
    $srv->stop();
};

subtest 'folder_change_flag is reader-accessible' => sub {
    my ($srv) = make_imap();
    is($srv->folder_change_flag(), 0, 'folder_change_flag starts 0');
    $srv->stop();
};

subtest 'folders and mailboxes accessors return refs' => sub {
    my ($srv) = make_imap();
    ok(ref $srv->folders() eq 'HASH', 'folders returns hashref');
    ok(ref $srv->mailboxes() eq 'ARRAY', 'mailboxes returns arrayref');
    is(scalar $srv->folders()->%*, 0, 'folders empty before poll');
    $srv->stop();
};

subtest 'classifier and history are reader-accessible' => sub {
    my ($srv) = make_imap();
    ok(defined $srv->classifier(), 'classifier readable');
    ok(defined $srv->history(), 'history readable');
    $srv->stop();
};

done_testing;

package ImapPollSyncTest::StubClassifier;
sub new { bless {}, shift }
sub get_all_buckets  { () }
sub is_pseudo_bucket { 0 }

package ImapPollSyncTest::StubHistory;
sub new { bless {}, shift }
sub force_requery {}
sub get_slot_from_hash { '' }
