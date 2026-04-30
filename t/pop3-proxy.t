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
use Mail::IMAPClient;
use IO::Socket::INET;
use File::Spec;
use File::Temp qw(tempdir);

my $tmpdir = tempdir(CLEANUP => 1);
$ENV{TEST_DBCONNECT} = "dbi:SQLite:dbname=$tmpdir/pf.db";

my $imap = Mail::IMAPClient->new(
    Server => 'localhost', Port => 10143, User => 'test', Password => 'test', Uid => 1)
    or plan skip_all => "Dovecot not reachable";

my $fixture_dir = File::Spec->catdir($TestHelper::REPO_ROOT, 't', 'fixtures');
my @ham_files  = sort glob "$fixture_dir/ham/*.eml";
my @spam_files = sort glob "$fixture_dir/spam/*.eml";

sub _slurp($p) { open my $f, '<:raw', $p; local $/; my $d = <$f>; close $f; $d }
sub _clear($f) { return unless $imap->exists($f); $imap->select($f); my @u = $imap->search('ALL'); $imap->delete_message(@u) if @u; $imap->expunge() }

_clear($_) for qw(INBOX);

my ($config, $mq) = TestHelper::setup();
TestHelper::configure_db($config);
$config->set_started(1);

require POPFile::History;
my $history = POPFile::History->new();
TestHelper::wire($history, $config, $mq);
$history->initialize();
$history->start();

my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);
$bayes->set_history($history);
$history->set_classifier($bayes);
my $session = $bayes->get_session_key('admin', '');
$bayes->create_bucket($session, 'ham');
$bayes->create_bucket($session, 'spam');
$bayes->add_message_to_bucket($session, 'ham', $ham_files[0]);
$bayes->add_message_to_bucket($session, 'ham', $ham_files[1]);
$bayes->add_message_to_bucket($session, 'ham', $ham_files[2]);
$bayes->add_message_to_bucket($session, 'ham', $ham_files[3]);
$bayes->add_message_to_bucket($session, 'spam', $spam_files[0]);
$bayes->add_message_to_bucket($session, 'spam', $spam_files[1]);
$bayes->add_message_to_bucket($session, 'spam', $spam_files[2]);
$bayes->add_message_to_bucket($session, 'spam', $spam_files[3]);

require Services::Classifier;
my $svc = Services::Classifier->new();
TestHelper::wire($svc, $config, $mq);
$svc->initialize();
$svc->set_classifier($bayes);
$svc->set_history($history);
$svc->start();

sub _pop3_fetch ($msg_num) {
    my $sock = IO::Socket::INET->new(
        PeerAddr => 'localhost', PeerPort => 10110, Proto => 'tcp', Timeout => 5)
        or BAIL_OUT("POP3 connect failed");
    my $r = sub { my $l = $sock->getline(); chomp $l; $l =~ s/\r$//; $l };
    my $s = sub ($c) { $sock->print("$c\r\n") };
    $r->(); $s->("USER test"); $r->(); $s->("PASS test"); $r->();
    $s->("RETR $msg_num");
    $r->();
    my @lines;
    while (my $l = $r->()) { last if $l eq '.'; push @lines, $l }
    $sock->close();
    return join("\r\n", @lines) . "\r\n"
}

sub _classify ($raw, $file) {
    open my $fh, '>', $file or die $!;
    print $fh $raw;
    close $fh;
    return $svc->classify($file)
}

subtest 'classify ham message retrieved via POP3' => sub {
    _clear('INBOX');
    $imap->select('INBOX');
    $imap->append('INBOX', _slurp($ham_files[4]));

    my $raw = _pop3_fetch(1);
    ok(length($raw) > 0, 'POP3 RETR returned message');

    my $bucket = _classify($raw, "$tmpdir/pop3-ham.msg");
    ok($bucket ne 'unclassified', "POP3-fetched classified (got: $bucket)");
};

subtest 'classify spam message retrieved via POP3' => sub {
    _clear('INBOX');
    $imap->select('INBOX');
    $imap->append('INBOX', _slurp($spam_files[4]));

    my $raw = _pop3_fetch(1);
    ok(length($raw) > 0, 'POP3 RETR returned message');

    my $bucket = _classify($raw, "$tmpdir/pop3-spam.msg");
    ok($bucket ne 'unclassified', "POP3-fetched classified (got: $bucket)");
};

_clear('INBOX');
$imap->logout();
done_testing;
