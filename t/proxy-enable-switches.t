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
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();

sub make_proxy {
    my ($class) = @_;
    (my $file = $class) =~ s{::}{/}g;
    require "$file.pm";
    my $proxy = $class->new();
    TestHelper::wire($proxy, $config, $mq);
    $proxy->initialize();
    return $proxy;
}

subtest 'POP3, SMTP, and NNTP are disabled by default' => sub {
    my $pop3 = make_proxy('Proxy::POP3');
    my $smtp = make_proxy('Proxy::SMTP');
    my $nntp = make_proxy('Proxy::NNTP');

    is($config->parameter('pop3_enabled'), 0, 'POP3 disabled by default');
    is($config->parameter('smtp_enabled'), 0, 'SMTP disabled by default');
    is($config->parameter('nntp_enabled'), 0, 'NNTP disabled by default');

    is($pop3->start(), 2, 'POP3 start is skipped when disabled');
    is($smtp->start(), 2, 'SMTP start is skipped when disabled');
    is($nntp->start(), 2, 'NNTP start is skipped when disabled');
};

done_testing;
