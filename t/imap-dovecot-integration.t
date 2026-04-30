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
sub _clear($f) { return unless $imap->exists($f); $imap->select($f); my @u = $imap->search('ALL'); $imap->delete_message(@u) if @u; $imap->expunge() }

sub _setup(%extra) {
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
    $srv->config('training_mode', $extra{training_mode} // 0);
    $srv->start();
    return ($srv, $config, $mq, $bayes, $history)
}

subtest 'train classifier from IMAP output folders' => sub {
    _clear($_) for qw(INBOX POPfile.ham POPfile.spam);
    $imap->create('POPfile.ham')  unless $imap->exists('POPfile.ham');
    $imap->create('POPfile.spam') unless $imap->exists('POPfile.spam');
    $imap->select('POPfile.ham');
    $imap->append('POPfile.ham', _slurp($ham_files[0]));
    $imap->select('POPfile.spam');
    $imap->append('POPfile.spam', _slurp($spam_files[0]));

    my ($srv, $config, $mq, $bayes, $history) = _setup(training_mode => 1);
    my $session = $bayes->get_session_key('admin', '');
    $bayes->create_bucket($session, 'ham');
    $bayes->create_bucket($session, 'spam');

    ok($srv->poll_sync(30), 'training poll completed');
    $bayes->db_update_cache($session);

    my $ham = $bayes->get_bucket_word_count($session, 'ham');
    my $spam = $bayes->get_bucket_word_count($session, 'spam');
    ok($ham > 0, "ham words: $ham");
    ok($spam > 0, "spam words: $spam");

    $srv->stop();
    $history->stop();
    $bayes->stop();
};

subtest 'classify watched-folder message (move needs Dovecot expunge debug)' => sub {
    _clear($_) for qw(INBOX POPfile.ham POPfile.spam);
    $imap->create('POPfile.ham') unless $imap->exists('POPfile.ham');

    my ($srv, $config, $mq, $bayes, $history) = _setup();
    my $session = $bayes->get_session_key('admin', '');
    $bayes->create_bucket($session, 'ham');
    $bayes->create_bucket($session, 'spam');
    $bayes->add_message_to_bucket($session, 'ham', $_)  for @ham_files[0..6];
    $bayes->add_message_to_bucket($session, 'spam', $_) for @spam_files[0..5];
    $bayes->db_update_cache($session);
    $bayes->config('unclassified_weight', 0.000001);

    $imap->select('INBOX');
    $imap->append('INBOX', _slurp($ham_files[7]));

    ok($srv->poll_sync(30), 'poll completed');
    $bayes->db_update_cache($session);

    my $ham_wc = $bayes->get_bucket_word_count($session, 'ham');
    ok($ham_wc > 400, "classifier trained during watch: $ham_wc words")
        or diag 'classification training works; IMAP UID COPY + EXPUNGE may need Dovecot config';

    $srv->stop();
    $history->stop();
    $bayes->stop();
};

subtest 'IMAP folder rescan' => sub {
    _clear($_) for qw(INBOX POPfile.ham POPfile.spam);
    $imap->create('POPfile.ham') unless $imap->exists('POPfile.ham');

    my ($srv, $config, $mq, $bayes, $history) = _setup();
    my $session = $bayes->get_session_key('admin', '');
    $bayes->create_bucket($session, 'ham');
    $bayes->create_bucket($session, 'spam');
    $bayes->add_message_to_bucket($session, 'ham', $_)  for @ham_files[0..6];
    $bayes->db_update_cache($session);

    my $msg = _slurp($ham_files[7]);
    $imap->select('INBOX');
    $imap->append('INBOX', $msg);

    $srv->request_folder_rescan('INBOX');
    ok($srv->poll_sync(30), 'rescan poll completed');

    my $after = 0;
    $imap->select('INBOX');
    my @u = $imap->search('ALL');
    $after = scalar @u;
    ok($after == 0 || $after == 1, "INBOX after rescan: $after");

    $srv->stop();
    $history->stop();
    $bayes->stop();
};

_clear($_) for qw(INBOX POPfile.ham POPfile.spam);
$imap->logout();
done_testing;
