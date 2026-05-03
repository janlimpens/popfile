# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Proxy::NNTP;

use Object::Pad;
use locale;

# A handy variable containing the value of an EOL for networks
my $eol = "\015\012";

class Proxy::NNTP :isa(Proxy::Proxy);

=head1 NAME

Proxy::NNTP — NNTP proxy that classifies news articles with POPFile

=head1 DESCRIPTION

C<Proxy::NNTP> extends L<Proxy::Proxy> to intercept NNTP sessions between a
news reader and a real NNTP server.  It parses the extended
C<AUTHINFO USER server[:port]:username> syntax to determine the upstream
server, manages a three-state authentication handshake (username needed →
password needed → connected), and classifies each fetched article via the
classifier service.

Supports C<ARTICLE>, C<HEAD>, C<BODY>, and the full set of NNTP read commands.
Disabled by default (C<enabled = 0>).

=head1 METHODS

=head2 initialize()

Registers NNTP-specific configuration parameters: C<port> (default 119),
C<local>, C<headtoo>, C<separator>, and C<welcome_string>.  Forces
C<enabled> to 0 after calling C<< Proxy::Proxy->initialize() >>.

=cut

BUILD {
        $self->set_name('nntp');
        $self->set_connection_timeout_error('500 no response from mail server');
        $self->set_connection_failed_error('500 can\'t connect to');
        $self->set_good_response('^(1|2|3)\d\d');
    }

    # ----------------------------------------------------------------------------
    method initialize() {
        $self->config('enabled',        0);
        $self->config('port',           119);
        $self->config('local',          1);
        $self->config('headtoo',        0);
        $self->config('separator',      ':');
        $self->config('welcome_string',
            "NNTP POPFile (" . $self->version() . ") server ready");

        if (!$self->SUPER::initialize()) {
            return 0;
        }

        $self->config('enabled', 0);
        return 1;
    }

=head2 start()

Skips startup (returns 2) if the C<enabled> config flag is 0.  Otherwise
refreshes the C<welcome_string> if it still contains the old version token,
then calls C<< Proxy::Proxy->start() >> to open the listening socket.

=cut

    method start() {
        if ($self->config('enabled') == 0) {
            return 2;
        }

        if ($self->config('welcome_string') =~
             /^NNTP POPFile \(v\d+\.\d+\.\d+\) server ready$/) {
            $self->config('welcome_string',
                            "NNTP POPFile (" . $self->version() . ") server ready");
        }

        return $self->SUPER::start();
    }

=head2 child($client)

Handles one complete NNTP session for C<$client>.  Implements a three-state
machine (C<username needed> → C<password needed> / C<ignore password> →
C<connected>) driven by C<AUTHINFO USER> and C<AUTHINFO PASS> commands.
Once connected, relays C<ARTICLE>, C<HEAD>, C<BODY>, C<GROUP>, C<LIST>,
C<NEWGROUPS>, C<NEWNEWS>, C<XOVER>, and other standard NNTP commands,
classifying full articles via the classifier service.

