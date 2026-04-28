#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);
my $session = $bayes->get_session_key('admin', '');

TestHelper::load_fixture($bayes, $session, {
    buckets => [qw(spam ham)],
    train => {
        spam => ['spam.eml'],
        ham => ['ham.eml'],
    },
});

subtest 'returns bucket list' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '');
    is ref $result->{buckets}, 'ARRAY', 'buckets is arrayref';
    my %bset = map { $_ => 1 } $result->{buckets}->@*;
    ok $bset{spam}, 'spam in bucket list';
    ok $bset{ham}, 'ham in bucket list';
};

subtest 'prefix filter works' => sub {
    my $result = $bayes->search_words_cross_bucket($session, 'zzz_no_match_xyz');
    is $result->{total}, 0, 'no results for unmatched prefix';
    is scalar $result->{words}->@*, 0, 'empty word list';
};

subtest 'result structure' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', per_page => 5);
    ok $result->{total} > 0, 'total > 0 after training';
    my $first = $result->{words}[0];
    ok defined $first->{word}, 'word key present';
    ok defined $first->{coverage}, 'coverage key present';
    ok defined $first->{is_stopword}, 'is_stopword key present';
    ok ref $first->{buckets} eq 'HASH', 'buckets hash present';
    ok exists $first->{buckets}{spam}, 'spam key in buckets hash';
    ok exists $first->{buckets}{ham}, 'ham key in buckets hash';
};

subtest 'sort by word asc' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', sort => 'word', dir => 'asc', per_page => 100);
    my @words = map { $_->{word} } $result->{words}->@*;
    my @sorted = sort @words;
    is \@words, \@sorted, 'words sorted alphabetically';
};

subtest 'sort by coverage' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', sort => 'coverage', dir => 'desc', per_page => 50);
    my @covs = map { $_->{coverage} } $result->{words}->@*;
    my @sorted = sort { $b <=> $a } @covs;
    is \@covs, \@sorted, 'words sorted by coverage descending';
};

subtest 'sort by bucket name' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', sort => 'spam', dir => 'desc', per_page => 50);
    my @counts = map { $_->{buckets}{spam} } $result->{words}->@*;
    my @sorted = sort { $b <=> $a } @counts;
    is \@counts, \@sorted, 'words sorted by spam count descending';
};

subtest 'sort by unknown bucket falls back gracefully' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', sort => 'no_such_bucket', dir => 'desc');
    ok ref $result->{words} eq 'ARRAY', 'returns array even with unknown sort';
};

subtest 'is_stopword flag' => sub {
    my @some_words = map { $_->{word} } $bayes->search_words_cross_bucket($session, '', per_page => 5)->{words}->@*;
    my $word = $some_words[0];
    $bayes->add_stopword($session, $word);
    my $result = $bayes->search_words_cross_bucket($session, $word);
    my ($row) = grep { $_->{word} eq $word } $result->{words}->@*;
    ok $row && $row->{is_stopword}, 'stopword flagged correctly';
    $bayes->remove_stopword($session, $word);
};

subtest 'pagination' => sub {
    my $p1 = $bayes->search_words_cross_bucket($session, '', page => 1, per_page => 3);
    my $p2 = $bayes->search_words_cross_bucket($session, '', page => 2, per_page => 3);
    ok $p1->{total} == $p2->{total}, 'total consistent across pages';
    my %p1_words = map { $_->{word} => 1 } $p1->{words}->@*;
    my @overlap = grep { $p1_words{$_->{word}} } $p2->{words}->@*;
    is scalar @overlap, 0, 'no word appears on both pages';
};

done_testing;
