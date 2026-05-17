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

require POPFile::API;
require POPFile::API::Controller::IMAP;

my $api = POPFile::API->new();
TestHelper::wire($api, $config, $mq);
$api->initialize();

subtest '_make_test_client uses request values without mutating live imap config' => sub {
    TestHelper::set_config($config,
        imap_hostname => 'live.example',
        imap_port => 993,
        imap_login => 'live-user',
        imap_password => 'live-pass',
        imap_use_ssl => 1,
    );

    my $controller = bless { api => $api }, 'POPFile::API::Controller::IMAP';

    no warnings 'once';
    no warnings 'redefine';
    local *POPFile::API::Controller::IMAP::popfile_api = sub {
        my ($self) = @_;
        return $self->{api};
    };

    my $client = $controller->_make_test_client({
        hostname => 'test.example',
        port => 143,
        login => 'test-user',
        password => 'test-pass',
        use_ssl => 0,
    });

    ok(defined $client, '_make_test_client returns a client');

    require POPFile::Config;
    my $cfg = POPFile::Config->instance();
    is($cfg->get(imap => 'hostname'), 'live.example', 'singleton hostname unchanged');
    is($cfg->get(imap => 'port'), 993, 'singleton port unchanged');
    is($cfg->get(imap => 'login'), 'live-user', 'singleton login unchanged');
    is($cfg->get(imap => 'password'), 'live-pass', 'singleton password unchanged');
    is($cfg->get(imap => 'use_ssl'), 1, 'singleton ssl flag unchanged');
};

done_testing;
