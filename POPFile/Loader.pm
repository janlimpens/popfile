package POPFile::Loader;

#----------------------------------------------------------------------------
#
# Loader.pm --- API for loading POPFile loadable modules and
# encapsulating POPFile application tasks
#
# Subroutine names beginning with CORE indicate a subroutine designed
# for exclusive use of POPFile's core application (popfile.pl).
#
# Subroutines not so marked are suitable for use by POPFile-based
# utilities to assist in loading and executing modules
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#   POPFile is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with POPFile; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#   Created by     Sam Schinke (sschinke@users.sourceforge.net)
#
#----------------------------------------------------------------------------

use Object::Pad;
use locale;

use Getopt::Long qw(:config pass_through);
use IO::Handle;
use Log::Any ();

class POPFile::Loader {
    # The POPFile classes are stored by reference in the components hash;
    # the top level key is the component type, the second key is its name.
    field %components;

    # When set to 1 the proxy works normally; 0 means graceful shutdown.
    field $alive = 1;

    # Must be 1 for POPFile::Loader to create any output on STDOUT.
    field $debug = 1;

    # If 1, POPFile shuts down immediately after starting.
    field $shutdown = 0;

    # Callback refs populated in CORE_loader_init.
    field $aborting = '';
    field $pipeready = '';
    field $forker = '';
    field $reaper = '';
    field $childexit = '';
    field $warning = '';
    field $die_cb = '';

    # POPFile version
    field $major_version = '?';
    field $minor_version = '?';
    field $build_version = '?';
    field $version_string = '';

    # Where POPFile is installed
    field $popfile_root = './';

    #------------------------------------------------------------------------
    # CORE_loader_init
    #
    # Initialize things only needed in CORE
    #------------------------------------------------------------------------
    method CORE_loader_init {
        if ( defined $ENV{POPFILE_ROOT} ) {
            $popfile_root = $ENV{POPFILE_ROOT};
        }

        # These anonymous subroutine references allow us to call these
        # important functions from anywhere using the reference, granting
        # internal access to $self without exposing $self to the caller.

        $aborting  = sub { $self->CORE_aborting(@_) };
        $pipeready = sub { $self->pipeready(@_) };
        $forker    = sub { $self->CORE_forker(@_) };
        $reaper    = sub { $self->CORE_reaper(@_) };
        $childexit = sub { $self->CORE_childexit(@_) };
        $warning   = sub { $self->CORE_warning(@_) };
        $die_cb       = sub { $self->CORE_die(@_) };

        my $version_file = $self->root_path( 'POPFile/popfile_version' );

        if ( -e $version_file ) {
            open my $ver, '<', $version_file;
            my $major = int(<$ver>);
            my $minor = int(<$ver>);
            my $rev   = int(<$ver>);
            close $ver;
            $self->CORE_version( $major, $minor, $rev );
        }

        GetOptions( 'shutdown' => \$shutdown );

        print "\nPOPFile Engine loading\n" if $debug;
    }

    #------------------------------------------------------------------------
    # CORE_aborting
    #
    # Called if we are going to be aborted.  Sets alive to 0 so that we
    # abort at the next convenient moment.
    #------------------------------------------------------------------------
    method CORE_aborting {
        $alive = 0;
        foreach my $type (sort keys %components) {
            foreach my $name (sort keys %{$components{$type}}) {
                $components{$type}{$name}->set_alive(0);
            }
        }
    }

    #------------------------------------------------------------------------
    # pipeready
    #
    # Returns 1 if data is available to be read on the passed-in pipe handle.
    #------------------------------------------------------------------------
    method pipeready ($pipe) {
        return 0 if !defined $pipe;

        my $rin = '';
        vec( $rin, fileno($pipe), 1 ) = 1;
        my $ready = select( $rin, undef, undef, 0.01 );
        return ( $ready > 0 );
    }

    #------------------------------------------------------------------------
    # CORE_reaper
    #
    # Called on SIGCHLD; asks each module to do whatever reaping is needed.
    #------------------------------------------------------------------------
    method CORE_reaper {
        foreach my $type (sort keys %components) {
            foreach my $name (sort keys %{$components{$type}}) {
                $components{$type}{$name}->reaper();
            }
        }

        $SIG{CHLD} = $reaper;
    }

    #------------------------------------------------------------------------
    # CORE_childexit
    #
    # Called by a module in a child process that wants to exit.  Warns all
    # other modules in the same process and then exits.
    #------------------------------------------------------------------------
    method CORE_childexit ($code) {
        foreach my $type (sort keys %components) {
            foreach my $name (sort keys %{$components{$type}}) {
                $components{$type}{$name}->childexit();
            }
        }

        exit $code;
    }

