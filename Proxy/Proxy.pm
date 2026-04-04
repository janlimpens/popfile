# SPDX-License-Identifier: GPL-3.0-or-later
package Proxy::Proxy;

# ----------------------------------------------------------------------------
#
# This module implements the base class for all POPFile proxy Modules
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
#   Modified by     Sam Schinke (sschinke@users.sourceforge.net)
#
# ----------------------------------------------------------------------------

use Object::Pad;
use locale;

use IO::Handle;
use IO::Socket;
use IO::Select;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

class Proxy::Proxy :isa(POPFile::Module) {
    # Reference to the classifier service facade
    field $service = undef;

    # Code reference called to handle each proxy connection
    field $child :reader :writer = 0;

    # Error messages for subclasses to set
    field $connection_timeout_error :reader :writer = '';
    field $connection_failed_error :reader :writer = '';
    field $good_response :reader :writer = '';
    field $ssl_not_supported_error :reader = '-ERR SSL connection is not supported since required modules are not installed';

    # Connect banner returned by the real server
    field $connect_banner :reader :writer = '';

    # Listening socket and its selector
    field $server = undef;
    field $selector = undef;

    # ----------------------------------------------------------------------------
    #
    # initialize
    #
    # ----------------------------------------------------------------------------
    method initialize() {
        $self->config('enabled', 1 );
        $self->config('port',    0 );

        $self->config('socks_server', '' );
        $self->config('socks_port',   1080 );

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # start
    #
    # ----------------------------------------------------------------------------
    method start() {
        $self->log_msg(1, "Opening listening socket on port " . $self->config('port') . '.' );
        $server = IO::Socket::INET->new(
            Proto     => 'tcp',
            ( $self->config('local' ) || 0 ) == 1 ? ( LocalAddr => 'localhost' ) : (),
            LocalPort => $self->config('port' ),
            Listen    => SOMAXCONN,
            Reuse     => 1 );

        my $name = $self->name();

        if ( !defined( $server ) ) {
            my $port = $self->config('port' );
            $self->log_msg(0, "Couldn't start the $name proxy because POPFile could not bind to the listen port $port" );
            print STDERR "\nCouldn't start the $name proxy because POPFile could not bind to the\nlisten port $port. This could be because there is another service\nusing that port or because you do not have the right privileges on\nyour system (On Unix systems this can happen if you are not root\nand the port you specified is less than 1024).\n\n";
            return 0;
        }

        $selector = IO::Select->new( $server );

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # stop
    #
    # ----------------------------------------------------------------------------
    method stop() {
        close $server if ( defined( $server ) );
    }

    # ----------------------------------------------------------------------------
    #
    # service
    #
    # ----------------------------------------------------------------------------
    method service() {
        if ( ( defined( $selector->can_read(0) ) ) &&
             ( $self->alive() ) ) {
            if ( my $client = $server->accept() ) {
                my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

                if ( ( ( $self->config('local' ) || 0 ) == 0 ) ||
                       ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {
                    binmode( $client );

                    if ( $self->config('force_fork' ) ) {
                        my ( $pid, $pipe ) = &{ $self->forker() };

                        if ( !defined( $pid ) || ( $pid == 0 ) ) {
                            $child->( $self, $client );
                            if ( defined( $pid ) ) {
                                &{ $self->setchildexit() }( 0 );
                            }
                        }
                    } else {
                        pipe my $reader, my $writer;
                        $child->( $self, $client );
                        close $reader;
                    }
                }

                close $client;
            }
        }

        return 1;
    }

    # ----------------------------------------------------------------------------
    #
    # forked
    #
    # ----------------------------------------------------------------------------
    method forked ($writer = undef) {
        close $server;
    }

    # ----------------------------------------------------------------------------
    #
    # tee_
    #
    # ----------------------------------------------------------------------------
    method tee ($socket, $text) {
        $self->log_msg(1, $text );
        print $socket $text;
    }

    # ----------------------------------------------------------------------------
    #
    # echo_to_regexp_
    #
    # ----------------------------------------------------------------------------
    method echo_to_regexp ($mail, $client, $regexp, $log = 0, $suppress = undef) {
        while ( my $line = $self->slurp($mail ) ) {
            if ( !defined($suppress) || !( $line =~ $suppress ) ) {
                if ( !$log ) {
                    print $client $line;
                } else {
                    $self->tee($client, $line );
                }
            } else {
                $self->log_msg(2, "Suppressed: $line" );
            }

            if ( $line =~ $regexp ) {
                last;
            }
        }
    }

    # ----------------------------------------------------------------------------
    #
    # echo_to_dot_
    #
    # ----------------------------------------------------------------------------
    method echo_to_dot ($mail, $client) {
        $self->echo_to_regexp($mail, $client, qr/^\.(\r\n|\r|\n)$/ );
    }

    # ----------------------------------------------------------------------------
    #
    # get_response_
    #
    # ----------------------------------------------------------------------------
    method get_response ($mail, $client, $command, $null_resp = 0, $suppress = 0) {
        unless ( defined($mail) && $mail->connected ) {
            $self->tee($client, "$connection_timeout_error$eol" );
            return ( $connection_timeout_error, 0 );
        }

        $self->tee($mail, $command . $eol );

        my $response;
        my $can_read = 0;

        if ( $mail =~ /ssl/i ) {
            $can_read = ( $mail->pending() > 0 );
        }
        if ( !$can_read ) {
            my $selector = IO::Select->new( $mail );
            my ($ready)  = $selector->can_read(
                ( !$null_resp ? $self->global_config('timeout' ) : .5 ) );
            $can_read = defined($ready) && ( $ready == $mail );
        }

        if ( $can_read ) {
            $response = $self->slurp($mail );

            if ( $response ) {
                $self->tee($client, $response ) if ( !$suppress );
                return ( $response, 1 );
            }
        }

        if ( !$null_resp ) {
            $self->tee($client, "$connection_timeout_error$eol" );
            return ( $connection_timeout_error, 0 );
        } else {
            $self->tee($client, "" );
            return ( "", 1 );
        }
    }

    # ----------------------------------------------------------------------------
    #
    # echo_response_
    #
    # ----------------------------------------------------------------------------
    method echo_response ($mail, $client, $command, $suppress = 0) {
        my ( $response, $ok ) = $self->get_response($mail, $client, $command, 0, $suppress );

        if ( $ok == 1 ) {
            if ( $response =~ /$good_response/ ) {
                return 0;
            } else {
                return 1;
            }
        } else {
            return 2;
        }
    }

    # ----------------------------------------------------------------------------
    #
    # verify_connected_
    #
    # ----------------------------------------------------------------------------
    method verify_connected ($mail, $client, $hostname, $port, $ssl = 0) {
        return $mail if ( $mail && $mail->connected );

        if ( $self->config('socks_server' ) ne '' ) {
            require IO::Socket::Socks;
            $self->log_msg(0, "Attempting to connect to socks server at "
                        . $self->config('socks_server' ) . ":"
                        . $self->config('socks_port' ) );

            $mail = IO::Socket::Socks->new(
                        ProxyAddr   => $self->config('socks_server' ),
                        ProxyPort   => $self->config('socks_port' ),
                        ConnectAddr => $hostname,
                        ConnectPort => $port );
        } else {
            if ( $ssl ) {
                eval { require IO::Socket::SSL; };
                if ( $@ ) {
                    $self->tee($client, "$ssl_not_supported_error$eol" );
                    return undef;
                }

                $self->log_msg(0, "Attempting to connect to SSL server at $hostname:$port" );

                $mail = IO::Socket::SSL->new(
                            Proto    => "tcp",
                            PeerAddr => $hostname,
                            PeerPort => $port,
                            Timeout  => $self->global_config('timeout' ),
                            Domain   => AF_INET );
            } else {
                $self->log_msg(0, "Attempting to connect to POP server at $hostname:$port" );

                $mail = IO::Socket::INET->new(
                            Proto    => "tcp",
                            PeerAddr => $hostname,
                            PeerPort => $port,
                            Timeout  => $self->global_config('timeout' ) );
            }
        }

        if ( $mail ) {
            if ( $mail->connected ) {
                $self->log_msg(0, "Connected to $hostname:$port timeout " . $self->global_config('timeout' ) );

                if ( !$ssl ) {
                    binmode( $mail );
                }

                if ( !$ssl || ( $mail->pending() == 0 ) ) {
                    my $selector = IO::Select->new( $mail );
                    last unless $selector->can_read( $self->global_config('timeout' ) );
                }

                my $buf        = '';
                my $max_length = 8192;
                my $n          = sysread( $mail, $buf, $max_length, length $buf );

                if ( !( $buf =~ /[\r\n]/ ) ) {
                    my $hit_newline = 0;
                    my $temp_buf;
                    my $wait = 0;

                    for my $i ( 0..( $self->global_config('timeout' ) * 100 ) ) {
                        if ( !$hit_newline ) {
                            $temp_buf    = $self->flush_extra($mail, $client, 1 );
                            $hit_newline = ( $temp_buf =~ /[\r\n]/ );
                            $buf        .= $temp_buf;
                            if ( $wait && !length $temp_buf ) {
                                select undef, undef, undef, 0.01;
                            }
                        } else {
                            last;
                        }
                    }
                }

                $self->log_msg(1, "Connection returned: $buf" );

                if ( $buf eq '' ) {
                    close $mail;
                    last;
                }

                $connect_banner = $buf;

                for my $i ( 0..4 ) {
                    $self->flush_extra($mail, $client, 1 );
                }

                return $mail;
            }
        }

        $self->log_msg(0, "IO::Socket::INET or IO::Socket::SSL gets an error: $@" );
        $self->tee($client, "$connection_failed_error $hostname:$port$eol" );
        return undef;
    }

    method set_service ($svc = undef) {
        $service = $svc if defined $svc;
        return $service
    }

} # end class Proxy::Proxy

1;
