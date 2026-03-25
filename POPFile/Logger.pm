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

    field $debug_filename    = '';
    field $last_ten          = undef;
    field $initialize_called = 0;
    field $last_tickd        = 0;
    field $today             = 0;

    BUILD {
        $self->name('logger');
    }

=head2 initialize

Called to initialize the logger. Sets default configuration values for
C<debug>, C<logdir>, C<format>, and C<level>, and registers for the
C<TICKD> message queue event.

Returns 1 on success.

=cut

    method initialize {
        $initialize_called = 1;

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

        $last_tickd = time;

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

=head2 start

Called to start the logger running. Calculates the current log filename
and emits startup banner messages.

Returns 1 on success.

=cut

    method start {
        $self->calculate_today();

        $self->debug( 0, '-----------------------' );
        $self->debug( 0, 'POPFile ' . $self->version() . ' starting' );

        return 1;
    }

=head2 stop

Called to stop the logger module. Emits a shutdown banner to the log.

=cut

    method stop {
        $self->debug( 0, 'POPFile stopped' );
        $self->debug( 0, '---------------' );
    }

=head2 service

Called repeatedly by the main loop. Recalculates the current log filename
and posts a C<TICKD> message to the queue if more than an hour has elapsed
since the last tick.

Returns 1 on success.

=cut

    method service {
        $self->calculate_today();

        # We send out a TICKD message every hour so that other modules
        # can do clean up tasks that need to be done regularly but not
        # often

        if ( $self->time > ( $last_tickd + 3600 ) ) {
            $self->mq_post_( 'TICKD' );
            $last_tickd = $self->time;
        }

        return 1;
    }

=head2 time

Returns the current epoch time. Wraps the built-in C<time> function so
the test suite can override it to simulate time passing.

=cut

    method time { return time; }

=head2 calculate_today

Sets C<$today> to the start of the current day (in epoch seconds) and
updates C<$debug_filename> to the corresponding log file path.

=cut

    method calculate_today {
        # Create the name of the debug file for the debug() function
        $today = int( $self->time / $seconds_per_day ) * $seconds_per_day;  # just to make this work in Eclipse: /

        # Note that 0 parameter than allows the logdir to be outside the user
        # sandbox

        $debug_filename = $self->get_user_path_(                   # PROFILE BLOCK START
            $self->config_( 'logdir' ) . "popfile$today.log", 0 ); # PROFILE BLOCK STOP
    }

=head2 remove_debug_files

Removes POPFile log files in the configured log directory that are older
than three days.

=cut

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

=head2 debug

    $self->debug( $level, $message );

Writes C<$message> to the log file and/or STDOUT if the configured log
level allows it. C<$level> must be less than or equal to the C<level>
config value for the message to be written. USER/PASS command arguments
are automatically obscured. Control characters are hex-escaped.

Also maintains an in-memory ring buffer of the last ten log lines,
accessible via C<last_ten>.

=cut

    method debug ($level, $message) {
        if ( $initialize_called == 0 ) {
            return;
        }

        if ( ( !defined( $self->config_( 'level' ) ) ) ||   # PROFILE BLOCK START
             ( $level > $self->config_( 'level' ) ) ) {     # PROFILE BLOCK STOP
            return;
        }

        if ( $debug_filename eq '' ) {
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
                if ( open my $debug, '>>', $debug_filename ) {
                    print $debug $msg;
                    close $debug;
                }
            }

            print $msg if ( $self->global_config_( 'debug' ) & 2 );

            # Add the line to the in memory collection of the last ten
            # logger entries and then remove the first one if we now have
            # more than 10

            push @{$last_ten}, ($msg);

            if ( $#{$last_ten} > 9 ) {
                shift @{$last_ten};
            }
        }
    }

=head2 debug_filename

Returns the path to the current log file.

=cut

    method debug_filename {
        return $debug_filename;
    }

=head2 last_ten

Returns the last (up to) ten log lines as a list. If no lines have been
logged yet, returns a single-element list containing C<'log empty'>.

=cut

    method last_ten {
        if ( $#{$last_ten} >= 0 ) {
            return @{$last_ten};
        } else {
            my @temp = ( 'log empty' );
            return @temp;
        }
    }
}

1;
