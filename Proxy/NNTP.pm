# POPFILE LOADABLE MODULE
package Proxy::NNTP;

# ----------------------------------------------------------------------------
#
# This module handles proxying the NNTP protocol for POPFile.
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

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

class Proxy::NNTP :isa(Proxy::Proxy) {

    BUILD {
        $self->name( 'nntp' );
        $self->child( \&child__ );
        $self->connection_timeout_error( '500 no response from mail server' );
        $self->connection_failed_error(  '500 can\'t connect to' );
        $self->good_response( '^(1|2|3)\d\d' );
    }

    # ----------------------------------------------------------------------------
    method initialize {
        $self->config_( 'enabled',        0 );
        $self->config_( 'force_fork',     1 );
        $self->config_( 'port',           119 );
        $self->config_( 'local',          1 );
        $self->config_( 'headtoo',        0 );
        $self->config_( 'separator',      ':' );
        $self->config_( 'welcome_string',
            "NNTP POPFile ($self->version()) server ready" );

        if ( !$self->SUPER::initialize() ) {
            return 0;
        }

        $self->config_( 'enabled', 0 );
        return 1;
    }

    # ----------------------------------------------------------------------------
    method start {
        if ( $self->config_( 'enabled' ) == 0 ) {
            return 2;
        }

        $self->register_configuration_item_( 'configuration', 'nntp_port',
                                             'nntp-port.thtml', $self );
        $self->register_configuration_item_( 'configuration', 'nntp_force_fork',
                                             'nntp-force-fork.thtml', $self );
        $self->register_configuration_item_( 'configuration', 'nntp_separator',
                                             'nntp-separator.thtml', $self );
        $self->register_configuration_item_( 'security', 'nntp_local',
                                             'nntp-security-local.thtml', $self );

        if ( $self->config_( 'welcome_string' ) =~
             /^NNTP POPFile \(v\d+\.\d+\.\d+\) server ready$/ ) {
            $self->config_( 'welcome_string',
                            "NNTP POPFile ($self->version()) server ready" );
        }

        return $self->SUPER::start();
    }

