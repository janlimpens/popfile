#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use File::Temp qw(tempfile tempdir);

my ($config, $mq, $tmpdir) = TestHelper::setup();

subtest 'parameter get/set' => sub {
    # Register a new parameter with a default value
    $config->set_started(0);
    $config->parameter('test_mymodule_port', 8080);
    $config->set_started(1);

    is( $config->parameter('test_mymodule_port'), 8080, 'reads back registered param' );

    $config->parameter('test_mymodule_port', 9090);
    is( $config->parameter('test_mymodule_port'), 9090, 'update param' );

    is( $config->parameter('nonexistent_param'), undef, 'undef for unknown param' );
};

subtest 'is_default' => sub {
    $config->set_started(0);
    $config->parameter('test_default_check', 'initial');
    $config->set_started(1);

    ok(  $config->is_default('test_default_check'), 'param at default' );
    $config->parameter('test_default_check', 'changed');
    ok( !$config->is_default('test_default_check'), 'param no longer at default after change' );
};

subtest 'save and load configuration' => sub {
    # Set a value and save
    $config->set_started(0);
    $config->parameter('savetest_module_key', 'original_value');
    $config->set_started(1);
    $config->parameter('savetest_module_key', 'saved_value');
    $config->set_save_needed(1);
    $config->save_configuration();

    my $cfg_file = "$tmpdir/popfile.cfg";
    ok( -e $cfg_file, 'popfile.cfg was written' );

    # Check the file contains the key
    open my $fh, '<', $cfg_file or die "Can't read $cfg_file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    like( $content, qr/savetest_module_key saved_value/, 'saved value in config file' );

    # Change the in-memory value, then reload from disk
    $config->parameter('savetest_module_key', 'different');
    is( $config->parameter('savetest_module_key'), 'different', 'in-memory changed' );

    $config->load_configuration();
    is( $config->parameter('savetest_module_key'), 'saved_value',
        'value restored from disk after load_configuration' );
};

subtest 'dirty flag' => sub {
    $config->set_save_needed(0);
    $config->parameter('savetest_module_key', 'trigger_dirty');
    is( $config->save_needed(), 1, 'dirty flag set after parameter change' );

    $config->set_save_needed(1);
    $config->save_configuration();
    is( $config->save_needed(), 0, 'dirty flag cleared after save' );
};

subtest 'path sandbox' => sub {
    is( $config->get_user_path('subdir/file.txt'), "$tmpdir/subdir/file.txt",
        'relative path resolved correctly' );

    is( $config->get_user_path('../escape.txt'), undef,
        'path traversal blocked in sandbox' );

    is( $config->get_user_path('/etc/passwd'), undef,
        'absolute path blocked in sandbox' );
};

subtest 'get_user_path and get_root_path' => sub {
    my $user_path = $config->get_user_path('test.db');
    is( $user_path, "$tmpdir/test.db", 'get_user_path resolves to tmpdir' );

    my $root_path = $config->get_root_path('Classifier/popfile.sql');
    is( $root_path, "$TestHelper::REPO_ROOT/Classifier/popfile.sql",
        'get_root_path resolves to repo root' );

    ok( -e $root_path, 'resolved root path actually exists' );
};

subtest 'sensitive config values are encrypted at rest' => sub {
    my ($config_local, $mq_local, $tmpdir_local) = TestHelper::setup();
    $config_local->set_started(0);
    $config_local->parameter('api_password', '');
    $config_local->parameter('imap_password', 's3cret');
    $config_local->parameter('imap_hostname', 'mail.example.com');
    $config_local->parameter('imap_login', 'alice');
    $config_local->set_started(1);
    $config_local->set_save_needed(1);
    $config_local->save_configuration();

    my $cfg_file = "$tmpdir_local/popfile.cfg";
    ok(-f $cfg_file, 'config file written');
    open my $fh, '<', $cfg_file;
    my %on_disk;
    while (<$fh>) { chomp; my ($k, $v) = split / /, $_, 2; $on_disk{$k} = $v }
    close $fh;

    ok($on_disk{imap_password} =~ /^ENC:/, 'password encrypted on disk');
    is($on_disk{imap_hostname}, 'mail.example.com', 'hostname plaintext on disk');
    is($on_disk{imap_login}, 'alice', 'login plaintext on disk');

    my $config2 = POPFile::Configuration->new();
    $config2->set_configuration($config2);
    $config2->set_mq($mq_local);
    $config2->set_popfile_root($TestHelper::REPO_ROOT);
    $config2->set_popfile_user($tmpdir_local);
    $config2->set_started(0);
    $config2->parameter('imap_password', '');
    $config2->parameter('imap_hostname', '');
    $config2->parameter('imap_login', '');
    $config2->set_started(1);
    $config2->load_configuration();
    is($config2->parameter('imap_password'), 's3cret', 'password decrypted correctly');
    is($config2->parameter('imap_hostname'), 'mail.example.com', 'hostname intact');
};

done_testing;
