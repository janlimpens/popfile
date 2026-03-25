package Proxy::SMTP;

# ----------------------------------------------------------------------------
#
# This module handles proxying the SMTP protocol for POPFile.
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
# ----------------------------------------------------------------------------

use Object::Pad;
use locale;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

class Proxy::SMTP :isa(Proxy::Proxy) {
    BUILD {
        $self->set_name( 'smtp' );
        $self->set_child( \&child__ );
        $self->set_connection_timeout_error( '554 Transaction failed' );
        $self->set_connection_failed_error(  '554 Transaction failed, can\'t connect to' );
        $self->set_good_response( '^[23]' );
    }

    # ----------------------------------------------------------------------------
    method initialize {
        $self->config('force_fork', 1 );
        $self->config('port', 25 );
        $self->config('chain_server', '' );
        $self->config('chain_port', 25 );
        $self->config('local', 1 );
        $self->config('welcome_string', "SMTP POPFile ($self->version()) welcome" );

        if ( !$self->SUPER::initialize() ) {
            return 0;
        }

        $self->config('enabled', 0 );
        return 1;
    }

    # ----------------------------------------------------------------------------
    method start {
        if ( $self->config('enabled' ) == 0 ) {
            return 2;
        }

        $self->register_configuration_item('configuration', 'smtp_fork_and_port',
                                             'smtp-configuration.thtml', $self );
        $self->register_configuration_item('security', 'smtp_local',
                                             'smtp-security-local.thtml', $self );
        $self->register_configuration_item('chain', 'smtp_server',
                                             'smtp-chain-server.thtml', $self );
        $self->register_configuration_item('chain', 'smtp_server_port',
                                             'smtp-chain-server-port.thtml', $self );

        if ( $self->config('welcome_string' ) =~ /^SMTP POPFile \(v\d+\.\d+\.\d+\) welcome$/ ) {
            $self->config('welcome_string', "SMTP POPFile ($self->version()) welcome" );
        }

        return $self->SUPER::start();
    }

    # ----------------------------------------------------------------------------
    #
    # child__
    #
    # $self   - this Proxy::SMTP object
    # $client - an open stream to an SMTP client
    #
    # ----------------------------------------------------------------------------
    method child ($client) {
        my $count = 0;
        my $mail;

        $self->tee($client, "220 " . $self->config('welcome_string' ) . "$eol" );

        while ( <$client> ) {
            my $command = $_;
            $command =~ s/(\015|\012)//g;
            $self->log_msg(2, "Command: --$command--" );

            if ( $command =~ /HELO/i ) {
                if ( $self->config('chain_server' ) ) {
                    if ( $mail = $self->verify_connected($mail, $client,
                            $self->config('chain_server' ),
                            $self->config('chain_port' ) ) ) {
                        $self->smtp_echo_response($mail, $client, $command );
                    } else {
                        last;
                    }
                } else {
                    $self->tee($client, "421 service not available$eol" );
                }
                next;
            }

            if ( $command =~ /EHLO/i ) {
                if ( $self->config('chain_server' ) ) {
                    if ( $mail = $self->verify_connected($mail, $client,
                            $self->config('chain_server' ),
                            $self->config('chain_port' ) ) ) {
                        my $unsupported = qr/250\-CHUNKING|BINARYMIME|XEXCH50/;
                        $self->smtp_echo_response($mail, $client, $command, $unsupported );
                    } else {
                        last;
                    }
                } else {
                    $self->tee($client, "421 service not available$eol" );
                }
                next;
            }

            if ( ( $command =~ /MAIL FROM:/i ) ||
                 ( $command =~ /RCPT TO:/i )   ||
                 ( $command =~ /VRFY/i )        ||
                 ( $command =~ /EXPN/i )        ||
                 ( $command =~ /NOOP/i )        ||
                 ( $command =~ /HELP/i )        ||
                 ( $command =~ /RSET/i ) ) {
                $self->smtp_echo_response($mail, $client, $command );
                next;
            }

            if ( $command =~ /DATA/i ) {
                if ( $self->smtp_echo_response($mail, $client, $command ) ) {
                    $count += 1;
                    my ( $class, $history_file ) = $self->set_service()->classify_message(
                        $client, $mail, 0, '', 0, undef, $eol );
                    my $response = $self->slurp($mail );
                    $self->tee($client, $response );
                    next;
                }
            }

            if ( $command =~ /QUIT/i ) {
                if ( $mail ) {
                    $self->smtp_echo_response($mail, $client, $command );
                    close $mail;
                } else {
                    $self->tee($client, "221 goodbye$eol" );
                }
                last;
            }

            if ( $mail && $mail->connected ) {
                $self->smtp_echo_response($mail, $client, $command );
                next;
            } else {
                $self->tee($client, "500 unknown command or bad syntax$eol" );
                last;
            }
        }

        if ( defined($mail) ) {
            $self->done_slurp($mail );
            close $mail;
        }

        close $client;
        $self->mq_post('CMPLT', $$ );
        $self->log_msg(0, "SMTP proxy done" );
    }

