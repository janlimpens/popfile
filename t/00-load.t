#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..";

use Test2::V0;

# Smoke test: verify all core modules can be loaded without errors.
# This catches syntax errors and missing dependencies early.

my @modules = qw(
    POPFile::Module
    POPFile::Configuration
    POPFile::Logger
    POPFile::MQ
    POPFile::Mutex
    POPFile::History
    POPFile::API
    Classifier::WordMangle
    Classifier::MailParse
    Classifier::Bayes
    Proxy::Proxy
    Proxy::POP3
    Proxy::SMTP
    Proxy::NNTP
    UI::Mojo
    Services::Classifier
    POPFile::Loader
);

for my $module (@modules) {
    (my $file = $module) =~ s{::}{/}g;
    ok( eval { require "$file.pm"; 1 }, "loaded $module" )
        or diag $@;
}

done_testing;
