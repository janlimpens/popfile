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
use File::Spec;
use File::Temp qw(tempdir);

my $tmpdir = tempdir(CLEANUP => 1);
$ENV{TEST_DBCONNECT} = "dbi:SQLite:dbname=$tmpdir/pf.db";

my $host = $ENV{IMAP_TEST_HOST} // 'localhost';
my $port = $ENV{IMAP_TEST_PORT} // 10143;

my $imap = Mail::IMAPClient->new(
    Server => $host, Port => $port, User => 'test', Password => 'test',
    Uid => 1, Peek => 1)
    or plan skip_all => "Dovecot not reachable";

my $fixture_dir = File::Spec->catdir($TestHelper::REPO_ROOT, 't', 'fixtures');
my @ham_files  = sort glob "$fixture_dir/ham/*.eml";
my @spam_files = sort glob "$fixture_dir/spam/*.eml";

sub _slurp($p) { open my $f, '<:raw', $p; local $/; my $d = <$f>; close $f; $d }

sub _clear($folder) {
    return unless $imap->exists($folder);
    $imap->select($folder);
    my @u = $imap->search('ALL');
    $imap->delete_message(@u) if @u;
    $imap->expunge();
}

subtest 'train from IMAP output folders' => sub {
    _clear($_) for qw(INBOX POPfile.ham POPfile.spam);
    $imap->create('POPfile.ham')  unless $imap->exists('POPfile.ham');
    $imap->create('POPfile.spam') unless $imap->exists('POPfile.spam');
    $imap->select('POPfile.ham');
    $imap->append('POPfile.ham', _slurp($ham_files[0]));
    $imap->select('POPfile.spam');
    $imap->append('POPfile.spam', _slurp($spam_files[0]));

    my ($config, $mq) = TestHelper::setup();
    TestHelper::configure_db($config);
    $config->parameter('imap_enabled', 1);
    $config->parameter('imap_update_interval', 3600);
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

    require Services::IMAP;
    my $srv = Services::IMAP->new();
    TestHelper::wire($srv, $config, $mq);
    $srv->initialize();
    $srv->set_classifier($bayes);
    $srv->set_history($history);
    $srv->config('hostname', $host);
    $srv->config('port', $port);
    $srv->config('login', 'test');
    $srv->config('password', 'test');
    $srv->config('use_ssl', 0);
    $srv->config('watched_folders', 'INBOX');
    $srv->config('bucket_folder_mappings', 'ham-->POPfile.ham-->spam-->POPfile.spam-->');
    $srv->config('training_mode', 1);
    $srv->start();

    ok($srv->poll_sync(30), 'poll completed');
    $bayes->db_update_cache($session);

    my $ham = $bayes->get_bucket_word_count($session, 'ham');
    my $spam = $bayes->get_bucket_word_count($session, 'spam');
    ok($ham > 0, "ham words: $ham");
    ok($spam > 0, "spam words: $spam");

    $srv->stop();
    $history->stop();
    $bayes->stop();
};

_clear($_) for qw(INBOX POPfile.ham POPfile.spam);
$imap->logout();
done_testing;
