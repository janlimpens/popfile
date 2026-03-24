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

class POPFile::Loader {

    BUILD {
        # The POPFile classes are stored by reference in the components
        # hash, the top level key is the type of the component (see
        # CORE_load_directory_modules) and then the name of the component
        # derived from calls to each loadable modules name() method.

        $self->{components__} = {};

        # When set to 1 the proxy works normally; 0 means graceful shutdown.

        $self->{alive__} = 1;

        # Must be 1 for POPFile::Loader to create any output on STDOUT.

        $self->{debug__} = 1;

        # If 1, POPFile shuts down immediately after starting (used by
        # installer, set by --shutdown command-line option).

        $self->{shutdown__} = 0;

        # Callback refs populated in CORE_loader_init.

        $self->{aborting__}  = '';
        $self->{pipeready__} = '';
        $self->{forker__}    = '';
        $self->{reaper__}    = '';
        $self->{childexit__} = '';
        $self->{warning__}   = '';
        $self->{die__}       = '';

        # POPFile version

        $self->{major_version__}  = '?';
        $self->{minor_version__}  = '?';
        $self->{build_version__}  = '?';
        $self->{version_string__} = '';

        # Where POPFile is installed

        $self->{popfile_root__} = './';
    }

    #------------------------------------------------------------------------
    # CORE_loader_init
    #
    # Initialize things only needed in CORE
    #------------------------------------------------------------------------
    method CORE_loader_init {

        if ( defined $ENV{POPFILE_ROOT} ) {
            $self->{popfile_root__} = $ENV{POPFILE_ROOT};
        }

        # These anonymous subroutine references allow us to call these
        # important functions from anywhere using the reference, granting
        # internal access to $self without exposing $self to the caller.

        $self->{aborting__}  = sub { $self->CORE_aborting(@_) };
        $self->{pipeready__} = sub { $self->pipeready(@_) };
        $self->{forker__}    = sub { $self->CORE_forker(@_) };
        $self->{reaper__}    = sub { $self->CORE_reaper(@_) };
        $self->{childexit__} = sub { $self->CORE_childexit(@_) };
        $self->{warning__}   = sub { $self->CORE_warning(@_) };
        $self->{die__}       = sub { $self->CORE_die(@_) };

        my $version_file = $self->root_path__( 'POPFile/popfile_version' );

        if ( -e $version_file ) {
            open my $ver, '<', $version_file;
            my $major = int(<$ver>);
            my $minor = int(<$ver>);
            my $rev   = int(<$ver>);
            close $ver;
            $self->CORE_version( $major, $minor, $rev );
        }

        GetOptions( 'shutdown' => \$self->{shutdown__} );

        print "\nPOPFile Engine loading\n" if $self->{debug__};
    }

    #------------------------------------------------------------------------
    # CORE_aborting
    #
    # Called if we are going to be aborted.  Sets alive to 0 so that we
    # abort at the next convenient moment.
    #------------------------------------------------------------------------
    method CORE_aborting {

        $self->{alive__} = 0;
        foreach my $type (sort keys %{$self->{components__}}) {
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                $self->{components__}{$type}{$name}->alive(0);
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

        foreach my $type (sort keys %{$self->{components__}}) {
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                $self->{components__}{$type}{$name}->reaper();
            }
        }

        $SIG{CHLD} = $self->{reaper__};
    }

