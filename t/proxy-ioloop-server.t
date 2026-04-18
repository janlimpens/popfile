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
use strict;
use warnings;

use Test2::V0;
use IO::Socket::INET ();
use Mojo::IOLoop ();
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();

require Proxy::Proxy;

{
    package TestProxy;
    use Object::Pad;
    class TestProxy :isa(Proxy::Proxy);

    method child ($client) {
        print $client "HELLO\n";
        close $client;
    }
}

my $proxy = TestProxy->new();
TestHelper::wire($proxy, $config, $mq);
$proxy->set_name('testproxy');
$proxy->initialize();
$config->parameter('testproxy_port', 0);
$config->parameter('testproxy_local', 0);

my $started = $proxy->start();
is($started, 1, 'proxy started successfully');

my $bound_port = $proxy->bound_port();
ok($bound_port > 0, "proxy bound to port $bound_port");

my $received = '';

Mojo::IOLoop->timer(0.1 => sub {
    my $sock = IO::Socket::INET->new(
        PeerAddr => '127.0.0.1',
        PeerPort => $bound_port,
        Proto => 'tcp',
        Timeout => 2,
    );
    if ($sock) {
        local $/ = undef;
        $received = <$sock>;
        $sock->close();
    }
    Mojo::IOLoop->timer(0.5 => sub { Mojo::IOLoop->stop() });
});

Mojo::IOLoop->start();

is($received, "HELLO\n", 'client received HELLO from subprocess');

$proxy->stop();

done_testing;