    #------------------------------------------------------------------------
    # CORE_forker
    #
    # Called to fork POPFile.  Calls every module's forked function in the
    # child process.  Returns (pid, pipe_handle): pid==0 in child (with
    # writer), non-zero pid in parent (with reader).
    #------------------------------------------------------------------------
    method CORE_forker {
        my @types = sort keys %components;

        foreach my $type (@types) {
            foreach my $name (sort keys %{$components{$type}}) {
                $components{$type}{$name}->prefork();
            }
        }

        pipe my $reader, my $writer;
        my $pid = fork();

        if ( !defined $pid ) {
            close $reader;
            close $writer;
            return (undef, undef);
        }

        if ( $pid == 0 ) {
            foreach my $type (@types) {
                foreach my $name (sort keys %{$components{$type}}) {
                    $components{$type}{$name}->forked($writer);
                }
            }
            close $reader;
            $writer->autoflush(1);
            return (0, $writer);
        }

        foreach my $type (@types) {
            foreach my $name (sort keys %{$components{$type}}) {
                $components{$type}{$name}->postfork($pid, $reader);
            }
        }

        close $writer;
        return ($pid, $reader);
    }

    #------------------------------------------------------------------------
    # CORE_warning
    #
    # Called on a Perl warning; logs it if debug level > 0.
    #------------------------------------------------------------------------
    method CORE_warning (@message) {
        if ( $self->module_config( 'GLOBAL', 'debug' ) > 0 ) {
            Log::Any->get_logger(category => 'POPFile')->warning("Perl warning: @message");
            warn @message;
        }
    }

    #------------------------------------------------------------------------
    # CORE_die
    #
    # Called on a fatal Perl error; logs and tries to stop cleanly.
    #------------------------------------------------------------------------
    method CORE_die (@message) {
        return if $^S;    # inside an eval — do nothing

        print STDERR @message;

        if ( $self->module_config( 'GLOBAL', 'debug' ) > 0 ) {
            Log::Any->get_logger(category => 'POPFile')->error("Perl fatal error: @message");
        }

        $self->CORE_stop();
        exit 1;
    }

    #------------------------------------------------------------------------
    # CORE_load_directory_modules
    #
    # Loads all POPFile Loadable Modules found in a directory.
    #------------------------------------------------------------------------
    method CORE_load_directory_modules ($directory, $type) {
        print "\n         {$type:" if $debug;

        opendir my $dh, $self->root_path($directory);

        while ( my $entry = readdir $dh ) {
            if ( $entry =~ /\.pm$/ ) {
                $self->CORE_load_module( "$directory/$entry", $type );
            }
        }

        closedir $dh;

        print '} ' if $debug;
    }

    #------------------------------------------------------------------------
    # CORE_load_module
    #
    # Loads a single POPFile Loadable Module and adds it to components__.
    # Returns the module handle (undef on failure).
    #------------------------------------------------------------------------
    method CORE_load_module ($module, $type) {
        my $mod = $self->load_module($module);

        if ( defined $mod ) {
            my $name = $mod->name();
            print " $name" if $debug;
            $components{$type}{$name} = $mod;
        }
        return $mod;
    }

    #------------------------------------------------------------------------
    # load_module_
    #
    # Loads a single POPFile Loadable Module.  No internal side-effects.
    # Returns the module handle (undef if not a loadable module).
    #------------------------------------------------------------------------
    method load_module ($module) {
        return undef unless -f $self->root_path($module);
        require $module;
        (my $class = $module) =~ s/\//::/g;
        $class =~ s/\.pm$//;
        my $mod = eval { $class->new() };
        return undef if $@;
        return $mod->DOES('POPFile::Loadable') ? $mod : undef
    }

    #------------------------------------------------------------------------
    # CORE_signals
    #
    # Sets signal handlers so POPFile handles OS and IPC events gracefully.
    #------------------------------------------------------------------------
    method CORE_signals {
        $SIG{QUIT}     = $aborting;
        $SIG{ABRT}     = $aborting;
        $SIG{KILL}     = $aborting;
        $SIG{STOP}     = $aborting;
        $SIG{TERM}     = $aborting;
        $SIG{INT}      = $aborting;
        $SIG{CHLD}     = $reaper;
        $SIG{ALRM}     = 'IGNORE';
        $SIG{PIPE}     = 'IGNORE';
        $SIG{__WARN__} = $warning;
        $SIG{__DIE__}  = $die_cb;

        return $SIG;
    }

