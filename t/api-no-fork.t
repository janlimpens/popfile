#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use Test::Mojo;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

require Services::Classifier;
my $svc = Services::Classifier->new();
TestHelper::wire($svc, $config, $mq);
$svc->set_classifier($bayes);
$svc->initialize();
$svc->start();

require POPFile::API;
my $api = POPFile::API->new();
TestHelper::wire($api, $config, $mq);
$api->initialize();
$api->set_service($svc);

sub with_stubbed_daemon {
    my ($code) = @_;
    my $listen;
    no warnings 'once';
    no warnings 'redefine';
    local *POPFile::API::_find_free_port = sub { 43123 };
    local *Mojo::Server::Daemon::new = sub {
        my ($class, %args) = @_;
        $listen = $args{listen};
        return bless {
            app => $args{app},
            listen => $args{listen},
        }, $class;
    };
    local *Mojo::Server::Daemon::start = sub { return 1 };
    local *Mojo::Server::Daemon::stop = sub { return 1 };
    local *Mojo::Server::Daemon::listen = sub { return $_[0]->{listen} };
    return $code->(\$listen);
}

subtest 'run_server removed from POPFile::API' => sub {
    ok(!POPFile::API->can('run_server'), 'run_server() has been removed');
};

subtest 'forked override removed from Services::Classifier' => sub {
    ok(!defined(&Services::Classifier::forked),
        'Services::Classifier no longer overrides forked()');
};

subtest 'start() registers in-process Mojo daemon without fork' => sub {
    with_stubbed_daemon(sub {
        my ($listen) = @_;
        $api->start();
        ok($api->can('daemon') && defined $api->daemon(),
            'daemon is set up in-process after start()');
        if ($api->can('daemon') && defined $api->daemon()) {
            isa_ok($api->daemon(), 'Mojo::Server::Daemon');
            is($$listen->[0], 'http://127.0.0.1:43123',
                'default api_local=1 binds to loopback');
            is($config->parameter('api_port'), 43123,
                'selected port is persisted to config');
        }
        $api->stop();
    });
};

subtest 'api_local=0 binds the API to all interfaces' => sub {
    with_stubbed_daemon(sub {
        my ($listen) = @_;
        $config->parameter('api_local', 0);
        $config->parameter('api_port', 0);
        $api->start();
        is($$listen->[0], 'http://*:43123',
            'api_local=0 binds to all interfaces');
        $api->stop();
    });
};

$svc->stop();
$bayes->stop();

done_testing;
