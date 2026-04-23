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
require POPFile::API::Controller::Config;
require Proxy::NNTP;
require Proxy::POP3;
require Proxy::SMTP;

my $api = POPFile::API->new();
TestHelper::wire($api, $config, $mq);
$api->initialize();

for my $class (qw(Proxy::POP3 Proxy::SMTP Proxy::NNTP)) {
    my $proxy = $class->new();
    TestHelper::wire($proxy, $config, $mq);
    $proxy->initialize();
}

my $controller = bless {
    api => $api,
    rendered => undef,
    req_json => undef,
}, 'POPFile::API::Controller::Config';

no warnings 'once';
no warnings 'redefine';
local *POPFile::API::Controller::Config::popfile_api = sub {
    my ($self) = @_;
    return $self->{api};
};
local *POPFile::API::Controller::Config::req = sub {
    my ($self) = @_;
    return bless { body => $self->{req_json} }, 'TestConfigReq';
};
local *POPFile::API::Controller::Config::render = sub {
    my ($self, %args) = @_;
    $self->{rendered} = \%args;
    return $self;
};
local *TestConfigReq::json = sub {
    my ($self) = @_;
    return $self->{body};
};

subtest 'config controller exposes proxy enabled keys' => sub {
    $controller->{rendered} = undef;
    $controller->get_config();
    my $json = $controller->{rendered}{json};
    is($json->{pop3_enabled}, 0, 'pop3_enabled exposed with default 0');
    is($json->{smtp_enabled}, 0, 'smtp_enabled exposed with default 0');
    is($json->{nntp_enabled}, 0, 'nntp_enabled exposed with default 0');
};

subtest 'config controller persists proxy enabled keys' => sub {
    $controller->{req_json} = {
        pop3_enabled => 1,
        smtp_enabled => 1,
        nntp_enabled => 1,
    };
    $controller->update_config();

    is($config->parameter('pop3_enabled'), 1, 'pop3_enabled updated');
    is($config->parameter('smtp_enabled'), 1, 'smtp_enabled updated');
    is($config->parameter('nntp_enabled'), 1, 'nntp_enabled updated');
};

done_testing;
