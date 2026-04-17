#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use File::Temp qw(tempfile);

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

my $session = $bayes->get_session_key('admin', '');
ok(defined $session && $session ne '', 'session obtained');

# -----------------------------------------------------------------------
subtest 'create buckets' => sub {
    is($bayes->create_bucket($session, 'spam'), 1, 'spam bucket created');
    is($bayes->create_bucket($session, 'ham'),  1, 'ham bucket created');
    my @all = $bayes->get_all_buckets($session);
    ok((grep { $_ eq 'spam' } @all), 'spam present in get_all_buckets');
    ok((grep { $_ eq 'ham'  } @all), 'ham present in get_all_buckets');
};

# -----------------------------------------------------------------------
subtest 'training and classification' => sub {
    my ($spam_fh, $spam_file) = tempfile(DIR => $tmpdir, SUFFIX => '.eml');
    print $spam_fh "From: attacker\@evil.com\r\nSubject: buy now cheap pills\r\n\r\nbuy cheap pills now viagra cialis\r\n";
    close $spam_fh;

    my ($ham_fh, $ham_file) = tempfile(DIR => $tmpdir, SUFFIX => '.eml');
    print $ham_fh "From: friend\@example.com\r\nSubject: lunch today\r\n\r\nhello how are you lunch meeting today\r\n";
    close $ham_fh;

    $bayes->add_message_to_bucket($session, 'spam', $spam_file)
        for 1..10;
    $bayes->add_message_to_bucket($session, 'ham', $ham_file)
        for 1..10;

    ok($bayes->get_bucket_word_count($session, 'spam') > 0, 'spam has words after training');
    ok($bayes->get_bucket_word_count($session, 'ham')  > 0, 'ham has words after training');

    my $result = $bayes->classify($session, $spam_file);
    is($result, 'spam', 'spam message classified as spam');
};

# -----------------------------------------------------------------------
$bayes->release_session_key($session);

my $stopped = eval { $bayes->stop(); 1 };
ok($stopped, 'bayes stop completes without error');

done_testing;
