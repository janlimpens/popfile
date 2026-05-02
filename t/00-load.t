#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use feature 'try';

# Smoke test: verify all core modules can be loaded without errors.
# This catches syntax errors and missing dependencies early.

my @modules = qw(
    POPFile::Features
    POPFile::Module
    POPFile::Configuration
    POPFile::Logger
    POPFile::MQ
    POPFile::Mutex
    POPFile::History
    Classifier::WordMangle
    Classifier::MailParse
    Classifier::Bayes
    Proxy::Proxy
    Proxy::POP3
    Proxy::SMTP
    Proxy::NNTP
    POPFile::API
    POPFile::Role::DBConnect
    Services::Classifier
    POPFile::Loader
);

for my $module (@modules) {
    (my $file = $module) =~ s{::}{/}g;
    my $error;
    my $loaded = do { try { require "$file.pm"; 1 }
        catch ($e) { $error = $e; 0 } };
    ok($loaded, "loaded $module")
        or diag $error;
}

done_testing;
