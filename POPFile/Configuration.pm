# POPFILE LOADABLE MODULE
package POPFile::Configuration;

#----------------------------------------------------------------------------
#
# This module handles POPFile's configuration parameters.  It is used to
# load and save from the popfile.cfg file and individual POPFile modules
# register specific parameters with this module.  This module also handles
# POPFile's command line parsing
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
#----------------------------------------------------------------------------

use Object::Pad;
use locale;

use Getopt::Long;

class POPFile::Configuration :isa(POPFile::Module) {
    # This hash is indexed by parameter name and has two sub-keys:
    #   value    — the current value
    #   default  — the default value
    field %configuration_parameters;

    # Name of the PID file that we created
    field $pid_file = '';

    # The last time the PID was checked
    field $pid_check = 0;

    # Used to tell whether we need to save the configuration
    field $save_needed :reader :writer = 0;

    # We track when start() is called so that we know when the modules
    # are done setting the default values
    field $started :reader :writer = 0;

    # Local copies of POPFILE_ROOT and POPFILE_USER
    field $popfile_root :reader :writer = $ENV{POPFILE_ROOT} || './';
    field $popfile_user :reader :writer = $ENV{POPFILE_USER} || './';

    # Parameters from config file that no longer have a registered owner
    field %deprecated_parameters;

    BUILD {
        $pid_check = time;
        $self->set_name('config');
    }