    #------------------------------------------------------------------------
    # CORE_load
    #
    # Loads POPFile's modules.
    # $noserver — if 1, skip UI, Proxy, and Services.
    #------------------------------------------------------------------------
    method CORE_load ($noserver = 0) {
        print "\n    Loading... " if $debug;

        $self->CORE_load_directory_modules( 'POPFile',    'core'       );
        $self->CORE_load_directory_modules( 'Classifier', 'classifier' );

        if ( !$noserver ) {
            $self->CORE_load_directory_modules( 'UI',       'interface' );
            $self->CORE_load_directory_modules( 'Proxy',    'proxy'     );
            $self->CORE_load_directory_modules( 'Services', 'services'  );
        }
    }

    #------------------------------------------------------------------------
    # CORE_link_components
    #
    # Links POPFile's modules together so they can use each other as objects.
    #------------------------------------------------------------------------
    method CORE_link_components {
        print "\n\nPOPFile Engine $version_string starting" if $debug;

        # Give every module access to configuration, version, and MQ.

        foreach my $type (sort keys %components) {
            foreach my $name (sort keys %{$components{$type}}) {
                $components{$type}{$name}->set_version(
                    scalar($self->CORE_version()) );
                $components{$type}{$name}->set_configuration(
                    $components{core}{config} );
                $components{$type}{$name}->set_mq(
                    $components{core}{mq} );
            }
        }

        # Inject classifier and history into modules that declare set_classifier / set_history.

        foreach my $type (sort keys %components) {
            foreach my $name (sort keys %{$components{$type}}) {
                my $mod = $components{$type}{$name};
                $mod->set_classifier( $components{classifier}{bayes} )
                    if $mod->can('set_classifier');
                $mod->set_history( $components{core}{history} )
                    if $mod->can('set_history');
            }
        }

        # Wire the classifier service to proxy and interface modules so they
        # can call it instead of reaching into Bayes directly.

        if ( defined $components{services}{classifier_service} ) {
            my $svc = $components{services}{classifier_service};

            foreach my $name (sort keys %{$components{proxy}}) {
                my $mod = $components{proxy}{$name};
                $mod->set_service($svc) if $mod->can('set_service');
            }
            foreach my $name (sort keys %{$components{interface}}) {
                my $mod = $components{interface}{$name};
                $mod->set_service($svc) if $mod->can('set_service');
            }
        }

        # Classifier::Bayes and POPFile::History are friends.

        $components{core}{history}->set_classifier(
            $components{classifier}{bayes} );
        $components{classifier}{bayes}->set_history(
            $components{core}{history} );

        $components{classifier}{bayes}->parser()->set_mangle(
            $components{classifier}{wordmangle} );
    }

    #------------------------------------------------------------------------
    # CORE_initialize
    #
    # Loops across POPFile's modules and initializes them.
    #------------------------------------------------------------------------
    method CORE_initialize {
        print "\n\n    Initializing... " if $debug;

        # Core must be initialized first.
        my @c = ( 'core', grep { !/^core$/ } sort keys %components );

        foreach my $type (@c) {
            print "\n         {$type:" if $debug;
            foreach my $name (sort keys %{$components{$type}}) {
                print " $name" if $debug;
                STDOUT->flush();

                my $mod  = $components{$type}{$name};
                my $code = $mod->initialize();

                if ( $code == 0 ) {
                    die "Failed to start while initializing the $name module";
                }

                if ( $code == 1 ) {
                    $mod->set_alive(1);
                    $mod->set_forker(       $forker    );
                    $mod->setchildexit(     $childexit );
                    $mod->set_pipeready(    $pipeready );
                }
            }
            print '} ' if $debug;
        }
        print "\n" if $debug;
    }

    #------------------------------------------------------------------------
    # CORE_config
    #
    # Loads POPFile's configuration and applies command-line overrides.
    #------------------------------------------------------------------------
    method CORE_config {
        $components{core}{config}->load_configuration();
        return $components{core}{config}->parse_command_line();
    }

