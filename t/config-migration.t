#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use File::Temp qw(tempdir);

subtest 'legacy popfile.cfg is migrated to popfile.json' => sub {
    my ($config, $mq, $tmpdir) = TestHelper::setup();
    $config->set_started(0);
    $config->parameter('api_port', 7070);
    $config->parameter('imap_hostname', 'mail.example.com');
    $config->parameter('imap_login', 'alice');
    $config->set_started(1);
    $config->set_save_needed(1);
    $config->set_config_format('legacy');
    $config->_save_legacy();

    ok(-e "$tmpdir/popfile.cfg", 'legacy cfg file written');
    ok(!-e "$tmpdir/popfile.json", 'no json yet');

    $config->load_configuration();

    ok(!-e "$tmpdir/popfile.cfg", 'legacy cfg moved aside');
    ok(-e "$tmpdir/popfile.cfg.bak", 'backup exists');
    ok(-e "$tmpdir/popfile.json", 'json created');
    is($config->parameter('api_port'), 7070, 'api_port restored from migration');
    is($config->parameter('imap_hostname'), 'mail.example.com', 'hostname restored');
};

subtest 'encrypted values survive legacy → JSON migration' => sub {
    my ($config, $mq, $tmpdir) = TestHelper::setup();
    $config->set_started(0);
    $config->parameter('imap_password', '');
    $config->set_started(1);
    $config->parameter('imap_password', 's3cret');
    $config->set_save_needed(1);
    $config->set_config_format('legacy');
    $config->_save_legacy();

    my $cfg_content = do { open my $fh, '<', "$tmpdir/popfile.cfg"; local $/; <$fh> };
    like($cfg_content, qr/^imap_password ENC:/m, 'password encrypted on disk');

    $config->load_configuration();
    is($config->parameter('imap_password'), 's3cret', 'password decrypted after migration');
};

subtest 'existing popfile.json is loaded directly (no migration)' => sub {
    my ($config, $mq, $tmpdir) = TestHelper::setup();
    $config->set_started(0);
    $config->parameter('api_port', 8080);
    $config->set_started(1);
    $config->set_config_format('json');
    $config->_save_json();

    $config->parameter('api_port', 0);  # change in-memory
    $config->load_configuration();
    is($config->parameter('api_port'), 8080, 'loaded from existing json');
};

subtest 'JSON config survives save/load round-trip' => sub {
    my ($config, $mq, $tmpdir) = TestHelper::setup();
    $config->set_started(0);
    $config->parameter('api_port', 9090);
    $config->parameter('imap_hostname', 'mx.test');
    $config->set_started(1);
    $config->set_config_format('json');
    $config->_save_json();

    $config->parameter('api_port', 0);
    $config->load_configuration();
    is($config->parameter('api_port'), 9090, 'value restored from json');
    is($config->parameter('imap_hostname'), 'mx.test', 'hostname restored');
};

done_testing;