    #------------------------------------------------------------------------
    # CORE_childexit
    #
    # Called by a module in a child process that wants to exit.  Warns all
    # other modules in the same process and then exits.
    #------------------------------------------------------------------------
    method CORE_childexit ($code) {

        foreach my $type (sort keys %{$self->{components__}}) {
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                $self->{components__}{$type}{$name}->childexit();
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

        my @types = sort keys %{$self->{components__}};

        foreach my $type (@types) {
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                $self->{components__}{$type}{$name}->prefork();
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
                foreach my $name (sort keys %{$self->{components__}{$type}}) {
                    $self->{components__}{$type}{$name}->forked($writer);
                }
            }
            close $reader;
            $writer->autoflush(1);
            return (0, $writer);
        }

        foreach my $type (@types) {
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                $self->{components__}{$type}{$name}->postfork($pid, $reader);
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
            $self->{components__}{core}{logger}->debug( 0, "Perl warning: @message" );
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
            $self->{components__}{core}{logger}->debug( 0, "Perl fatal error : @message" );
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

        print "\n         {$type:" if $self->{debug__};

        opendir my $dh, $self->root_path__($directory);

        while ( my $entry = readdir $dh ) {
            if ( $entry =~ /\.pm$/ ) {
                $self->CORE_load_module( "$directory/$entry", $type );
            }
        }

        closedir $dh;

        print '} ' if $self->{debug__};
    }

    #------------------------------------------------------------------------
    # CORE_load_module
    #
    # Loads a single POPFile Loadable Module and adds it to components__.
    # Returns the module handle (undef on failure).
    #------------------------------------------------------------------------
    method CORE_load_module ($module, $type) {

        my $mod = $self->load_module_($module);

        if ( defined $mod ) {
            my $name = $mod->name();
            print " $name" if $self->{debug__};
            $self->{components__}{$type}{$name} = $mod;
        }
        return $mod;
    }

    #------------------------------------------------------------------------
    # load_module_
    #
    # Loads a single POPFile Loadable Module.  No internal side-effects.
    # Returns the module handle (undef if not a loadable module).
    #------------------------------------------------------------------------
    method load_module_ ($module) {

        my $mod;

        if ( open my $fh, '<', $self->root_path__($module) ) {
            my $first = <$fh>;
            close $fh;

            if ( $first =~ /^# POPFILE LOADABLE MODULE/ ) {
                require $module;

                $module =~ s/\//::/;
                $module =~ s/\.pm//;

                $mod = $module->new();
            }
        }
        return $mod;
    }

    #------------------------------------------------------------------------
    # CORE_signals
    #
    # Sets signal handlers so POPFile handles OS and IPC events gracefully.
    #------------------------------------------------------------------------
    method CORE_signals {

        $SIG{QUIT}     = $self->{aborting__};
        $SIG{ABRT}     = $self->{aborting__};
        $SIG{KILL}     = $self->{aborting__};
        $SIG{STOP}     = $self->{aborting__};
        $SIG{TERM}     = $self->{aborting__};
        $SIG{INT}      = $self->{aborting__};
        $SIG{CHLD}     = $self->{reaper__};
        $SIG{ALRM}     = 'IGNORE';
        $SIG{PIPE}     = 'IGNORE';
        $SIG{__WARN__} = $self->{warning__};
        $SIG{__DIE__}  = $self->{die__};

        return $SIG;
    }

    #------------------------------------------------------------------------
    # CORE_load
    #
    # Loads POPFile's modules.
    # $noserver — if 1, skip UI, Proxy, and Services.
    #------------------------------------------------------------------------
    method CORE_load ($noserver = 0) {

        print "\n    Loading... " if $self->{debug__};

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

        print "\n\nPOPFile Engine $self->{version_string__} starting" if $self->{debug__};

        # Give every module access to configuration, logger, version, and MQ.

        foreach my $type (sort keys %{$self->{components__}}) {
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                $self->{components__}{$type}{$name}->version(
                    scalar($self->CORE_version()) );
                $self->{components__}{$type}{$name}->configuration(
                    $self->{components__}{core}{config} );
                $self->{components__}{$type}{$name}->logger(
                    $self->{components__}{core}{logger} )
                    if $name ne 'logger';
                $self->{components__}{$type}{$name}->mq(
                    $self->{components__}{core}{mq} );
            }
        }

        # All interface components need access to the classifier and history.

        foreach my $name (sort keys %{$self->{components__}{interface}}) {
            $self->{components__}{interface}{$name}->classifier(
                $self->{components__}{classifier}{bayes} );
            $self->{components__}{interface}{$name}->history(
                $self->{components__}{core}{history} );
        }

        foreach my $name (sort keys %{$self->{components__}{proxy}}) {
            $self->{components__}{proxy}{$name}->classifier(
                $self->{components__}{classifier}{bayes} );
            $self->{components__}{proxy}{$name}->history(
                $self->{components__}{core}{history} );
        }

        foreach my $name (sort keys %{$self->{components__}{services}}) {
            $self->{components__}{services}{$name}->classifier(
                $self->{components__}{classifier}{bayes} );
            $self->{components__}{services}{$name}->history(
                $self->{components__}{core}{history} );
        }

        # Wire the classifier service to proxy and interface modules so they
        # can call it instead of reaching into Bayes directly.

        if ( defined $self->{components__}{services}{classifier_service} ) {
            my $svc = $self->{components__}{services}{classifier_service};

            foreach my $name (sort keys %{$self->{components__}{proxy}}) {
                my $mod = $self->{components__}{proxy}{$name};
                $mod->set_service($svc) if $mod->can('set_service');
            }
            foreach my $name (sort keys %{$self->{components__}{interface}}) {
                my $mod = $self->{components__}{interface}{$name};
                $mod->set_service($svc) if $mod->can('set_service');
            }
        }

        # Classifier::Bayes and POPFile::History are friends.

        $self->{components__}{core}{history}->classifier(
            $self->{components__}{classifier}{bayes} );
        $self->{components__}{classifier}{bayes}->history(
            $self->{components__}{core}{history} );

        $self->{components__}{classifier}{bayes}->{parser__}->mangle(
            $self->{components__}{classifier}{wordmangle} );
    }

