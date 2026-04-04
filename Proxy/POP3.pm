package Proxy::POP3;

# ----------------------------------------------------------------------------
#
# This module handles proxying the POP3 protocol for POPFile.
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

use Digest::MD5;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

class Proxy::POP3 :isa(Proxy::Proxy) {
    field $use_apop = 0;
    field $apop_user = '';
    field $apop_banner = undef;

    BUILD {
        $self->set_name( 'pop3' );
        $self->set_child( \&child__ );
        $self->set_connection_timeout_error( '-ERR no response from mail server' );
        $self->set_connection_failed_error(  '-ERR can\'t connect to' );
        $self->set_good_response( '^\+OK' );
    }

    # ----------------------------------------------------------------------------
    #
    # initialize
    #
    # ----------------------------------------------------------------------------
    method initialize() {
        $self->config('enabled', 1 );
        $self->config('force_fork', 1 );
        $self->config('port', 1110 );
        $self->config('secure_server', '' );
        $self->config('secure_port', 995 );
        $self->config('local', 1 );
        $self->config('toptoo', 0 );
        $self->config('separator', ':' );
        $self->config('welcome_string',
            "POP3 POPFile ($self->version()) server ready" );

        return $self->SUPER::initialize();
    }

    # ----------------------------------------------------------------------------
    #
    # start
    #
    # ----------------------------------------------------------------------------
    method start() {
        if ( $self->config('enabled' ) == 0 ) {
            return 2;
        }

        if ( $self->config('welcome_string' ) =~
             /^POP3 POPFile \(v\d+\.\d+\.\d+\) server ready$/ ) {
            $self->config('welcome_string',
                            "POP3 POPFile ($self->version()) server ready" );
        }

        return $self->SUPER::start();
    }

