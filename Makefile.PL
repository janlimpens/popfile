#! /usr/bin/env perl
use v5.38;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'POPFile',
    VERSION          => '1.1.3',
    ABSTRACT         => 'POPFile email classifier',
    AUTHOR           => 'Jan Limpens <jan@limpens.com>',
    MIN_PERL_VERSION => '5.038',

    PREREQ_PM => {
        'DBI'              => '1.643',
        'DBD::SQLite'      => '1.00',
        'Date::Format'     => 0,
        'Date::Parse'      => 0,
        'Digest::MD5'      => 0,
        'HTML::Tagset'     => 0,
        'HTML::Template'   => 0,
        'MIME::Base64'     => 0,
        'MIME::QuotedPrint' => 0,
        'Object::Pad'      => '0.800',
        'Sort::Key::Natural' => 0,
    },

    TEST_REQUIRES => {
        'Test2::V0' => 0,
    },

    # EXE_FILES => ['./popfile.pl'],
);