    #------------------------------------------------------------------------
    # CORE_start
    #
    # Loops across POPFile's modules and starts them.
    #------------------------------------------------------------------------
    method CORE_start {
        print "\n    Starting...     " if $debug;

        my @c = ( 'core', 'classifier', 'services',
                  grep { !/^(core|classifier|services)$/ } sort keys %components );

        foreach my $type (@c) {
            print "\n         {$type:" if $debug;
            foreach my $name (sort keys %{$components{$type}}) {
                my $code = $components{$type}{$name}->start();

                if ( $code == 0 ) {
                    die "Failed to start while starting the $name module";
                }

                if ( $code == 2 ) {
                    delete $components{$type}{$name};
                } else {
                    print " $name" if $debug;
                    STDOUT->flush();
                }
            }
            print '} ' if $debug;
        }

        print "\n\nPOPFile Engine ", scalar($self->CORE_version()), " running\n"
            if $debug;
        STDOUT->flush();
    }

    #------------------------------------------------------------------------
    # CORE_service
    #
    # The main service loop.  Calls each module's service() method.
    # $nowait — if 1, run once without sleeping and return.
    #------------------------------------------------------------------------
    method CORE_service ($nowait = 0) {
        while ( $alive == 1 ) {
            foreach my $type (sort keys %components) {
                foreach my $name (sort keys %{$components{$type}}) {
                    if ( $components{$type}{$name}->service() == 0 ) {
                        $alive = 0;
                        last;
                    }
                }
            }

            select(undef, undef, undef, 0.05) if !$nowait;

            last if $nowait;

            if ( $shutdown == 1 ) {
                $alive = 0;
            }
        }

        return $alive;
    }

    #------------------------------------------------------------------------
    # CORE_stop
    #
    # Loops across POPFile's modules and stops them.
    #------------------------------------------------------------------------
    method CORE_stop {
        if ( $debug ) {
            print "\n\nPOPFile Engine $version_string stopping\n";
            STDOUT->flush();
            print "\n    Stopping... ";
        }

        # Shut down MQ first so it can flush remaining messages to other
        # modules before they stop.

        $components{core}{mq}->set_alive(0);
        $components{core}{mq}->stop();
        $components{core}{history}->set_alive(0);
        $components{core}{history}->stop();

        foreach my $type (sort keys %components) {
            print "\n         {$type:" if $debug;
            foreach my $name (sort keys %{$components{$type}}) {
                print " $name" if $debug;
                STDOUT->flush();

                next if $name eq 'mq';
                next if $name eq 'history';
                $components{$type}{$name}->set_alive(0);
                $components{$type}{$name}->stop();
            }
            print '} ' if $debug;
        }

        print "\n\nPOPFile Engine $version_string terminated\n"
            if $debug;
    }

    #------------------------------------------------------------------------
    # CORE_version
    #
    # Gets or sets POPFile's version data.
    # Returns string in scalar context, or (major, minor, build) in list.
    #------------------------------------------------------------------------
    method CORE_version ($major_version = undef, $minor_version = undef, $build_version = undef) {
        if ( !defined $major_version ) {
            return wantarray
                ? ($major_version, $minor_version, $build_version)
                : $version_string;
        }

        ($major_version,
         $minor_version,
         $build_version) = ($major_version, $minor_version, $build_version);
        $version_string = "v$major_version.$minor_version.$build_version";
    }

    #------------------------------------------------------------------------
    # get_module
    #
    # Gets a module from the components hash.
    # May be called as get_module('Classifier::Bayes') or
    #                   get_module($name, $type).
    #------------------------------------------------------------------------
    method get_module ($name, $type = undef) {
        if ( !defined($type) && $name =~ /^(.*)::(.*)$/ ) {
            $type = lc $1;
            $name = lc $2;
            $type =~ s/^popfile$/core/i;
            $type =~ s/^ui$/interface/i;
        }

        return $components{$type}{$name};
    }

    #------------------------------------------------------------------------
    # set_module
    #
    # Inserts a module into the components hash.
    #------------------------------------------------------------------------
    method set_module ($type, $name, $module) {
        $components{$type}{$name} = $module;
    }

    #------------------------------------------------------------------------
    # remove_module
    #
    # Stops and removes a module from the components hash.
    #------------------------------------------------------------------------
    method remove_module ($type, $name) {
        $components{$type}{$name}->stop();
        delete $components{$type}{$name};
    }

    #------------------------------------------------------------------------
    # root_path__
    #
    # Joins the given path with the POPFile root directory.
    #------------------------------------------------------------------------
    method root_path ($path) {
        $popfile_root =~ s/[\/\\]$//;
        $path                   =~ s/^[\/\\]//;

        return "$popfile_root/$path";
    }

    # --- Getters / Setters ---

    method debug ($val = undef) {
        $debug = $val if defined $val;
        return $debug;
    }

    method module_config ($module, $item, $value = undef) {
        return $components{core}{config}->module_config($module, $item, $value );
    }

} # end class POPFile::Loader

1;
