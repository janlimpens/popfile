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

require UI::Mojo;
require POPFile::Configuration;

my $mq = bless {}, 'StubMQ';
sub StubMQ::post     {}
sub StubMQ::register {}

my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $ui = UI::Mojo->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();

subtest 'open_browser config param defaults to 0' => sub {
    is($ui->config('open_browser'), 0, 'open_browser default is 0');
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
    $ui->config('port', 0);
    my $port = $ui->_find_free_port();
    ok($port != 0, 'allocated port is non-zero');
};

done_testing;
