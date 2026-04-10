#!/usr/bin/env perl
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens

my $packing_list = defined($ENV{POPFILE_ROOT})?$ENV{POPFILE_ROOT}:'./';
$packing_list =~ s/[\\\/]$//;
$packing_list .= '/popfile.pck';

my $fatal = 0;
my @log;

if (open PACKING, "<$packing_list") {
    while (<PACKING>) {
        if (/^(REQUIRED|OPTIONAL-([^\t]+))\t([^\t]+)\t([^\r\n]+)/) {
            my ($required, $why, $version, $module) = ($1, $2, $3, $4);

            # Find the module and set $ver to the loaded version, or -1 if
            # the module was not found

            local $::SIG{__DIE__};
            local $::SIG{__WARN__};
            eval "require $module";
            my $ver = ${"${module}::VERSION"} || ${"${module}::VERSION"} || 0;
            $ver = ${"${module}::VERSION"} || ${"${module}::VERSION"} || 0;
            $ver = -1 if $@;

            if ($ver == -1) {
                if ($required eq 'REQUIRED') {
                    $fatal = 1;
                    print STDERR "ERROR: POPFile needs Perl module $module, please install it.\n";
                } else {
                    push @log, ("Warning: POPFile may require Perl module $module; it is needed only for \"$why\".");
                }
            }
        }
    }
    close PACKING;
} else {
    push @log, ("Warning: Couldn't open POPFile packing list ($packing_list) so cannot check configuration (this probably doesn't matter)");
}

use strict;
use locale;
use lib defined($ENV{POPFILE_ROOT}) ? $ENV{POPFILE_ROOT} : '.';
use lib (defined($ENV{POPFILE_ROOT}) ? $ENV{POPFILE_ROOT} : '.') . '/vendor/perl-querybuilder/lib';
use POPFile::Loader;

# POPFile is actually loaded by the POPFile::Loader object which does all
# the work

my $POPFile = POPFile::Loader->new();

# Indicate that we should create output on STDOUT (the POPFile
# load sequence) and initialize with the version

$POPFile->debug(1);
$POPFile->CORE_loader_init();

# Redefine POPFile's signals

$POPFile->CORE_signals();

# Create the main objects that form the core of POPFile.  Consists of
# the configuration modules, the classifier, the UI (currently HTML
# based), platform specific code, and the POP3 proxy.  The link the
# components together, intialize them all, load the configuration from
# disk, start the modules running

$POPFile->CORE_load();
$POPFile->CORE_link_components();
$POPFile->CORE_initialize();
print "POPFile " . $POPFile->CORE_version() . "\n";
if ($POPFile->CORE_config()) {
    $POPFile->CORE_start();

    my $ui = $POPFile->get_module('mojo_ui', 'interface');
    print "POPFile UI: http://localhost:" . $ui->config('port') . "/\n"
        if defined $ui;

    # If there were any log messages from the packing list check then
    # log them now

    if (@log) {
        foreach my $m (@log) {
            $POPFile->get_module('POPFile::Logger')->debug(0, $m);
        }
    }

    $POPFile->get_module('POPFile::Logger')->debug(0, "POPFile successfully started");

    # This is the main POPFile loop that services requests, it will
    # exit only when we need to exit

    $POPFile->CORE_service();

    # Shutdown every POPFile module

    $POPFile->CORE_stop();
}

# END