    # ----------------------------------------------------------------------------
    method smtp_echo_response ($mail, $client, $command, $suppress = undef) {
        my ( $response, $ok ) = $self->get_response($mail, $client, $command );
        if ( $response =~ /^\d\d\d-/ ) {
            $self->echo_to_regexp($mail, $client, qr/^\d\d\d /, 1, $suppress );
        }
        return ( $response =~ /$self->good_response()/ );
    }

    # ----------------------------------------------------------------------------
    method configure_item ($name, $templ, $language = undef) {
        if ( $name eq 'smtp_fork_and_port' ) {
            $templ->param( 'smtp_port'           => $self->config('port' ) );
            $templ->param( 'smtp_force_fork_on'  => $self->config('force_fork' ) );
        } elsif ( $name eq 'smtp_local' ) {
            $templ->param( 'smtp_local_on' => $self->config('local' ) );
        } elsif ( $name eq 'smtp_server' ) {
            $templ->param( 'smtp_chain_server' => $self->config('chain_server' ) );
        } elsif ( $name eq 'smtp_server_port' ) {
            $templ->param( 'smtp_chain_port' => $self->config('chain_port' ) );
        } else {
            $self->SUPER::configure_item( $name, $templ );
        }
    }

    # ----------------------------------------------------------------------------
    method validate_item ($name, $templ, $language, $form) {
        if ( $name eq 'smtp_fork_and_port' ) {
            if ( defined( $$form{smtp_force_fork} ) ) {
                $self->config('force_fork', $$form{smtp_force_fork} );
            }
            if ( defined( $$form{smtp_port} ) ) {
                if ( ( $$form{smtp_port} >= 1 ) && ( $$form{smtp_port} < 65536 ) ) {
                    $self->config('port', $$form{smtp_port} );
                    $templ->param( 'smtp_port_feedback' =>
                        sprintf( $$language{Configuration_SMTPUpdate}, $self->config('port' ) ) );
                } else {
                    $templ->param( 'smtp_port_feedback' =>
                        "<div class=\"error01\">$$language{Configuration_Error3}</div>" );
                }
            }
            return;
        }

        if ( $name eq 'smtp_local' ) {
            $self->config('local', $$form{smtp_local} ) if defined $$form{smtp_local};
            return;
        }

        if ( $name eq 'smtp_server' ) {
            if ( defined $$form{smtp_chain_server} ) {
                $self->config('chain_server', $$form{smtp_chain_server} );
                $templ->param( 'smtp_server_feedback' =>
                    sprintf( $$language{Security_SMTPServerUpdate}, $self->config('chain_server' ) ) );
            }
            return;
        }

        if ( $name eq 'smtp_server_port' ) {
            if ( defined $$form{smtp_chain_server_port} ) {
                if ( ( $$form{smtp_chain_server_port} >= 1 ) &&
                     ( $$form{smtp_chain_server_port} < 65536 ) ) {
                    $self->config('chain_port', $$form{smtp_chain_server_port} );
                    $templ->param( 'smtp_port_feedback' =>
                        sprintf( $$language{Security_SMTPPortUpdate}, $self->config('chain_port' ) ) );
                } else {
                    $templ->param( 'smtp_port_feedback' =>
                        "<div class=\"error01\">$$language{Security_Error1}</div>" );
                }
            }
            return;
        }

        $self->SUPER::validate_item( $name, $templ, $language, $form );
    }

} # end class Proxy::SMTP

1;
