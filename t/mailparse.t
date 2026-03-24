#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;
use TestHelper;
use FindBin qw($Bin);

my ($config, $logger, $mq, $tmpdir) = TestHelper::setup();

# MailParse requires WordMangle to be injected via mangle()
my $wm = TestHelper::make_module('Classifier::WordMangle', $config, $logger, $mq);
$wm->start();

# MailParse itself does not extend POPFile::Module and has no configuration
# dependency – it's a plain object with parse_file() as entry point.
require Classifier::MailParse;
my $mp = Classifier::MailParse->new();
$mp->mangle($wm);

my $fixture_dir = "$Bin/fixtures";

# -----------------------------------------------------------------------
subtest 'parse ham email' => sub {
    $mp->parse_file("$fixture_dir/ham.eml");

    my %words = %{ $mp->{words__} };
    ok( scalar keys %words > 0, 'extracted some words from ham.eml' );

    # The ham fixture contains "meeting", "budget", "project", "report"
    ok( exists $words{meeting},  'found "meeting"' );
    ok( exists $words{budget},   'found "budget"' );
    ok( exists $words{project},  'found "project"' );
    ok( exists $words{report},   'found "report"' );

    # Header pseudowords should be present
    my @header_words = grep { /^from:|^to:|^subject:/ } keys %words;
    ok( @header_words > 0, 'header pseudowords extracted' );
};

# -----------------------------------------------------------------------
subtest 'parse spam email' => sub {
    $mp->parse_file("$fixture_dir/spam.eml");

    my %words = %{ $mp->{words__} };
    ok( scalar keys %words > 0, 'extracted some words from spam.eml' );

    # The spam fixture contains "prize", "free", "offer", "click"
    ok( exists $words{prize},         'found "prize"' );
    ok( exists $words{free},          'found "free"' );
    ok( exists $words{offer},         'found "offer"' );
    ok( exists $words{congratulations}, 'found "congratulations"' );
};

# -----------------------------------------------------------------------
subtest 'word counts are positive integers' => sub {
    $mp->parse_file("$fixture_dir/ham.eml");
    my %words = %{ $mp->{words__} };

    for my $word (keys %words) {
        ok( $words{$word} > 0, "count for '$word' is positive" );
    }
};

# -----------------------------------------------------------------------
subtest 'repeated parse resets word list' => sub {
    $mp->parse_file("$fixture_dir/spam.eml");
    my $spam_words = scalar keys %{ $mp->{words__} };

    $mp->parse_file("$fixture_dir/ham.eml");
    my %ham_words = %{ $mp->{words__} };

    # "prize" is in spam but not in ham
    ok( !exists $ham_words{prize}, 'word list reset between parses: "prize" absent after ham parse' );
};

# -----------------------------------------------------------------------
subtest 'header extraction' => sub {
    $mp->parse_file("$fixture_dir/ham.eml");

    like( $mp->get_header('from'),    qr/alice/, 'From header extracted' );
    like( $mp->get_header('to'),      qr/bob/,   'To header extracted' );
    like( $mp->get_header('subject'), qr/Meeting/i, 'Subject header extracted' );
};

done_testing;
