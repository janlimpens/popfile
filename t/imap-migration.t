#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

subtest 'legacy watched_folders config string migrates to DB' => sub {
    my ($config, $mq) = TestHelper::setup();
    TestHelper::configure_db($config);
    # Set legacy config values
    $config->set_started(0);
    $config->parameter('imap_watched_folders', 'INBOX-->Spam-->Ham-->');
    $config->parameter('imap_bucket_folder_mappings', 'spam-->Junk-->work-->Work-->');
    $config->set_started(1);

    require Services::IMAP;
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->_ensure_folder_tables();
    $imap->_migrate_folder_config();

    my @watched = $imap->watched_folders();
    is(scalar @watched, 3, 'three watched folders migrated');
    ok((grep { $_ eq 'Spam' } @watched) > 0, 'Spam migrated');
    ok((grep { $_ eq 'Ham' } @watched) > 0, 'Ham migrated');

    is($imap->folder_for_bucket('spam'), 'Junk', 'spam→Junk migrated');
    is($imap->folder_for_bucket('work'), 'Work', 'work→Work migrated');
};

subtest 'migration is idempotent' => sub {
    my ($config, $mq) = TestHelper::setup();
    TestHelper::configure_db($config);
    $config->set_started(0);
    $config->parameter('imap_watched_folders', 'INBOX-->Only-->');
    $config->set_started(1);

    require Services::IMAP;
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->_ensure_folder_tables();
    $imap->_migrate_folder_config();

    my @first = $imap->watched_folders();
    is(scalar @first, 2, 'first migration: two folders');

    # Second migration should be a no-op
    $imap->_migrate_folder_config();
    my @second = $imap->watched_folders();
    is(scalar @second, 2, 'second migration: still two folders');
};

subtest 'empty legacy config does not break migration' => sub {
    my ($config, $mq) = TestHelper::setup();
    TestHelper::configure_db($config);

    require Services::IMAP;
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->_ensure_folder_tables();
    $imap->_migrate_folder_config();

    ok(1, 'migration completes without config keys');
};

done_testing;
