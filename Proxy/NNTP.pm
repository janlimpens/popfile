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
        $self->set_name( 'nntp' );
        $self->set_child( \&child__ );
        $self->set_connection_timeout_error( '500 no response from mail server' );
        $self->set_connection_failed_error(  '500 can\'t connect to' );
        $self->set_good_response( '^(1|2|3)\d\d' );
    }

    # ----------------------------------------------------------------------------
    method initialize {
        $self->config('enabled',        0 );
        $self->config('force_fork',     1 );
        $self->config('port',           119 );
        $self->config('local',          1 );
        $self->config('headtoo',        0 );
        $self->config('separator',      ':' );
        $self->config('welcome_string',
            "NNTP POPFile ($self->version()) server ready" );

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

        if ( $self->config('welcome_string' ) =~
             /^NNTP POPFile \(v\d+\.\d+\.\d+\) server ready$/ ) {
            $self->config('welcome_string',
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
    method child ($client) {
        my %downloaded;
        my $news;
        my $connection_state = 'username needed';

        $self->tee($client, "201 " . $self->config('welcome_string' ) . "$eol" );

        while ( <$client> ) {
            my $command = $_;
            my ( $response, $ok );
            $command =~ s/(\015|\012)//g;
            $self->log_msg(2, "Command: --$command--" );

            if ( $command =~ /^ *QUIT/i ) {
                if ( $news ) {
                    last if ( $self->echo_response($news, $client, $command ) == 2 );
                    close $news;
                } else {
                    $self->tee($client, "205 goodbye$eol" );
                }
                last;
            }

            if ( $connection_state eq 'username needed' ) {
                my $separator    = $self->config('separator' );
                my $user_command = "^ *AUTHINFO USER ([^:]+)(:([\\d]{1,5}))?(\\Q$separator\\E(.+))?";

                if ( $command =~ /$user_command/i ) {
                    my $server   = $1;
                    my $port     = ( defined($3) && ($3 > 0) && ($3 < 65536) ) ? $3 : undef;
                    my $username = $5;

                    if ( $server ne '' ) {
                        if ( $news = $self->verify_connected($news, $client,
                                                               $server,
                                                               $port || 119 ) ) {
                            if ( defined $username ) {
                                $self->get_response($news, $client,
                                                      'AUTHINFO USER ' . $username );
                                $connection_state = "password needed";
                            } else {
                                $self->tee($client, "381 password$eol" );
                                $connection_state = "ignore password";
                            }
                        } else {
                            last;
                        }
                    } else {
                        $self->tee($client,
                            "482 Authentication rejected server name not specified in AUTHINFO USER command$eol" );
                        last;
                    }

                    $self->flush_extra($news, $client, 0 );
                } else {
                    $self->tee($client, "480 Authorization required for this command$eol" );
                }
                next;
            }

            if ( $connection_state eq "password needed" ) {
                if ( $command =~ /^ *AUTHINFO PASS (.*)/i ) {
                    ( $response, $ok ) = $self->get_response($news, $client, $command );
                    if ( $response =~ /^281 .*/ ) {
                        $connection_state = "connected";
                    }
                } else {
                    $self->tee($client, "381 more authentication required for this command$eol" );
                }
                next;
            }

            if ( $connection_state eq "ignore password" ) {
                if ( $command =~ /^ *AUTHINFO PASS (.*)/i ) {
                    $self->tee($client, "281 authentication accepted$eol" );
                    $connection_state = "connected";
                } else {
                    $self->tee($client, "381 more authentication required for this command$eol" );
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
                            $self->get_message_id($news, $client, $command );
                        if ( !defined($message_id) ) {
                            $self->tee($client, $response );
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
                        $self->log_msg(1, "Printing message from cache" );
                        $self->tee($client, "220 0 $message_id$eol" );

                        ( my $class, undef ) = $self->set_service()->classify_message(
                            $retrfile, $client, 1,
                            $downloaded{$message_id}{class},
                            $downloaded{$message_id}{slot}, undef, $eol );
                        print $client ".$eol";
                        close $retrfile;
                    } else {
                        ( $response, $ok ) = $self->get_response($news, $client, $command );
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
                            $self->get_message_id($news, $client, $command );
                        if ( !defined($message_id) ) {
                            $self->tee($client, $response );
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if ( $self->config('headtoo' ) ) {
                        my ( $class, $history_file );
                        my $cached = 0;

                        if ( defined( $downloaded{$message_id} ) ) {
                            $cached       = 1;
                            $class        = $downloaded{$message_id}{class};
                            $history_file = $downloaded{$message_id}{slot};
                        } else {
                            my $article_command = $command;
                            $article_command =~ s/^ *HEAD/ARTICLE/i;
                            ( $response, $ok ) = $self->get_response($news, $client,
                                                                        $article_command, 0, 1 );
                            if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                                $message_id = $2;
                                $response =~ s/^220/221/;
                                $self->tee($client, "$response" );

                                ( $class, $history_file ) = $self->set_service()->classify_message(
                                    $news, undef, 0, '', 0, 0, $eol );
                                $downloaded{$message_id}{slot}  = $history_file;
                                $downloaded{$message_id}{class} = $class;
                            } else {
                                $self->tee($client, "$response" );
                                next;
                            }
                        }

                        ( $response, $ok ) = $self->get_response($news, $client,
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
                            $self->get_message_id($news, $client, $command );
                        if ( !defined($message_id) ) {
                            $self->tee($client, $response );
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
                        $self->log_msg(1, "Printing message from cache" );
                        $self->tee($client, "222 0 $message_id$eol" );

                        while ( my $line = $self->slurp($retrfile ) ) {
                            last if ( $line =~ /^[\015\012]+$/ );
                        }
                        $self->echo_to_dot($retrfile, $client );
                        print $client ".$eol";
                        close $retrfile;
                    } else {
                        my $article_command = $command;
                        $article_command =~ s/^ *BODY/ARTICLE/i;
                        ( $response, $ok ) = $self->get_response($news, $client,
                                                                    $article_command, 0, 1 );
                        if ( $response =~ /^220 +(\d+) +([^ \015]+)/i ) {
                            $message_id = $2;
                            $response =~ s/^220/222/;
                            $self->tee($client, "$response" );

                            my ( $class, $history_file ) = $self->set_service()->classify_message(
                                $news, undef, 0, '', 0, 0, $eol );
                            $downloaded{$message_id}{slot}  = $history_file;
                            $downloaded{$message_id}{class} = $class;

                            ( $response, $ok ) = $self->get_response($news, $client,
                                                                        $command, 0, 1 );
                            if ( $response =~ /^222 +(\d+) +([^ ]+)/i ) {
                                $self->echo_to_dot($news, $client, 0 );
                            }
                        } else {
                            $self->tee($client, "$response" );
                        }
                    }
                    next;
                }

                if ( $command =~
                    /^[ ]*(LIST|HEAD|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|
                         XOVER|XPAT|XROVER|XTHREAD)/ix ) {
                    ( $response, $ok ) = $self->get_response($news, $client, $command );
                    if ( $response =~ /^2\d\d/ ) {
                        $self->echo_to_dot($news, $client, 0 );
                    }
                    next;
                }

                if ( $command =~ /^ *(HELP)/i ) {
                    ( $response, $ok ) = $self->get_response($news, $client, $command );
                    if ( $response =~ /^1\d\d/ ) {
                        $self->echo_to_dot($news, $client, 0 );
                    }
                    next;
                }

                if ( $command =~ /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i ) {
                    $self->get_response($news, $client, $command );
                    next;
                }

                if ( $command =~ /^ *(IHAVE|POST|XRELPIC)/i ) {
                    ( $response, $ok ) = $self->get_response($news, $client, $command );
                    if ( $response =~ /^3\d\d/ ) {
                        $self->echo_to_dot($client, $news, 0 );
                        $self->get_response($news, $client, "$eol" );
                    } else {
                        $self->tee($client, $response );
                    }
                    next;
                }
            }

            if ( $command =~ /^ *$/ ) {
                if ( $news && $news->connected ) {
                    $self->get_response($news, $client, $command, 1 );
                    next;
                }
            }

            if ( $news && $news->connected ) {
                $self->echo_response($news, $client, $command );
                next;
            } else {
                $self->tee($client, "500 unknown command or bad syntax$eol" );
                last;
            }
        }

        if ( defined($news) ) {
            $self->done_slurp($news );
            close $news;
        }
        close $client;
        $self->mq_post('CMPLT', $$ );
        $self->log_msg(0, "NNTP proxy done" );
    }

    # ----------------------------------------------------------------------------
    method get_message_id ($news, $client, $command) {
        $command =~ s/^ *(ARTICLE|HEAD|BODY)/STAT/i;
        my ( $response, $ok ) = $self->get_response($news, $client, $command, 0, 1 );
        if ( $response =~ /^223 +(\d+) +([^ \015]+)/i ) {
            return ( $2, $response );
        } else {
            return ( undef, $response );
        }
    }

} # end class Proxy::NNTP

1;
