#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use POPFile::Config;

sub make_imap {
    my ($config, $mq) = TestHelper::setup();
    TestHelper::configure_db($config);
    require Services::IMAP;
    my $imap = Services::IMAP->new();
    TestHelper::wire($imap, $config, $mq);
    $imap->initialize();
    $imap->start();
    $imap->watched_folders('INBOX');
    return ($imap, $config)
}

subtest 'CRUD for watched folders' => sub {
    my ($imap) = make_imap();
    my @initial = $imap->watched_folders();
    ok(@initial >= 1, 'has at least INBOX');

    $imap->watched_folders('INBOX', 'Spam', 'Ham');
    my @updated = $imap->watched_folders();
    is(scalar @updated, 3, 'three folders set');
    is($updated[0], 'INBOX', 'first is INBOX');
    is($updated[1], 'Spam', 'second is Spam');
};

subtest 'CRUD for bucket-folder mappings' => sub {
    my ($imap) = make_imap();
    is($imap->folder_for_bucket('spam'), undef, 'no mapping yet');

    $imap->folder_for_bucket('spam', 'Junk');
    is($imap->folder_for_bucket('spam'), 'Junk', 'bucket mapped to Junk');

    my ($imap2, $cfg2) = make_imap();
    is($imap2->folder_for_bucket('spam'), undef, 'separate instance with own DB has no mapping');

    $imap->folder_for_bucket('spam', 'SpamNew');
    is($imap->folder_for_bucket('spam'), 'SpamNew', 'mapping updated via upsert');
};

subtest 'mappings survive across separate IMAP instances' => sub {
    my ($imap, $config) = make_imap();
    $imap->folder_for_bucket('work', 'WorkFolder');
    $imap->watched_folders('INBOX', 'WorkFolder');

    my $imap2 = Services::IMAP->new();
    TestHelper::wire($imap2, $config, undef);
    $imap2->initialize();
    $imap2->start();
    is($imap2->folder_for_bucket('work'), 'WorkFolder', 'mapping persists');
    my @w = $imap2->watched_folders();
    ok((grep { $_ eq 'WorkFolder' } @w) > 0, 'watched folder persists');
};

done_testing;
