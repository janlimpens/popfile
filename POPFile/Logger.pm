# POPFILE LOADABLE MODULE
package POPFile::Logger;

#----------------------------------------------------------------------------
#
# This module handles POPFile's logger.  It is used to save debugging
# information to disk or to send it to the screen.
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

# Constant used by the log rotation code
my $seconds_per_day = 60 * 60 * 24;

class POPFile::Logger :isa(POPFile::Module) {

    BUILD {
        $self->{debug_filename__}    = '';
        $self->{last_ten__}          = undef;
        $self->{initialize_called__} = 0;
        $self->name('logger');
    }

    # ---------------------------------------------------------------------------
    #
    # initialize
    #
    # Called to initialize the interface
    #
    # ---------------------------------------------------------------------------
    method initialize {
        $self->{initialize_called__} = 1;

        # Start with debugging to file
        $self->global_config_( 'debug', 1 );

        # The default location for log files
        $self->config_( 'logdir', './' );

        # The output format for log files, can be default, tabbed or csv
        $self->config_( 'format', 'default' );

        # The log level.  There are three levels of log:
        #
        # 0   Critical log messages
        # 1   Verbose logging
        # 2   Maximum verbosity

        $self->config_( 'level', 0 );

        $self->{last_tickd__} = time;

        $self->mq_register_( 'TICKD', $self );

        return 1;
    }

    # ---------------------------------------------------------------------------
    #
    # deliver
    #
    # Called by the message queue to deliver a message
    #
    # There is no return value from this method
    #
    # ---------------------------------------------------------------------------
    method deliver ($type, @message) {

        # If a day has passed then clean up log files

        if ( $type eq 'TICKD' ) {
            $self->remove_debug_files();
        }
    }

    # ---------------------------------------------------------------------------
    #
    # start
    #
    # Called to start the logger running
    #
    # ---------------------------------------------------------------------------
    method start {
        $self->calculate_today__();

        $self->debug( 0, '-----------------------' );
        $self->debug( 0, 'POPFile ' . $self->version() . ' starting' );

        return 1;
    }

    # ---------------------------------------------------------------------------
    #
    # stop
    #
    # Called to stop the logger module
    #
    # ---------------------------------------------------------------------------
    method stop {
        $self->debug( 0, 'POPFile stopped' );
        $self->debug( 0, '---------------' );
    }

    # ---------------------------------------------------------------------------
    #
    # service
    #
    # ---------------------------------------------------------------------------
    method service {
        $self->calculate_today__();

        # We send out a TICKD message every hour so that other modules
        # can do clean up tasks that need to be done regularly but not
        # often

        if ( $self->time > ( $self->{last_tickd__} + 3600 ) ) {
            $self->mq_post_( 'TICKD' );
            $self->{last_tickd__} = $self->time;
        }

        return 1;
    }

    # ---------------------------------------------------------------------------
    #
    # time
    #
    # Does the same as the built-in time function but can be overriden
    # by the test suite to trick the module into thinking that a lot
    # of time has passed.
    #
    # ---------------------------------------------------------------------------
    method time { return time; }

    # ---------------------------------------------------------------------------
    #
    # calculate_today__
    #
    # Set the global $self->{today} variable to the current day in seconds
    #
    # ---------------------------------------------------------------------------
    method calculate_today__ {
        # Create the name of the debug file for the debug() function
        $self->{today__} = int( $self->time / $seconds_per_day ) * $seconds_per_day;  # just to make this work in Eclipse: /

        # Note that 0 parameter than allows the logdir to be outside the user
        # sandbox

        $self->{debug_filename__} = $self->get_user_path_(                   # PROFILE BLOCK START
            $self->config_( 'logdir' ) . "popfile$self->{today__}.log", 0 ); # PROFILE BLOCK STOP
    }

    # ---------------------------------------------------------------------------
    #
    # remove_debug_files
    #
    # Removes popfile log files that are older than 3 days
    #
    # ---------------------------------------------------------------------------
    method remove_debug_files {
        my @debug_files = glob( $self->get_user_path_(                            # PROFILE BLOCK START
                              $self->config_( 'logdir' ) . 'popfile*.log', 0 ) ); # PROFILE BLOCK STOP

        foreach my $debug_file (@debug_files) {
            # Extract the epoch information from the popfile log file name
            if ( $debug_file =~ /popfile([0-9]+)\.log/ )  {
                # If older than now - 3 days then delete
                unlink($debug_file) if ( $1 < ($self->time - 3 * $seconds_per_day) );
            }
        }
    }

    # ----------------------------------------------------------------------------
    #
    # debug
    #
    # $level      The level of this message
    # $message    A string containing a debug message that may or may not be
    #             printed
    #
    # Prints the passed string if the global $debug is true
    #
    # ----------------------------------------------------------------------------
    method debug ($level, $message) {
        if ( $self->{initialize_called__} == 0 ) {
            return;
        }

        if ( ( !defined( $self->config_( 'level' ) ) ) ||   # PROFILE BLOCK START
             ( $level > $self->config_( 'level' ) ) ) {     # PROFILE BLOCK STOP
            return;
        }

        if ( $self->{debug_filename__} eq '' ) {
            return;
        }

        if ( $self->global_config_( 'debug' ) > 0 ) {

            # Check to see if we are handling the USER/PASS command and if
            # we are then obscure the account information

            if ( $message =~ /((--)?)(USER|PASS)\s+\S*(\1)/i ) {
                $message = "$`$1$3 XXXXXX$4";
            }

            $message =~ s/([\x00-\x1f])/sprintf("[%2.2x]", ord($1))/eg;

            my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =   # PROFILE BLOCK START
                localtime;                                                         # PROFILE BLOCK STOP
            $year += 1900;
            $mon  += 1;

            $min  = "0$min"  if ( $min  < 10 );
            $hour = "0$hour" if ( $hour < 10 );
            $sec  = "0$sec"  if ( $sec  < 10 );

            my $delim = ' ';
            $delim = "\t" if ( $self->config_( 'format' ) eq 'tabbed' );
            $delim = ',' if ( $self->config_( 'format' ) eq 'csv' );

            my $msg =                                                             # PROFILE BLOCK START
                "$year/$mon/$mday$delim$hour:$min:$sec$delim$$:$delim$message\n"; # PROFILE BLOCK STOP

            if ( $self->global_config_( 'debug' ) & 1 )  {
                if ( open my $debug, '>>', $self->{debug_filename__} ) {
                    print $debug $msg;
                    close $debug;
                }
            }

            print $msg if ( $self->global_config_( 'debug' ) & 2 );

            # Add the line to the in memory collection of the last ten
            # logger entries and then remove the first one if we now have
            # more than 10

            push @{$self->{last_ten__}}, ($msg);

            if ( $#{$self->{last_ten__}} > 9 ) {
                shift @{$self->{last_ten__}};
            }
        }
    }

    # GETTERS/SETTERS

    method debug_filename {
        return $self->{debug_filename__};
    }

    method last_ten {
        if ( $#{$self->{last_ten__}} >= 0 ) {
            return @{$self->{last_ten__}};
        } else {
            my @temp = ( 'log empty' );
            return @temp;
        }
    }
}

1;