    # ----------------------------------------------------------------------------
    #
    # child__
    #
    # $self   - this Proxy::NNTP object
    # $client - an open stream to an NNTP client
    #
    # ----------------------------------------------------------------------------
    method child__ ($client) {
        my %downloaded;
        my $news;
        my $connection_state = 'username needed';

        $self->tee_( $client, "201 " . $self->config_( 'welcome_string' ) . "$eol" );

        while ( <$client> ) {
            my $command = $_;
            my ( $response, $ok );
            $command =~ s/(\015|\012)//g;
            $self->log_( 2, "Command: --$command--" );

            if ( $command =~ /^ *QUIT/i ) {
                if ( $news ) {
                    last if ( $self->echo_response_( $news, $client, $command ) == 2 );
                    close $news;
                } else {
                    $self->tee_( $client, "205 goodbye$eol" );
                }
                last;
            }

            if ( $connection_state eq 'username needed' ) {
                my $separator    = $self->config_( 'separator' );
                my $user_command = "^ *AUTHINFO USER ([^:]+)(:([\\d]{1,5}))?(\\Q$separator\\E(.+))?";

                if ( $command =~ /$user_command/i ) {
                    my $server   = $1;
                    my $port     = ( defined($3) && ($3 > 0) && ($3 < 65536) ) ? $3 : undef;
                    my $username = $5;

                    if ( $server ne '' ) {
                        if ( $news = $self->verify_connected_( $news, $client,
                                                               $server,
                                                               $port || 119 ) ) {
                            if ( defined $username ) {
                                $self->get_response_( $news, $client,
                                                      'AUTHINFO USER ' . $username );
                                $connection_state = "password needed";
                            } else {
                                $self->tee_( $client, "381 password$eol" );
                                $connection_state = "ignore password";
                            }
                        } else {
                            last;
                        }
                    } else {
                        $self->tee_( $client,
                            "482 Authentication rejected server name not specified in AUTHINFO USER command$eol" );
                        last;
                    }

                    $self->flush_extra_( $news, $client, 0 );
                } else {
                    $self->tee_( $client, "480 Authorization required for this command$eol" );
                }
                next;
            }

            if ( $connection_state eq "password needed" ) {
                if ( $command =~ /^ *AUTHINFO PASS (.*)/i ) {
                    ( $response, $ok ) = $self->get_response_( $news, $client, $command );
                    if ( $response =~ /^281 .*/ ) {
                        $connection_state = "connected";
                    }
                } else {
                    $self->tee_( $client, "381 more authentication required for this command$eol" );
                }
                next;
            }

            if ( $connection_state eq "ignore password" ) {
                if ( $command =~ /^ *AUTHINFO PASS (.*)/i ) {
                    $self->tee_( $client, "281 authentication accepted$eol" );
                    $connection_state = "connected";
                } else {
                    $self->tee_( $client, "381 more authentication required for this command$eol" );
                }
                next;
            }

            if ( $connection_state eq "connected" ) {
                my $message_id;
                my $history = $self->set_service()->history_obj();

                if ( $command =~ /^ *ARTICLE ?(.*)?/i ) {
                    my $file;

                    if ( $1 =~ /^\d*$/ ) {
                        ( $message_id, $response ) =
                            $self->get_message_id_( $news, $client, $command );
                        if ( !defined($message_id) ) {
                            $self->tee_( $client, $response );
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if ( defined( $downloaded{$message_id} ) &&
                         ( $file = $history->get_slot_file(
                               $downloaded{$message_id}{slot} ) ) &&
                         ( open my $retrfile, '<', $file ) ) {

                        binmode $retrfile;
                        $self->log_( 1, "Printing message from cache" );
                        $self->tee_( $client, "220 0 $message_id$eol" );

                        ( my $class, undef ) = $self->set_service()->classify_message(
                            $retrfile, $client, 1,
                            $downloaded{$message_id}{class},
                            $downloaded{$message_id}{slot}, undef, $eol );
                        print $client ".$eol";
                        close $retrfile;
                    } else {
                        ( $response, $ok ) = $self->get_response_( $news, $client, $command );
                        if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                            $message_id = $2;
                            my ( $class, $history_file ) = $self->set_service()->classify_message(
                                $news, $client, 0, '', 0, undef, $eol );
                            $downloaded{$message_id}{slot}  = $history_file;
                            $downloaded{$message_id}{class} = $class;
                        }
                    }
                    next;
                }

                if ( $command =~ /^ *HEAD ?(.*)?/i ) {
                    if ( $1 =~ /^\d*$/ ) {
                        ( $message_id, $response ) =
                            $self->get_message_id_( $news, $client, $command );
                        if ( !defined($message_id) ) {
                            $self->tee_( $client, $response );
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if ( $self->config_( 'headtoo' ) ) {
                        my ( $class, $history_file );
                        my $cached = 0;

                        if ( defined( $downloaded{$message_id} ) ) {
                            $cached       = 1;
                            $class        = $downloaded{$message_id}{class};
                            $history_file = $downloaded{$message_id}{slot};
                        } else {
                            my $article_command = $command;
                            $article_command =~ s/^ *HEAD/ARTICLE/i;
                            ( $response, $ok ) = $self->get_response_( $news, $client,
                                                                        $article_command, 0, 1 );
                            if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                                $message_id = $2;
                                $response =~ s/^220/221/;
                                $self->tee_( $client, "$response" );

                                ( $class, $history_file ) = $self->set_service()->classify_message(
                                    $news, undef, 0, '', 0, 0, $eol );
                                $downloaded{$message_id}{slot}  = $history_file;
                                $downloaded{$message_id}{class} = $class;
                            } else {
                                $self->tee_( $client, "$response" );
                                next;
                            }
                        }

                        ( $response, $ok ) = $self->get_response_( $news, $client,
                                                                    $command, 0,
                                                                    ( $cached ? 0 : 1 ) );
                        if ( $response =~ /^221 +(\d+) +([^ ]+)/i ) {
                            $self->set_service()->classify_message(
                                $news, $client, 1, $class, $history_file, 1, $eol );
                        }
                        next;
                    }
                }

                if ( $command =~ /^ *BODY ?(.*)?/i ) {
                    my $file;

                    if ( $1 =~ /^\d*$/ ) {
                        ( $message_id, $response ) =
                            $self->get_message_id_( $news, $client, $command );
                        if ( !defined($message_id) ) {
                            $self->tee_( $client, $response );
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if ( defined( $downloaded{$message_id} ) &&
                         ( $file = $history->get_slot_file(
                               $downloaded{$message_id}{slot} ) ) &&
                         ( open my $retrfile, '<', $file ) ) {

                        binmode $retrfile;
                        $self->log_( 1, "Printing message from cache" );
                        $self->tee_( $client, "222 0 $message_id$eol" );

                        while ( my $line = $self->slurp_( $retrfile ) ) {
                            last if ( $line =~ /^[\015\012]+$/ );
                        }
                        $self->echo_to_dot_( $retrfile, $client );
                        print $client ".$eol";
                        close $retrfile;
                    } else {
                        my $article_command = $command;
                        $article_command =~ s/^ *BODY/ARTICLE/i;
                        ( $response, $ok ) = $self->get_response_( $news, $client,
                                                                    $article_command, 0, 1 );
                        if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                            $message_id = $2;
                            $response =~ s/^220/222/;
                            $self->tee_( $client, "$response" );

                            my ( $class, $history_file ) = $self->set_service()->classify_message(
                                $news, undef, 0, '', 0, 0, $eol );
                            $downloaded{$message_id}{slot}  = $history_file;
                            $downloaded{$message_id}{class} = $class;

                            ( $response, $ok ) = $self->get_response_( $news, $client,
                                                                        $command, 0, 1 );
                            if ( $response =~ /^222 +(\d+) +([^ ]+)/i ) {
                                $self->echo_to_dot_( $news, $client, 0 );
                            }
                        } else {
                            $self->tee_( $client, "$response" );
                        }
                    }
                    next;
                }

                if ( $command =~
                    /^[ ]*(LIST|HEAD|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|
                         XOVER|XPAT|XROVER|XTHREAD)/ix ) {
                    ( $response, $ok ) = $self->get_response_( $news, $client, $command );
                    if ( $response =~ /^2\d\d/ ) {
                        $self->echo_to_dot_( $news, $client, 0 );
                    }
                    next;
                }

                if ( $command =~ /^ *(HELP)/i ) {
                    ( $response, $ok ) = $self->get_response_( $news, $client, $command );
                    if ( $response =~ /^1\d\d/ ) {
                        $self->echo_to_dot_( $news, $client, 0 );
                    }
                    next;
                }

                if ( $command =~ /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i ) {
                    $self->get_response_( $news, $client, $command );
                    next;
                }

                if ( $command =~ /^ *(IHAVE|POST|XRELPIC)/i ) {
                    ( $response, $ok ) = $self->get_response_( $news, $client, $command );
                    if ( $response =~ /^3\d\d/ ) {
                        $self->echo_to_dot_( $client, $news, 0 );
                        $self->get_response_( $news, $client, "$eol" );
                    } else {
                        $self->tee_( $client, $response );
                    }
                    next;
                }
            }

            if ( $command =~ /^ *$/ ) {
                if ( $news && $news->connected ) {
                    $self->get_response_( $news, $client, $command, 1 );
                    next;
                }
            }

            if ( $news && $news->connected ) {
                $self->echo_response_( $news, $client, $command );
                next;
            } else {
                $self->tee_( $client, "500 unknown command or bad syntax$eol" );
                last;
            }
        }

        if ( defined($news) ) {
            $self->done_slurp_( $news );
            close $news;
        }
        close $client;
        $self->mq_post_( 'CMPLT', $$ );
        $self->log_( 0, "NNTP proxy done" );
    }

    # ----------------------------------------------------------------------------
    method get_message_id_ ($news, $client, $command) {
        $command =~ s/^ *(ARTICLE|HEAD|BODY)/STAT/i;
        my ( $response, $ok ) = $self->get_response_( $news, $client, $command, 0, 1 );
        if ( $response =~ /^223 +(\d+) +([^ \015]+)/i ) {
            return ( $2, $response );
        } else {
            return ( undef, $response );
        }
    }

    # ----------------------------------------------------------------------------
    method configure_item ($name, $templ, $language = undef) {
        if ( $name eq 'nntp_port' ) {
            $templ->param( 'nntp_port' => $self->config_( 'port' ) );
        } elsif ( $name eq 'nntp_separator' ) {
            $templ->param( 'nntp_separator' => $self->config_( 'separator' ) );
        } elsif ( $name eq 'nntp_local' ) {
            $templ->param( 'nntp_if_local' => $self->config_( 'local' ) );
        } elsif ( $name eq 'nntp_force_fork' ) {
            $templ->param( 'nntp_force_fork_on' => $self->config_( 'force_fork' ) );
        } else {
            $self->SUPER::configure_item( $name, $templ );
        }
    }

    # ----------------------------------------------------------------------------
    method validate_item ($name, $templ, $language, $form) {
        if ( $name eq 'nntp_port' ) {
            if ( defined $$form{nntp_port} ) {
                if ( ( $$form{nntp_port} =~ /^\d+$/ ) &&
                     ( $$form{nntp_port} >= 1 ) &&
                     ( $$form{nntp_port} <= 65535 ) ) {
                    $self->config_( 'port', $$form{nntp_port} );
                    $templ->param( 'nntp_port_feedback' =>
                        sprintf( $$language{Configuration_NNTPUpdate}, $self->config_( 'port' ) ) );
                } else {
                    $templ->param( 'nntp_port_feedback' =>
                        "<div class=\"error01\">$$language{Configuration_Error3}</div>" );
                }
            }
            return;
        }

        if ( $name eq 'nntp_separator' ) {
            if ( defined $$form{nntp_separator} ) {
                if ( length( $$form{nntp_separator} ) == 1 ) {
                    $self->config_( 'separator', $$form{nntp_separator} );
                    $templ->param( 'nntp_separator_feedback' =>
                        sprintf( $$language{Configuration_NNTPSepUpdate}, $self->config_( 'separator' ) ) );
                } else {
                    $templ->param( 'nntp_separator_feedback' =>
                        "<div class=\"error01\">\n$$language{Configuration_Error1}</div>\n" );
                }
            }
            return;
        }

        if ( $name eq 'nntp_local' ) {
            $self->config_( 'local', $$form{nntp_local} ) if defined $$form{nntp_local};
            return;
        }

        if ( $name eq 'nntp_force_fork' ) {
            $self->config_( 'force_fork', $$form{nntp_force_fork} )
                if defined $$form{nntp_force_fork};
            return;
        }

        $self->SUPER::validate_item( $name, $templ, $language, $form );
    }

} # end class Proxy::NNTP

1;
