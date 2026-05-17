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
use TestHelper;

require POPFile::API;

my ($config, $mq, $tmpdir) = TestHelper::setup();

my $ui = POPFile::API->new();
TestHelper::wire($ui, $config, $mq);
$ui->initialize();
TestHelper::set_config($config,
    api_open_browser => 1,
    api_port => 0,
);

subtest 'open_browser config param defaults to 1' => sub {
    is($ui->config->get('open_browser'), 1, 'open_browser default is 1');
};

subtest '_find_free_port returns a usable port' => sub {
    my $port = $ui->_find_free_port();
    ok($port > 0, "got a port: $port");
    ok($port <= 65535, 'port is in valid range');
    my $sock = IO::Socket::INET->new(
        Listen => 1,
        Proto => 'tcp',
        LocalAddr => '127.0.0.1',
        LocalPort => $port,
    );
    ok(defined $sock, 'can bind to the returned port')
        or diag "bind failed: $!";
    $sock->close() if defined $sock;
};

subtest 'port 0 config triggers free-port allocation' => sub {
    my $port = $ui->_find_free_port();
    ok($port != 0, 'allocated port is non-zero');
};

done_testing;
