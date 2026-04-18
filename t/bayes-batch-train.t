#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;
use Path::Tiny;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);

my $ham_text  = path("$TestHelper::REPO_ROOT/t/fixtures/ham.eml")->slurp;
my $spam_text = path("$TestHelper::REPO_ROOT/t/fixtures/spam.eml")->slurp;

subtest 'train_messages_batch produces same word counts as individual add_message_to_bucket' => sub {
    my $session_a = $bayes->get_session_key('admin', '');
    $bayes->create_bucket($session_a, 'inbox');
    $bayes->create_bucket($session_a, 'spam');

    $bayes->add_message_to_bucket($session_a, 'inbox', "$TestHelper::REPO_ROOT/t/fixtures/ham.eml")
        for 1 .. 3;
    $bayes->add_message_to_bucket($session_a, 'spam', "$TestHelper::REPO_ROOT/t/fixtures/spam.eml")
        for 1 .. 3;

    my $ham_count_individual  = $bayes->get_bucket_word_count($session_a, 'inbox');
    my $spam_count_individual = $bayes->get_bucket_word_count($session_a, 'spam');

    $bayes->release_session_key($session_a);

    my $session_b = TestHelper::reset_db($bayes, $config);
    $bayes->create_bucket($session_b, 'inbox');
    $bayes->create_bucket($session_b, 'spam');

    $bayes->train_messages_batch($session_b, 'inbox', [($ham_text)  x 3]);
    $bayes->train_messages_batch($session_b, 'spam',  [($spam_text) x 3]);

    my $ham_count_batch  = $bayes->get_bucket_word_count($session_b, 'inbox');
    my $spam_count_batch = $bayes->get_bucket_word_count($session_b, 'spam');

    is($ham_count_batch,  $ham_count_individual,  'inbox word count matches individual training');
    is($spam_count_batch, $spam_count_individual, 'spam word count matches individual training');

    $bayes->release_session_key($session_b);
};

subtest 'train_messages_batch with empty list is a no-op' => sub {
    my $session = $bayes->get_session_key('admin', '');
    my $before = $bayes->get_bucket_word_count($session, 'inbox');
    my $result = $bayes->train_messages_batch($session, 'inbox', []);
    my $after  = $bayes->get_bucket_word_count($session, 'inbox');
    is($after, $before, 'word count unchanged for empty batch');
    $bayes->release_session_key($session);
};

subtest 'train_messages_batch returns 0 for unknown bucket' => sub {
    my $session = $bayes->get_session_key('admin', '');
    my $result = $bayes->train_messages_batch($session, 'no-such-bucket', [$ham_text]);
    is($result, 0, 'returns 0 for unknown bucket');
    $bayes->release_session_key($session);
};

$bayes->stop();

done_testing;
