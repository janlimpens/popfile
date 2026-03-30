#!/usr/bin/perl
# POP3 integration test for the POPFile testbed.
#
# Prerequisites:
#   docker compose -f docker-compose.test.yml up -d
#   perl t/fixtures/setup_test_pop3_config.pl
#   carton exec perl popfile.pl &    # start POPFile POP3 proxy (port 1110)
#   seed at least one message via seed_imap.pl or IMAP client
#
# The test connects to POP3_TEST_HOST:POP3_TEST_PORT (default localhost:10110)
# as POP3_TEST_USER/POP3_TEST_PASS (default testuser/testpass).
# Set POP3_VIA_PROXY=1 to also verify the X-Text-Classification header.
#
# Skip by setting SKIP_INTEGRATION=1 or leaving POP3_TEST_HOST unset.

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;
use IO::Socket::INET;

if ($ENV{SKIP_INTEGRATION} || !$ENV{POP3_TEST_HOST}) {
    plan(skip_all => 'POP3 integration tests require POP3_TEST_HOST to be set');
}

my $host = $ENV{POP3_TEST_HOST} // 'localhost';
my $port = $ENV{POP3_TEST_PORT} // 10110;
my $user = $ENV{POP3_TEST_USER} // 'testuser';
my $pass = $ENV{POP3_TEST_PASS} // 'testpass';

my $sock = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    Proto => 'tcp',
    Timeout => 10,
) or plan(skip_all => "Cannot connect to $host:$port: $!");

sub recv_line {
    my $line = $sock->getline();
    chomp $line;
    $line =~ s/\r$//;
    return $line
}

sub send_cmd {
    my ($cmd) = @_;
    $sock->print("$cmd\r\n");
}

subtest 'greeting' => sub {
    my $banner = recv_line();
    like($banner, qr/^\+OK/, 'server sends +OK greeting');
};

subtest 'authentication' => sub {
    send_cmd("USER $user");
    my $resp = recv_line();
    like($resp, qr/^\+OK/, 'USER accepted');
    send_cmd("PASS $pass");
    $resp = recv_line();
    like($resp, qr/^\+OK/, 'PASS accepted');
};

subtest 'stat' => sub {
    send_cmd('STAT');
    my $resp = recv_line();
    like($resp, qr/^\+OK \d+ \d+/, 'STAT returns message count and size');
};

subtest 'retr first message' => sub {
    send_cmd('RETR 1');
    my $resp = recv_line();
    like($resp, qr/^\+OK/, 'RETR 1 accepted');
    my @lines;
    while (my $line = recv_line()) {
        last if $line eq '.';
        push @lines, $line;
    }
    ok(scalar @lines > 0, 'RETR 1 returned message lines');
    if ($ENV{POP3_VIA_PROXY}) {
        my $found = grep { /^X-Text-Classification:/i } @lines;
        ok($found, 'message contains X-Text-Classification header');
    }
};

subtest 'quit' => sub {
    send_cmd('QUIT');
    my $resp = recv_line();
    like($resp, qr/^\+OK/, 'QUIT accepted');
};

$sock->close();

done_testing();
