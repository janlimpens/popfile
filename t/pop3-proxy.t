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
use IO::Socket::INET;
use Mail::IMAPClient;
use TestHelper;
use File::Spec;

my $host = $ENV{POP3_TEST_HOST} // 'localhost';
my $port = $ENV{POP3_TEST_PORT} // 10110;
my $user = $ENV{POP3_TEST_USER} // 'test';
my $pass = $ENV{POP3_TEST_PASS} // 'test';

my $sock = IO::Socket::INET->new(
    PeerAddr => $host, PeerPort => $port, Proto => 'tcp', Timeout => 5)
    or plan skip_all => "Dovecot POP3 not reachable at $host:$port";

sub _recv { my $l = $sock->getline(); chomp $l; $l =~ s/\r$//; $l }
sub _send($cmd) { $sock->print("$cmd\r\n") }

subtest 'POP3 greeting' => sub {
    my $banner = _recv();
    like($banner, qr/^\+OK/, 'POP3 +OK greeting');
};

subtest 'login and check empty mailbox' => sub {
    _send("USER $user");
    like(_recv(), qr/^\+OK/, 'USER accepted');
    _send("PASS $pass");
    like(_recv(), qr/^\+OK/, 'PASS accepted');
    _send('STAT');
    like(_recv(), qr/^\+OK 0 0/, 'STAT shows empty mailbox');
    _send('QUIT');
    like(_recv(), qr/^\+OK/, 'QUIT accepted');
};
$sock->close();

subtest 'seed and retrieve messages via POP3' => sub {
    my $imap = Mail::IMAPClient->new(
        Server => 'localhost', Port => 10143, User => 'test', Password => 'test',
        Uid => 1)
        or BAIL_OUT("Cannot connect IMAP to seed");

    for my $f (qw(INBOX)) {
        next unless $imap->exists($f);
        $imap->select($f);
        my @u = $imap->search('ALL');
        $imap->delete_message(@u) if @u;
        $imap->expunge();
    }

    my $fixture_dir = File::Spec->catdir($TestHelper::REPO_ROOT, 't', 'fixtures');
    my @ham_files = sort glob "$fixture_dir/ham/*.eml";
    sub _slurp($p) { open my $f, '<:raw', $p; local $/; my $d = <$f>; close $f; $d }

    $imap->select('INBOX');
    $imap->append('INBOX', _slurp($ham_files[0]));
    $imap->append('INBOX', _slurp($ham_files[1]));
    $imap->logout();

    $sock = IO::Socket::INET->new(
        PeerAddr => $host, PeerPort => $port, Proto => 'tcp', Timeout => 5)
        or BAIL_OUT("POP3 reconnect failed");
    _recv();
    _send("USER $user"); _recv();
    _send("PASS $pass"); _recv();

    _send('STAT');
    my $stat = _recv();
    like($stat, qr/^\+OK [1-9]\d* \d+/, "STAT shows messages: $stat");

    _send('LIST');
    like(_recv(), qr/^\+OK/, 'LIST accepted');
    while (my $l = _recv()) { last if $l eq '.' }

    _send('RETR 1');
    like(_recv(), qr/^\+OK/, 'RETR 1 accepted');
    my $body = '';
    while (my $l = _recv()) { last if $l eq '.'; $body .= "$l\n" }
    ok(length($body) > 0, 'RETR 1 returned message body');

    _send('QUIT');
    _recv();
};
$sock->close();

done_testing;
