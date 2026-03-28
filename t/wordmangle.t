#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();

# WordMangle::start() only calls load_stopwords() which gracefully
# fails if the stopwords file is absent; no PID or DB setup needed.
my $wm = TestHelper::make_module('Classifier::WordMangle', $config, $mq);
$wm->start();

subtest 'basic normalisation' => sub {
    is( $wm->mangle('Hello'),     'hello',     'lowercases' );
    is( $wm->mangle('WORLD'),     'world',     'lowercases all-caps' );
    is( $wm->mangle('MixedCase'), 'mixedcase', 'lowercases mixed case' );
    is( $wm->mangle(''),          '',          'empty string stays empty' );
};

subtest 'regex metachar replacement' => sub {
    is( $wm->mangle('a+b'),   'a.b', 'replaces +' );
    is( $wm->mangle('a/b'),   'a.b', 'replaces /' );
    is( $wm->mangle('a?b'),   'a.b', 'replaces ?' );
    is( $wm->mangle('a*b'),   'a.b', 'replaces *' );
    is( $wm->mangle('a|b'),   'a.b', 'replaces |' );
    is( $wm->mangle('a(b'),   'a.b', 'replaces (' );
    is( $wm->mangle('a)b'),   'a.b', 'replaces )' );
    is( $wm->mangle('a[b'),   'a.b', 'replaces [' );
    is( $wm->mangle('a]b'),   'a.b', 'replaces ]' );
    is( $wm->mangle('a{b'),   'a.b', 'replaces {' );
    is( $wm->mangle('a}b'),   'a.b', 'replaces }' );
    is( $wm->mangle('a^b'),   'a.b', 'replaces ^' );
    is( $wm->mangle('a$b'),   'a.b', 'replaces $' );
    is( $wm->mangle('a.b'),   'a.b', 'replaces .' );
    is( $wm->mangle('a\\b'),  'a.b', 'replaces \\' );
};

subtest 'long word filter' => sub {
    # Use 'z' – not a hex digit, so only the length filter applies
    my $long_44 = 'z' x 44;
    my $long_45 = 'z' x 45;
    my $long_46 = 'z' x 46;

    is( $wm->mangle($long_44), $long_44, '44-char word passes' );
    is( $wm->mangle($long_45), $long_45, '45-char word passes (boundary)' );
    is( $wm->mangle($long_46), '',       '46-char word filtered out' );
};

subtest 'hex number filter' => sub {
    is( $wm->mangle('DEADBEE'),  'deadbee',  '7-char hex passes' );
    is( $wm->mangle('DEADBEEF'), '',          '8-char hex filtered' );
    is( $wm->mangle('DEADBEEF12'), '',        '10-char hex filtered' );
    is( $wm->mangle('DEADBEEZ'),  'deadbeez', '8-char non-pure-hex passes' );
};

subtest 'colon handling' => sub {
    is( $wm->mangle('hello:world'),     'helloworld', 'colon stripped by default' );
    is( $wm->mangle('hello:world', 1),  'hello:world', 'colon kept with allow_colon' );
    is( $wm->mangle('from:alice', 1),   'from:alice',  'pseudoword kept with allow_colon' );
};

subtest 'stopwords' => sub {
    $wm->add_stopword('the', '');
    $wm->add_stopword('and', '');

    is( $wm->mangle('the'), '', 'stopword filtered' );
    is( $wm->mangle('and'),            '',      'stopword filtered' );
    is( $wm->mangle('hello'),          'hello', 'non-stopword passes' );
    is( $wm->mangle('the', undef, 1), 'the',   'stopword bypassed with ignore_stops' );

    $wm->remove_stopword('the', '');
    $wm->remove_stopword('and', '');
};

subtest 'add_stopword / remove_stopword' => sub {
    is( $wm->add_stopword('badword', ''),   1, 'add_stopword returns 1 on success' );
    is( $wm->mangle('badword'), '', 'newly added stopword is filtered' );
    is( $wm->remove_stopword('badword', ''), 1, 'remove_stopword returns 1 on success' );
    is( $wm->mangle('badword'), 'badword', 'removed stopword no longer filtered' );

    is( $wm->add_stopword('bad word!', ''), 0, 'invalid stopword rejected' );
};

subtest 'stemming' => sub {
    $wm->config('stemming', 1);
    $wm->set_language('en');

    is( $wm->mangle('running'), 'run',       'English stem: running -> run' );
    is( $wm->mangle('runs'),    'run',       'English stem: runs -> run' );
    is( $wm->mangle('dogs'),    'dog',       'English stem: dogs -> dog' );
    is( $wm->mangle('from:alice', 1), 'from:alice', 'pseudoword with colon not stemmed' );

    $wm->config('stemming', 0);
    $wm->set_language('en');
};

subtest 'lingua stopwords' => sub {
    $wm->set_language('en');

    is( $wm->mangle('the'),   '', '"the" filtered as lingua stopword' );
    is( $wm->mangle('hello'), 'hello', 'non-stopword still passes' );
};

subtest 'german stemming and stopwords' => sub {
    $wm->config('stemming', 1);
    $wm->set_language('de');

    is( $wm->get_language(), 'de', 'language set to de' );
    isnt( $wm->mangle('und'), 'und', '"und" filtered as German stopword' );
    is( $wm->mangle('und'), '', '"und" is empty after filtering' );

    $wm->config('stemming', 0);
    $wm->set_language('en');
};

subtest 'set_language survives repeat calls' => sub {
    my $lang_before = $wm->get_language();
    $wm->set_language($lang_before);
    is( $wm->get_language(), $lang_before, 'language unchanged after re-set' );
};

done_testing;