=cut

    method child ($client) {
        my %downloaded;
        my $news;
        my $connection_state = 'username needed';

        $self->tee($client, "201 " . $self->config('welcome_string') . "$eol");

        while (<$client>) {
            my $command = $_;
            my ($response, $ok);
            $command =~ s/(\015|\012)//g;
            $self->log_msg(DEBUG => "Command: --$command--");

            if ($command =~ /^ *QUIT/i) {
                if ($news) {
                    last if ($self->echo_response($news, $client, $command) == 2);
                    close $news;
                } else {
                    $self->tee($client, "205 goodbye$eol");
                }
                last;
            }

            if ($connection_state eq 'username needed') {
                my $separator = $self->config('separator');
                my $user_command = "^ *AUTHINFO USER ([^:]+)(:([\\d]{1,5}))?(\\Q$separator\\E(.+))?";

                if ($command =~ /$user_command/i) {
                    my $server = $1;
                    my $port = (defined($3) && ($3 > 0) && ($3 < 65536)) ? $3 : undef;
                    my $username = $5;

                    if ($server ne '') {
                        if ($news = $self->verify_connected($news, $client,
                                                               $server,
                                                               $port || 119)) {
                            if (defined $username) {
                                $self->get_response($news, $client,
                                                      'AUTHINFO USER ' . $username);
                                $connection_state = "password needed";
                            } else {
                                $self->tee($client, "381 password$eol");
                                $connection_state = "ignore password";
                            }
                        } else {
                            last;
                        }
                    } else {
                        $self->tee($client,
                            "482 Authentication rejected server name not specified in AUTHINFO USER command$eol");
                        last;
                    }

                    $self->flush_extra($news, $client, 0);
                } else {
                    $self->tee($client, "480 Authorization required for this command$eol");
                }
                next;
            }

            if ($connection_state eq "password needed") {
                if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
                    ($response, $ok) = $self->get_response($news, $client, $command);
                    if ($response =~ /^281 .*/) {
                        $connection_state = "connected";
                    }
                } else {
                    $self->tee($client, "381 more authentication required for this command$eol");
                }
                next;
            }

            if ($connection_state eq "ignore password") {
                if ($command =~ /^ *AUTHINFO PASS (.*)/i) {
                    $self->tee($client, "281 authentication accepted$eol");
                    $connection_state = "connected";
                } else {
                    $self->tee($client, "381 more authentication required for this command$eol");
                }
                next;
            }

            if ($connection_state eq "connected") {
                my $message_id;
                my $history = $self->set_classifier_service()->history_obj();

                if ($command =~ /^ *ARTICLE ?(.*)?/i) {
                    my $file;

                    if ($1 =~ /^\d*$/) {
                        ($message_id, $response) =
                            $self->get_message_id($news, $client, $command);
                        unless (defined $message_id) {
                            $self->tee($client, $response);
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if (defined($downloaded{$message_id}) &&
                         ($file = $history->get_slot_file(
                               $downloaded{$message_id}{slot})) &&
                         (open my $retrfile, '<', $file)) {
                        binmode $retrfile;
                        $self->log_msg(INFO => "Printing message from cache");
                        $self->tee($client, "220 0 $message_id$eol");

                        (my $class, undef) = $self->set_classifier_service()->classify_message(
                            $retrfile, $client, 1,
                            $downloaded{$message_id}{class},
                            $downloaded{$message_id}{slot}, undef, $eol);
                        print $client ".$eol";
                        close $retrfile;
                    } else {
                        ($response, $ok) = $self->get_response($news, $client, $command);
                        if ($response =~ /^220 +(\d+) +([^ \015]+)/i) {
                            $message_id = $2;
                            my ($class, $history_file) = $self->set_classifier_service()->classify_message(
                                $news, $client, 0, '', 0, undef, $eol);
                            $downloaded{$message_id}{slot} = $history_file;
                            $downloaded{$message_id}{class} = $class;
                        }
                    }
                    next;
                }

                if ($command =~ /^ *HEAD ?(.*)?/i) {
                    if ($1 =~ /^\d*$/) {
                        ($message_id, $response) =
                            $self->get_message_id($news, $client, $command);
                        unless (defined $message_id) {
                            $self->tee($client, $response);
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if ($self->config('headtoo')) {
                        my ($class, $history_file);
                        my $cached = 0;

                        if (defined($downloaded{$message_id})) {
                            $cached = 1;
                            $class = $downloaded{$message_id}{class};
                            $history_file = $downloaded{$message_id}{slot};
                        } else {
                            my $article_command = $command;
                            $article_command =~ s/^ *HEAD/ARTICLE/i;
                            ($response, $ok) = $self->get_response($news, $client,
                                                                        $article_command, 0, 1);
                            if ($response =~ /^220 +(\d+) +([^ \015]+)/i) {
                                $message_id = $2;
                                $response =~ s/^220/221/;
                                $self->tee($client, "$response");

                                ($class, $history_file) = $self->set_classifier_service()->classify_message(
                                    $news, undef, 0, '', 0, 0, $eol);
                                $downloaded{$message_id}{slot} = $history_file;
                                $downloaded{$message_id}{class} = $class;
                            } else {
                                $self->tee($client, "$response");
                                next;
                            }
                        }

                        ($response, $ok) = $self->get_response($news, $client,
                                                                    $command, 0,
                                                                    ($cached ? 0 : 1));
                        if ($response =~ /^221 +(\d+) +([^ ]+)/i) {
                            $self->set_classifier_service()->classify_message(
                                $news, $client, 1, $class, $history_file, 1, $eol);
                        }
                        next;
                    }
                }

                if ($command =~ /^ *BODY ?(.*)?/i) {
                    my $file;

                    if ($1 =~ /^\d*$/) {
                        ($message_id, $response) =
                            $self->get_message_id($news, $client, $command);
                        unless (defined $message_id) {
                            $self->tee($client, $response);
                            next;
                        }
                    } else {
                        $message_id = $1;
                    }

                    if (defined($downloaded{$message_id}) &&
                         ($file = $history->get_slot_file(
                               $downloaded{$message_id}{slot})) &&
                         (open my $retrfile, '<', $file)) {
                        binmode $retrfile;
                        $self->log_msg(INFO => "Printing message from cache");
                        $self->tee($client, "222 0 $message_id$eol");

                        while (my $line = $self->slurp($retrfile)) {
                            last if ($line =~ /^[\015\012]+$/);
                        }
                        $self->echo_to_dot($retrfile, $client);
                        print $client ".$eol";
                        close $retrfile;
                    } else {
                        my $article_command = $command;
                        $article_command =~ s/^ *BODY/ARTICLE/i;
                        ($response, $ok) = $self->get_response($news, $client,
                                                                    $article_command, 0, 1);
                        if ($response =~ /^220 +(\d+) +([^ \015]+)/i) {
                            $message_id = $2;
                            $response =~ s/^220/222/;
                            $self->tee($client, "$response");

                            my ($class, $history_file) = $self->set_classifier_service()->classify_message(
                                $news, undef, 0, '', 0, 0, $eol);
                            $downloaded{$message_id}{slot} = $history_file;
                            $downloaded{$message_id}{class} = $class;

                            ($response, $ok) = $self->get_response($news, $client,
                                                                        $command, 0, 1);
                            if ($response =~ /^222 +(\d+) +([^ ]+)/i) {
                                $self->echo_to_dot($news, $client, 0);
                            }
                        } else {
                            $self->tee($client, "$response");
                        }
                    }
                    next;
                }

                if ($command =~
                    /^[ ]*(LIST|HEAD|NEWGROUPS|NEWNEWS|LISTGROUP|XGTITLE|XINDEX|XHDR|
                         XOVER|XPAT|XROVER|XTHREAD)/ix) {
                    ($response, $ok) = $self->get_response($news, $client, $command);
                    if ($response =~ /^2\d\d/) {
                        $self->echo_to_dot($news, $client, 0);
                    }
                    next;
                }

                if ($command =~ /^ *(HELP)/i) {
                    ($response, $ok) = $self->get_response($news, $client, $command);
                    if ($response =~ /^1\d\d/) {
                        $self->echo_to_dot($news, $client, 0);
                    }
                    next;
                }

                if ($command =~ /^ *(GROUP|STAT|IHAVE|LAST|NEXT|SLAVE|MODE|XPATH)/i) {
                    $self->get_response($news, $client, $command);
                    next;
                }

                if ($command =~ /^ *(IHAVE|POST|XRELPIC)/i) {
                    ($response, $ok) = $self->get_response($news, $client, $command);
                    if ($response =~ /^3\d\d/) {
                        $self->echo_to_dot($client, $news, 0);
                        $self->get_response($news, $client, "$eol");
                    } else {
                        $self->tee($client, $response);
                    }
                    next;
                }
            }

            if ($command =~ /^ *$/) {
                if ($news && $news->connected) {
                    $self->get_response($news, $client, $command, 1);
                    next;
                }
            }

            if ($news && $news->connected) {
                $self->echo_response($news, $client, $command);
                next;
            } else {
                $self->tee($client, "500 unknown command or bad syntax$eol");
                last;
            }
        }

        if (defined($news)) {
            $self->done_slurp($news);
            close $news;
        }
        close $client;
        $self->log_msg(WARN => "NNTP proxy done");
    }

=head2 get_message_id($news, $client, $command)

Converts an C<ARTICLE>/C<HEAD>/C<BODY> command to a C<STAT> command and sends
it to C<$news> to resolve a numeric article number to its Message-ID.
Returns C<($message_id, $response)> on success or C<(undef, $response)> if
the server returns an error.

=cut

    method get_message_id ($news, $client, $command) {
        $command =~ s/^ *(ARTICLE|HEAD|BODY)/STAT/i;
        my ($response, $ok) = $self->get_response($news, $client, $command, 0, 1);
        if ($response =~ /^223 +(\d+) +([^ \015]+)/i) {
            return ($2, $response);
        } else {
            return (undef, $response);
        }
    }


1;