    # ----------------------------------------------------------------------------
    #
    # initialize
    #
    # Called to initialize the interface
    #
    # ----------------------------------------------------------------------------
    method initialize {
        # This is the location where we store the PID of POPFile in a file
        # called popfile.pid

        $self->config_( 'piddir', './' );

        # The default interval of checking pid file in seconds
        # To turn off checking, set this option to 0

        $self->config_( 'pidcheck_interval', 5 );

        # The default timeout in seconds for POP3 commands

        $self->global_config_( 'timeout', 60 );

        # The default location for the message files

        $self->global_config_( 'msgdir', 'messages/' );

        # The maximum number of characters to consider in a message during
        # classification, display or reclassification

        $self->global_config_( 'message_cutoff', 100000 );

        # Checking for updates if off by default

        $self->global_config_( 'update_check', 0 );

        # The last time we checked for an update using the local epoch

        $self->global_config_( 'last_update_check', 0 );

        # Register for the TICKD message which is sent hourly by the
        # Logger module.   We use this to hourly save the configuration file
        # so that POPFile's configuration is saved in case of a hard crash.
        #
        # This is particularly needed by the IMAP module which stores some
        # state related information in the configuration parameters.  Note that
        # because of the save_needed__ bool there wont be any write to the
        # disk unless a configuration parameter has been changed since the
        # last save.  (see parameter())

        $self->mq_register_( 'TICKD', $self );

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # start
    #
    # Called to start this module
    #
    # ----------------------------------------------------------------------------
    method start {
        $started = 1;

        # Check to see if the PID file is present, if it is then another
        # POPFile may be running, warn the user and terminate, note the 0
        # at the end means that we allow the piddir to be absolute and
        # outside the user sandbox

        $pid_file = $self->get_user_path( $self->config_( 'piddir' ) . 'popfile.pid', 0 );

        if (defined($self->live_check_())) {
            return 0;
        }

        $self->write_pid_();

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # service
    #
    # service() is a called periodically to give the module a chance to do
    # housekeeping work.
    #
    # If any problem occurs that requires POPFile to shutdown service()
    # should return 0 and the top level process will gracefully terminate
    # POPFile including calling all stop() methods.  In normal operation
    # return 1.
    #
    # ----------------------------------------------------------------------------
    method service {
        my $time = time;

        if ( $self->config_( 'pidcheck_interval' ) > 0 ) {
            if ( $pid_check <= ( $time - $self->config_( 'pidcheck_interval' ))) {
                $pid_check = $time;

                if ( !$self->check_pid_() ) {
                    $self->write_pid_();
                    $self->log_( 0, "New POPFile instance detected and signalled" );
                }
            }
        }

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # stop
    #
    # Called to shutdown this module
    #
    # ----------------------------------------------------------------------------
    method stop {
        $self->save_configuration();

        $self->delete_pid_();
    }

    # ----------------------------------------------------------------------------
    #
    # deliver
    #
    # Called by the message queue to deliver a message
    #
    # ----------------------------------------------------------------------------
    method deliver ($type, @message) {
        if ( $type eq 'TICKD' ) {
            $self->save_configuration();
        }
    }

    # ----------------------------------------------------------------------------
    #
    # live_check_
    #
    # Checks if an instance of POPFile is currently running. Takes 10 seconds.
    # Returns the process-ID of the currently running POPFile, undef if none.
    #
    # ----------------------------------------------------------------------------
    method live_check_ {
        if ( $self->check_pid_() ) {
            my $oldpid = $self->get_pid_();
            my $wait_time = $self->config_( 'pidcheck_interval' ) * 2;

            my $error = "\n\nA copy of POPFile appears to be running.\n Attempting to signal the previous copy.\n Waiting $wait_time seconds for a reply.\n";

            $self->delete_pid_();

            print STDERR $error;

            select( undef, undef, undef, $wait_time );

            my $pid = $self->get_pid_();

            if ( defined($pid) ) {
                $error = "\n A copy of POPFile is running.\n It has signaled that it is alive with process ID: $pid\n";
                print STDERR $error;
                return $pid;
            } else {
                print STDERR "\nThe other POPFile ($oldpid) failed to signal back, starting new copy ($$)\n";
	    }
        }
        return undef;
    }

    # ----------------------------------------------------------------------------
    #
    # check_pid_
    #
    # returns 1 if the pid file exists, 0 otherwise
    #
    # ----------------------------------------------------------------------------
    method check_pid_ {
        return (-e $pid_file);
    }

    # ----------------------------------------------------------------------------
    #
    # get_pid_
    #
    # returns the pidfile proccess ID if a pid file is present, undef
    # otherwise (0 might be a valid PID)
    #
    # ----------------------------------------------------------------------------
    method get_pid_ {
        if (open my $pid_fh, '<', $pid_file) {
            my $pid = <$pid_fh>;
            $pid =~ s/[\r\n]//g;
            close $pid_fh;
            return $pid;
        }

        return undef;
    }

    # ----------------------------------------------------------------------------
    #
    # write_pid_
    #
    # writes the current process-ID into the pid file
    #
    # ----------------------------------------------------------------------------
    method write_pid_ {
        if ( open my $pid_fh, '>', $pid_file ) {
            print $pid_fh "$$\n";
            close $pid_fh;
        }
    }

    # ----------------------------------------------------------------------------
    #
    # delete_pid_
    #
    # deletes the pid file
    #
    # ----------------------------------------------------------------------------
    method delete_pid_ {
        unlink( $pid_file );
    }

    # ----------------------------------------------------------------------------
    #
    # parse_command_line - Parse ARGV
    #
    # The arguments are the keys of the configuration hash.  Any argument
    # that is not already defined in the hash generates an error, there
    # must be an even number of ARGV elements because each command
    # argument has to have a value.
    #
    # ----------------------------------------------------------------------------
    method parse_command_line {
        # Options from the command line specified with the --set parameter

        my @set_options;

        # The following command line options are supported:
        #
        # --set          Permanently sets a configuration item for the current user
        # --             Everything after this point is an old style POPFile option
        #
        # So its possible to do
        #
        # --set bayes_param=value --set=-bayes_param=value
        # --set -bayes_param=value -- -bayes_param value

        if ( !GetOptions( "set=s" => \@set_options ) ) {
            return 0;
        }

        # Join together the options specified with --set and those after
        # the --, the options in @set_options are going to be of the form
        # foo=bar and hence need to be split into foo bar

        my @options;

        for my $i (0..$#set_options) {
            $set_options[$i] =~ /-?(.+)=(.+)/;

	    if ( !defined( $1 ) ) {
                print STDERR "\nBad option: $set_options[$i]\n";
                return 0;
	    }

            push @options, ("-$1");
            if ( defined( $2 ) ) {
                push @options, ($2);
            }
        }

        push @options, @ARGV;

        if ( $#options >= 0 )  {
            my $i = 0;

            while ( $i <= $#options )  {
                # A command line argument must start with a -

                if ( $options[$i] =~ /^-(.+)$/ ) {
                    my $parameter = $self->upgrade_parameter__($1);

                    if (defined($configuration_parameters{$parameter})) {
                        if ( $i < $#options ) {
                            $self->parameter( $parameter, $options[$i+1] );
                            $i += 2;
                        } else {
                            print STDERR "\nMissing argument for $options[$i]\n";
                            return 0;
                        }
                    } else {
                        print STDERR "\nUnknown option $options[$i]\n";
                        return 0;
                    }
                } else {
                    print STDERR "\nExpected a command line option and got $options[$i]\n";
                    return 0;
                }
            }
        }

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # upgrade_parameter__
    #
    # Given a parameter from either command line or from the configuration
    # file return the upgraded version (e.g. the old port parameter
    # becomes pop3_port
    #
    # ----------------------------------------------------------------------------
    method upgrade_parameter__ ($parameter) {
        # This table maps from the old parameter to the new one, for
        # example the old xpl parameter which controls insertion of the
        # X-POPFile-Link header in email is now called GLOBAL_xpl and is
        # accessed through POPFile::Module::global_config_ The old piddir
        # parameter is now config_piddir and is accessed through either
        # config_ if accessed from the config module or through
        # module_config_ from outside

        my %upgrades = (
                         # Parameters that are now handled by Classifier::Bayes

                         'corpus',                   'bayes_corpus',
                         'unclassified_probability', 'bayes_unclassified_probability',

                         # Parameters that are now handled by
                         # POPFile::Configuration

                         'piddir',                   'config_piddir',

                         # Parameters that are now global to POPFile

                         'debug',                    'GLOBAL_debug',
                         'msgdir',                   'GLOBAL_msgdir',
                         'timeout',                  'GLOBAL_timeout',

                         # Parameters that are now handled by POPFile::Logger

                         'logdir',                   'logger_logdir',

                         # Parameters that are now handled by Proxy::POP3

                         'localpop',                 'pop3_local',
                         'port',                     'pop3_port',
                         'sport',                    'pop3_secure_port',
                         'server',                   'pop3_secure_server',
                         'separator',                'pop3_separator',
                         'toptoo',                   'pop3_toptoo',

                         # Parameters that are now handled by UI::HTML

                         'language',                 'html_language',
                         'last_reset',               'html_last_reset',
                         'last_update_check',        'html_last_update_check',
                         'localui',                  'html_local',
                         'page_size',                'html_page_size',
                         'password',                 'html_password',
                         'send_stats',               'html_send_stats',
                         'skin',                     'html_skin',
                         'test_language',            'html_test_language',
                         'update_check',             'html_update_check',
                         'ui_port',                  'html_port',

                         # Parameters that have moved from the UI::HTML to
                         # POPFile::History

                         'archive',                  'history_archive',
                         'archive_classes',          'history_archive_classes',
                         'archive_dir',              'history_archive_dir',
                         'history_days',             'history_history_days',
                         'html_archive',             'history_archive',
                         'html_archive_classes',     'history_archive_classes',
                         'html_archive_dir',         'history_archive_dir',
                         'html_history_days',        'history_history_days',

                         # Parameters that have moved from UI::HTML to
                         # global to POPFile

                         'html_update_check',        'GLOBAL_update_check',
                         'html_last_update_check',   'GLOBAL_last_update_check',

        );
        if ( defined( $upgrades{$parameter} ) ) {
            return $upgrades{$parameter};
        } else {
            return $parameter;
        }
    }

    # ----------------------------------------------------------------------------
    #
    # load_configuration
    #
    # Loads the current configuration of popfile into the configuration
    # hash from a local file.  The format is a very simple set of lines
    # containing a space separated name and value pair
    #
    # ----------------------------------------------------------------------------
    method load_configuration {
        $started = 1;

        my $config_file = $self->get_user_path( 'popfile.cfg' );

        if ( open my $config, '<', $config_file ) {
            while ( <$config> ) {
                s/(\015|\012)//g;
                if ( /(\S+) (.+)?/ ) {
                    my $parameter = $1;
                    my $value     = $2;
                    $value = '' if !defined( $value );

                    $parameter = $self->upgrade_parameter__($parameter);

                    # There's a special hack here inserted so that even if
                    # the HTML module is not loaded the html_language
                    # parameter is loaded and not discarded.  That's done
                    # so that the Japanese users can use insert.pl
                    # etc. which rely on knowing the language

                    if (defined($configuration_parameters{$parameter}) ||                        ( $parameter eq 'html_language' ) ) {                        $configuration_parameters{$parameter}{value} =                            $value;                    } else {
                        $deprecated_parameters{$parameter} = $value;
                    }
                }
            }

            close $config;
        } else {
            if ( -e $config_file && !-r _ ) {
                $self->log_( 0, "Couldn't load from the configuration file $config_file" );
            }
        }

        $save_needed = 0;
    }

    # ----------------------------------------------------------------------------
    #
    # save_configuration
    #
    # Saves the current configuration of popfile from the configuration
    # hash to a local file.
    #
    # ----------------------------------------------------------------------------
    method save_configuration {
        if ( $save_needed == 0 ) {
            return;
        }

        my $config_file = $self->get_user_path( 'popfile.cfg' );
        my $config_temp = $self->get_user_path( 'popfile.cfg.tmp' );

        if ( -e $config_file && !-w _ ) {
            $self->log_( 0, "Can't write to the configuration file $config_file" );
        }

        if ( open my $config, '>', $config_temp ) {
            $save_needed = 0;

            foreach my $key (sort keys %configuration_parameters) {
                print $config "$key $configuration_parameters{$key}{value}\n";
            }

            close $config;

            rename $config_temp, $config_file;
        } else {
            $self->log_( 0, "Couldn't open a temporary configuration file $config_temp" );
        }
    }

    # ----------------------------------------------------------------------------
    #
    # get_user_path, get_root_path
    #
    # Resolve a path relative to POPFILE_USER or POPFILE_ROOT
    #
    # $path              The path to resolve
    # $sandbox           Set to 1 if this path must be sandboxed (i.e. absolute
    #                    paths and paths containing .. are not accepted).
    #
    # ----------------------------------------------------------------------------
    method get_user_path ($path, $sandbox = undef) {
        return $self->path_join__( $popfile_user, $path, $sandbox );
    }

    method get_root_path ($path, $sandbox = undef) {
        return $self->path_join__( $popfile_root, $path, $sandbox );
    }

    # ----------------------------------------------------------------------------
    #
    # path_join__
    #
    # Join two paths togther
    #
    # $left              The LHS
    # $right             The RHS
    # $sandbox           Set to 1 if this path must be sandboxed (i.e. absolute
    #                    paths and paths containing .. are not accepted).
    #
    # ----------------------------------------------------------------------------
    method path_join__ ($left, $right, $sandbox = undef) {
        $sandbox = 1 if ( !defined( $sandbox ) );

        if ( ( $right =~ /^\// ) ||             ( $right =~ /^[A-Za-z]:[\/\\]/ ) ||
             ( $right =~ /\\\\/ ) ) {            if ( $sandbox ) {
                $self->log_( 0, "Attempt to access path $right outside sandbox" );
                return undef;
            } else {
                return $right;
            }
        }

        if ( $sandbox && ( $right =~ /\.\./ ) ) {
            $self->log_( 0, "Attempt to access path $right outside sandbox" );
            return undef;
        }

        $left  =~ s/\/$//;
        $right =~ s/^\///;

        return "$left/$right";
    }

    # ----------------------------------------------------------------------------
    #
    # parameter
    #
    # Gets or sets a parameter
    #
    # $name          Name of the parameter to get or set
    # $value         Optional value to set the parameter to
    #
    # Always returns the current value of the parameter
    #
    # ----------------------------------------------------------------------------
    method parameter ($name, $value = undef) {
        if ( defined( $value ) ) {
            $save_needed = 1;
            $configuration_parameters{$name}{value} = $value;
            if ( $started == 0 ) {
                $configuration_parameters{$name}{default} = $value;
            }
        }

        # If $configuration_parameters{$name} is undefined, simply
        # return undef to avoid auto-vivifying it.
        if ( defined($configuration_parameters{$name}) ) {
            return $configuration_parameters{$name}{value};
        } else {
            return undef;
        }
    }

    # ----------------------------------------------------------------------------
    #
    # is_default
    #
    # Returns whether the parameter has the default value or not
    #
    # $name          Name of the parameter
    #
    # Returns 1 if the parameter still has its default value
    #
    # ----------------------------------------------------------------------------
    method is_default ($name) {
        return ( $configuration_parameters{$name}{value} eq                 $configuration_parameters{$name}{default} );    }

    # GETTERS / SETTERS

    method configuration_parameters {
        return sort keys %configuration_parameters;
    }

    method deprecated_parameter ($name) {
        return $deprecated_parameters{$name};
    }
}

1;