    #------------------------------------------------------------------------
    # CORE_initialize
    #
    # Loops across POPFile's modules and initializes them.
    #------------------------------------------------------------------------
    method CORE_initialize {

        print "\n\n    Initializing... " if $self->{debug__};

        # Core must be initialized first.
        my @c = ( 'core', grep { !/^core$/ } sort keys %{$self->{components__}} );

        foreach my $type (@c) {
            print "\n         {$type:" if $self->{debug__};
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                print " $name" if $self->{debug__};
                STDOUT->flush();

                my $mod  = $self->{components__}{$type}{$name};
                my $code = $mod->initialize();

                if ( $code == 0 ) {
                    die "Failed to start while initializing the $name module";
                }

                if ( $code == 1 ) {
                    $mod->alive(1);
                    $mod->forker(       $self->{forker__}    );
                    $mod->setchildexit( $self->{childexit__} );
                    $mod->pipeready(    $self->{pipeready__} );
                }
            }
            print '} ' if $self->{debug__};
        }
        print "\n" if $self->{debug__};
    }

    #------------------------------------------------------------------------
    # CORE_config
    #
    # Loads POPFile's configuration and applies command-line overrides.
    #------------------------------------------------------------------------
    method CORE_config {

        $self->{components__}{core}{config}->load_configuration();
        return $self->{components__}{core}{config}->parse_command_line();
    }

    #------------------------------------------------------------------------
    # CORE_start
    #
    # Loops across POPFile's modules and starts them.
    #------------------------------------------------------------------------
    method CORE_start {

        print "\n    Starting...     " if $self->{debug__};

        my @c = ( 'core', grep { !/^core$/ } sort keys %{$self->{components__}} );

        foreach my $type (@c) {
            print "\n         {$type:" if $self->{debug__};
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                my $code = $self->{components__}{$type}{$name}->start();

                if ( $code == 0 ) {
                    die "Failed to start while starting the $name module";
                }

                if ( $code == 2 ) {
                    delete $self->{components__}{$type}{$name};
                } else {
                    print " $name" if $self->{debug__};
                    STDOUT->flush();
                }
            }
            print '} ' if $self->{debug__};
        }

        print "\n\nPOPFile Engine ", scalar($self->CORE_version()), " running\n"
            if $self->{debug__};
        STDOUT->flush();
    }

    #------------------------------------------------------------------------
    # CORE_service
    #
    # The main service loop.  Calls each module's service() method.
    # $nowait — if 1, run once without sleeping and return.
    #------------------------------------------------------------------------
    method CORE_service ($nowait = 0) {

        while ( $self->{alive__} == 1 ) {
            foreach my $type (sort keys %{$self->{components__}}) {
                foreach my $name (sort keys %{$self->{components__}{$type}}) {
                    if ( $self->{components__}{$type}{$name}->service() == 0 ) {
                        $self->{alive__} = 0;
                        last;
                    }
                }
            }

            select(undef, undef, undef, 0.05) if !$nowait;

            last if $nowait;

            if ( $self->{shutdown__} == 1 ) {
                $self->{alive__} = 0;
            }
        }

        return $self->{alive__};
    }

    #------------------------------------------------------------------------
    # CORE_stop
    #
    # Loops across POPFile's modules and stops them.
    #------------------------------------------------------------------------
    method CORE_stop {

        if ( $self->{debug__} ) {
            print "\n\nPOPFile Engine $self->{version_string__} stopping\n";
            STDOUT->flush();
            print "\n    Stopping... ";
        }

        # Shut down MQ first so it can flush remaining messages to other
        # modules before they stop.

        $self->{components__}{core}{mq}->alive(0);
        $self->{components__}{core}{mq}->stop();
        $self->{components__}{core}{history}->alive(0);
        $self->{components__}{core}{history}->stop();

        foreach my $type (sort keys %{$self->{components__}}) {
            print "\n         {$type:" if $self->{debug__};
            foreach my $name (sort keys %{$self->{components__}{$type}}) {
                print " $name" if $self->{debug__};
                STDOUT->flush();

                next if $name eq 'mq';
                next if $name eq 'history';
                $self->{components__}{$type}{$name}->alive(0);
                $self->{components__}{$type}{$name}->stop();
            }
            print '} ' if $self->{debug__};
        }

        print "\n\nPOPFile Engine $self->{version_string__} terminated\n"
            if $self->{debug__};
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
                ? ($self->{major_version__}, $self->{minor_version__}, $self->{build_version__})
                : $self->{version_string__};
        }

        ($self->{major_version__},
         $self->{minor_version__},
         $self->{build_version__}) = ($major_version, $minor_version, $build_version);
        $self->{version_string__} = "v$major_version.$minor_version.$build_version";
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

        return $self->{components__}{$type}{$name};
    }

    #------------------------------------------------------------------------
    # set_module
    #
    # Inserts a module into the components hash.
    #------------------------------------------------------------------------
    method set_module ($type, $name, $module) {

        $self->{components__}{$type}{$name} = $module;
    }

    #------------------------------------------------------------------------
    # remove_module
    #
    # Stops and removes a module from the components hash.
    #------------------------------------------------------------------------
    method remove_module ($type, $name) {

        $self->{components__}{$type}{$name}->stop();
        delete $self->{components__}{$type}{$name};
    }

    #------------------------------------------------------------------------
    # root_path__
    #
    # Joins the given path with the POPFile root directory.
    #------------------------------------------------------------------------
    method root_path__ ($path) {

        $self->{popfile_root__} =~ s/[\/\\]$//;
        $path                   =~ s/^[\/\\]//;

        return "$self->{popfile_root__}/$path";
    }

    # --- Getters / Setters ---

    method debug ($debug = undef) {
        $self->{debug__} = $debug if defined $debug;
        return $self->{debug__};
    }

    method module_config ($module, $item, $value = undef) {
        return $self->{components__}{core}{config}->module_config_( $module, $item, $value );
    }

} # end class POPFile::Loader

1;