    # ----------------------------------------------------------------------------
    #
    # child__
    #
    # The worker method called when we get a good connection from a client.
    # Called as a plain sub via coderef stored in $self->{child_}.
    #
    # $self   - this Proxy::POP3 object
    # $client - an open stream to a POP3 client
    #
    # ----------------------------------------------------------------------------
    method child ($client) {
        my %downloaded;
        my $mail;

        $apop_banner = undef;
        $use_apop    = 0;
        $apop_user   = '';

        $self->tee($client, "+OK " . $self->config('welcome_string' ) . "$eol" );

        my $s = $self->config('separator' );
        $s =~ s/(\$|\@|\[|\]|\(|\)|\||\?|\*|\.|\^|\+)/\\$1/;

        my $transparent  = "^USER ([^$s]+)\$";
        my $user_command = "USER ([^$s]+)($s(\\d{1,5}))?$s([^$s]+)($s([^$s]+))?";
        my $apop_command = "APOP ([^$s]+)($s(\\d{1,5}))?$s([^$s]+) (.*?)";

        $self->log_msg(2, "Regexps: $transparent, $user_command, $apop_command" );

        while ( <$client> ) {
            my $command = $_;
            $command =~ s/(\015|\012)//g;
            $self->log_msg(2, "Command: --$command--" );

            if ( $command =~ /$transparent/i ) {
                if ( $self->config('secure_server' ) ne '' ) {
                    if ( $mail = $self->verify_connected($mail, $client,
                            $self->config('secure_server' ),
                            $self->config('secure_port' ) ) ) {
                        last if ( $self->echo_response($mail, $client, $command ) == 2 );
                    } else {
                        next;
                    }
                } else {
                    $self->tee($client,
                        "-ERR Transparent proxying not configured: set secure server/port ( command you sent: '$command' )$eol" );
                }
                next;
            }

            if ( $command =~ /$user_command/i ) {
                if ( $1 ne '' ) {
                    my ( $host, $port, $user, $options ) = ( $1, $3, $4, $6 );

                    $self->mq_post('LOGIN', $user );

                    my $ssl = defined($options) && ( $options =~ /ssl/i );
                    $port = $ssl ? 995 : 110 if ( !defined($port) );

                    if ( $mail = $self->verify_connected($mail, $client, $host, $port, $ssl ) ) {
                        if ( defined($options) && ( $options =~ /apop/i ) ) {
                            $apop_banner = $1
                                if $self->connect_banner() =~ /(<[^>]+>)/;
                            $self->log_msg(2, "banner=" . $apop_banner )
                                if defined( $apop_banner );

                            if ( defined( $apop_banner ) ) {
                                $use_apop  = 1;
                                $apop_user = $user;
                                $self->tee($client, "+OK hello $user$eol" );
                                next;
                            } else {
                                $use_apop = 0;
                                $self->tee($client,
                                    "-ERR $host doesn't support APOP, aborting authentication$eol" );
                                next;
                            }
                        } else {
                            $use_apop = 0;
                            last if ( $self->echo_response($mail, $client, 'USER ' . $user ) == 2 );
                        }
                    } else {
                        next;
                    }
                }
                next;
            }

            if ( $command =~ /PASS (.*)/i ) {
                if ( $use_apop ) {
                    my $md5 = Digest::MD5->new;
                    $md5->add( $apop_banner, $1 );
                    my $md5hex = $md5->hexdigest;
                    $self->log_msg(2, "digest='$md5hex'" );

                    my ( $response, $ok ) = $self->get_response($mail, $client,
                        "APOP $apop_user $md5hex", 0, 1 );
                    if ( ( $ok == 1 ) && ( $response =~ /$self->good_response()/ ) ) {
                        $self->tee($client, "+OK password ok$eol" );
                    } else {
                        $self->tee($client, $response );
                    }
                } else {
                    last if ( $self->echo_response($mail, $client, $command ) == 2 );
                }
                next;
            }

            if ( $command =~ /$apop_command/io ) {
                $self->tee($client,
                    "-ERR APOP not supported between mail client and POPFile.$eol" );
                next;
            }

            if ( $command =~ /AUTH ([^ ]+)/i ) {
                if ( $self->config('secure_server' ) ne '' ) {
                    if ( $mail = $self->verify_connected($mail, $client,
                            $self->config('secure_server' ),
                            $self->config('secure_port' ) ) ) {
                        my ( $response, $ok ) = $self->get_response($mail, $client, $command );
                        while ( ( !( $response =~ /\+OK/ ) ) && ( !( $response =~ /-ERR/ ) ) ) {
                            my $auth = <$client>;
                            $auth =~ s/(\015|\012)$//g;
                            ( $response, $ok ) = $self->get_response($mail, $client, $auth );
                        }
                    } else {
                        next;
                    }
                } else {
                    $self->tee($client, "-ERR No secure server specified$eol" );
                }
                next;
            }

            if ( $command =~ /AUTH/i ) {
                if ( $self->config('secure_server' ) ne '' ) {
                    if ( $mail = $self->verify_connected($mail, $client,
                            $self->config('secure_server' ),
                            $self->config('secure_port' ) ) ) {
                        my $response = $self->echo_response($mail, $client, "AUTH" );
                        last if ( $response == 2 );
                        if ( $response == 0 ) {
                            $self->echo_to_dot($mail, $client );
                        }
                    } else {
                        next;
                    }
                } else {
                    $self->tee($client, "-ERR No secure server specified$eol" );
                }
                next;
            }

            if ( ( $command =~ /LIST ?(.*)?/i ) ||
                 ( $command =~ /UIDL ?(.*)?/i ) ) {
                my $response = $self->echo_response($mail, $client, $command );
                last if ( $response == 2 );
                if ( $response == 0 ) {
                    $self->echo_to_dot($mail, $client ) if ( $1 eq '' );
                }
                next;
            }

            if ( $command =~ /TOP (.*) (.*)/i ) {
                my $count = $1;
                if ( $2 ne '99999999' ) {
                    if ( $self->config('toptoo' ) == 1 ) {
                        my $response = $self->echo_response($mail, $client, "RETR $count" );
                        last if ( $response == 2 );
                        if ( $response == 0 ) {
                            my ( $class, $slot ) = $self->set_service()->classify_message(
                                $mail, $client, 0, '', 0, 0, $eol );
                            $downloaded{$count}{slot}  = $slot;
                            $downloaded{$count}{class} = $class;

                            $response = $self->echo_response($mail, $client, $command, 1 );
                            last if ( $response == 2 );
                            if ( $response == 0 ) {
                                $self->set_service()->classify_message(
                                    $mail, $client, 1, $class, $slot, 1, $eol );
                            }
                        }
                    } else {
                        my $response = $self->echo_response($mail, $client, $command );
                        last if ( $response == 2 );
                        if ( $response == 0 ) {
                            $self->echo_to_dot($mail, $client );
                        }
                    }
                    next;
                }
                # fall through: TOP x 99999999 treated as RETR
            }

            if ( $command =~ /CAPA/i ) {
                if ( $mail || $self->config('secure_server' ) ne '' ) {
                    if ( $mail || ( $mail = $self->verify_connected($mail, $client,
                                       $self->config('secure_server' ),
                                       $self->config('secure_port' ) ) ) ) {
                        my $response = $self->echo_response($mail, $client, "CAPA" );
                        last if ( $response == 2 );
                        if ( $response == 0 ) {
                            $self->echo_to_dot($mail, $client );
                        }
                    } else {
                        next;
                    }
                } else {
                    $self->tee($client, "-ERR No secure server specified$eol" );
                }
                next;
            }

            if ( $command =~ /HELO/i ) {
                $self->tee($client, "+OK HELO POPFile Server Ready$eol" );
                next;
            }

            if ( ( $command =~ /NOOP/i )         ||
                 ( $command =~ /STAT/i )          ||
                 ( $command =~ /XSENDER (.*)/i )  ||
                 ( $command =~ /DELE (.*)/i )     ||
                 ( $command =~ /RSET/i ) ) {
                last if ( $self->echo_response($mail, $client, $command ) == 2 );
                next;
            }

            if ( ( $command =~ /RETR (.*)/i ) || ( $command =~ /TOP (.*) 99999999/i ) ) {
                my $count = $1;
                my $class;

                my $history = $self->set_service()->history_obj();
                my $file;

                if ( defined( $downloaded{$count} ) &&
                     ( $file = $history->get_slot_file( $downloaded{$count}{slot} ) ) &&
                     ( open my $retrfile, '<', $file ) ) {
                    binmode $retrfile;
                    $self->log_msg(1, "Printing message from cache" );
                    $self->tee($client,
                        "+OK " . ( -s $file ) . " bytes from POPFile cache$eol" );

                    ( $class, undef ) = $self->set_service()->classify_message(
                        $retrfile, $client, 1,
                        $downloaded{$count}{class},
                        $downloaded{$count}{slot}, undef, $eol );
                    print $client ".$eol";
                    close $retrfile;
                } else {
                    my $response = $self->echo_response($mail, $client, $command );
                    last if ( $response == 2 );
                    if ( $response == 0 ) {
                        my $slot;
                        ( $class, $slot ) = $self->set_service()->classify_message(
                            $mail, $client, 0, '', 0, undef, $eol );
                        $downloaded{$count}{slot}  = $slot;
                        $downloaded{$count}{class} = $class;
                    }
                }
                next;
            }

            if ( $command =~ /QUIT/i ) {
                if ( $mail ) {
                    last if ( $self->echo_response($mail, $client, $command ) == 2 );
                    close $mail;
                } else {
                    $self->tee($client, "+OK goodbye$eol" );
                }
                last;
            }

            if ( $mail && $mail->connected ) {
                last if ( $self->echo_response($mail, $client, $command ) == 2 );
                next;
            } else {
                $self->tee($client, "-ERR unknown command or bad syntax$eol" );
                next;
            }
        }

        if ( defined($mail) ) {
            $self->done_slurp($mail );
            close $mail;
        }

        close $client;
        $self->mq_post('CMPLT', $$ );
        $self->log_msg(0, "POP3 proxy done" );
    }

} # end class Proxy::POP3

1;
