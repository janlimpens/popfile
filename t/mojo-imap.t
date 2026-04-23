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
    $config->parameter('imap_hostname', 'live.example');
    $config->parameter('imap_port', 993);
    $config->parameter('imap_login', 'live-user');
    $config->parameter('imap_password', 'live-pass');
    $config->parameter('imap_use_ssl', 1);
    $config->parameter('GLOBAL_timeout', 75);

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

    is($client->config('hostname'), 'test.example', 'test client hostname comes from request');
    is($client->config('port'), 143, 'test client port comes from request');
    is($client->config('login'), 'test-user', 'test client login comes from request');
    is($client->config('password'), 'test-pass', 'test client password comes from request');
    is($client->config('use_ssl'), 0, 'test client ssl flag comes from request');
    is($client->global_config('timeout'), 75, 'test client inherits global timeout');

    is($config->parameter('imap_hostname'), 'live.example', 'hostname left unchanged');
    is($config->parameter('imap_port'), 993, 'port left unchanged');
    is($config->parameter('imap_login'), 'live-user', 'login left unchanged');
    is($config->parameter('imap_password'), 'live-pass', 'password left unchanged');
    is($config->parameter('imap_use_ssl'), 1, 'ssl flag left unchanged');
};

done_testing;
