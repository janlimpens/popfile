# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package Proxy::Proxy;

use Object::Pad;
use locale;

use IO::Handle;
use IO::Socket;
use IO::Select;

my $eol = "\015\012";

class Proxy::Proxy :isa(POPFile::Module);
    field $service = undef;

    field $connection_timeout_error :reader :writer = '';
    field $connection_failed_error :reader :writer = '';
    field $good_response :reader :writer = '';
    field $ssl_not_supported_error :reader = '-ERR SSL connection is not supported since required modules are not installed';

    field $connect_banner :reader :writer = '';

    field $server_id = undef;
    field $bound_port :reader = 0;

=head1 NAME

Proxy::Proxy — base class for POPFile proxy modules

=head1 DESCRIPTION

C<Proxy::Proxy> is the common foundation for all POPFile protocol proxies
(POP3, SMTP, NNTP).  A proxy sits between the mail client and the real mail
server: it listens on a local TCP port, accepts a client connection, opens a
corresponding connection to the upstream server, and relays commands and
responses in both directions.

Subclasses override the C<$child> coderef to implement protocol-specific
command handling.  The base class provides the listening socket lifecycle
(C<initialize>, C<start>, C<stop>), connection helpers, and
low-level I/O utilities used by all proxy implementations.

=head1 METHODS

=head2 initialize()

Registers configuration parameters: C<enabled>, C<port>, C<socks_server>,
and C<socks_port>.  Returns 1.

=cut

    method initialize() {
        $self->config('enabled', 1);
        $self->config('port',    0);

        $self->config('socks_server', '');
        $self->config('socks_port',   1080);

        return 1;
    }

=head2 start()

Opens a Mojo::IOLoop TCP server on the configured C<port>.  For each
incoming connection the raw filehandle is stolen from the Mojo stream and
handled in a C<Mojo::IOLoop> subprocess that calls C<$child>.  If the port
is 0, the OS chooses a free port; C<bound_port()> returns the actual port.
Returns 0 if the server cannot be started; 1 on success.

=cut

    method start() {
        require Mojo::IOLoop;
        $self->log_msg(INFO => "Opening listening socket on port " . $self->config('port') . '.');

        my $local = ($self->config('local') || 0) == 1;
        my %listen_args = (port => $self->config('port'));
        $listen_args{address} = '127.0.0.1' if $local;

        my $name = $self->name();

        $server_id = Mojo::IOLoop->server(
            \%listen_args,
            sub ($loop, $stream, $id) {
                my $fh = $stream->steal_handle();
                $loop->subprocess(
                    sub { $self->_handle_connection($fh) },
                    sub ($loop, $err, @result) {
                        $self->log_msg(INFO => "subprocess error: $err") if $err;
                    }
                );
            }
        );

        if (!defined $server_id) {
            my $port = $self->config('port');
            $self->log_msg(WARN => "Couldn't start the $name proxy because POPFile could not bind to the listen port $port");
            print STDERR "\nCouldn't start the $name proxy because POPFile could not bind to the\nlisten port $port. This could be because there is another service\nusing that port or because you do not have the right privileges on\nyour system (On Unix systems this can happen if you are not root\nand the port you specified is less than 1024).\n\n";
            return 0;
        }

        $bound_port = Mojo::IOLoop->acceptor($server_id)->port();
        $self->log_msg(INFO => "$name proxy listening on port $bound_port");
        return 1;
    }

=head2 _handle_connection($fh)

Runs inside a C<Mojo::IOLoop> subprocess.  Wraps the raw filehandle as an
C<IO::Socket> and calls the C<$child> coderef.

=cut

    method _handle_connection ($fh) {
        my $sock = IO::Socket->new();
        $sock->fdopen($fh, 'r+');
        binmode $sock;
        $self->child($sock);
    }

=head2 stop()

Removes the Mojo::IOLoop server.

=cut

    method stop() {
        Mojo::IOLoop->remove($server_id) if defined $server_id;
        $server_id = undef;
    }

=head2 tee($socket, $text)

Logs C<$text> at info level and sends it to C<$socket>.

=cut

    method tee ($socket, $text) {
        $self->log_msg(INFO => $text);
        print $socket $text;
    }

=head2 echo_to_regexp($mail, $client, $regexp, $log, $suppress)

Reads lines from C<$mail> and forwards them to C<$client> until a line
matching C<$regexp> is seen.  If C<$log> is true, each line is sent via
C<tee()> (logged) rather than a bare C<print>.  Lines matching C<$suppress>
are dropped silently.

=cut

    method echo_to_regexp ($mail, $client, $regexp, $log = 0, $suppress = undef) {
        while (my $line = $self->slurp($mail)) {
            if (!defined($suppress) || !($line =~ $suppress)) {
                if (!$log) {
                    print $client $line;
                } else {
                    $self->tee($client, $line);
                }
            } else {
                $self->log_msg(DEBUG => "Suppressed: $line");
            }

            if ($line =~ $regexp) {
                last;
            }
        }
    }

=head2 echo_to_dot($mail, $client)

Relays lines from C<$mail> to C<$client> until the SMTP/POP3 dot-stuffed
terminator (a bare C<.>) is received.  Delegates to C<echo_to_regexp>.

=cut

    method echo_to_dot ($mail, $client) {
        $self->echo_to_regexp($mail, $client, qr/^\.(\r\n|\r|\n)$/);
    }

=head2 get_response($mail, $client, $command, $null_resp, $suppress)

Sends C<$command> to C<$mail> (the upstream server) and reads back one line of
response, forwarding it to C<$client> unless C<$suppress> is set.  Waits up
to the global C<timeout> for a reply; if C<$null_resp> is true a short timeout
is used and an empty response is treated as success.  Returns
C<($response, 1)> on success or C<($connection_timeout_error, 0)> on failure.

=cut

    method get_response ($mail, $client, $command, $null_resp = 0, $suppress = 0) {
        unless (defined($mail) && $mail->connected) {
            $self->tee($client, "$connection_timeout_error$eol");
            return ($connection_timeout_error, 0);
        }

        $self->tee($mail, $command . $eol);

        my $response;
        my $can_read = 0;

        if ($mail =~ /ssl/i) {
            $can_read = ($mail->pending() > 0);
        }
        if (!$can_read) {
            my $selector = IO::Select->new($mail);
            my ($ready) = $selector->can_read(
                (!$null_resp ? $self->global_config('timeout') : .5));
            $can_read = defined($ready) && ($ready == $mail);
        }

        if ($can_read) {
            $response = $self->slurp($mail);

            if ($response) {
                $self->tee($client, $response) if (!$suppress);
                return ($response, 1);
            }
        }

        if (!$null_resp) {
            $self->tee($client, "$connection_timeout_error$eol");
            return ($connection_timeout_error, 0);
        } else {
            $self->tee($client, "");
            return ("", 1);
        }
    }

=head2 echo_response($mail, $client, $command, $suppress)

Sends C<$command> and checks the single-line response against
C<$good_response>.  Returns 0 if the response matches (success), 1 if it
does not match, or 2 if no response was received.

=cut

    method echo_response ($mail, $client, $command, $suppress = 0) {
        my ($response, $ok) = $self->get_response($mail, $client, $command, 0, $suppress);

        if ($ok == 1) {
            if ($response =~ /$good_response/) {
                return 0;
            } else {
                return 1;
            }
        } else {
            return 2;
        }
    }

=head2 verify_connected($mail, $client, $hostname, $port, $ssl)

Returns C<$mail> unchanged if it is already connected.  Otherwise opens a new
TCP (or SSL) connection to C<$hostname:$port>, optionally via a SOCKS proxy.
Reads and stores the server's connect banner in C<$connect_banner>.  Returns
the connected socket on success, C<undef> on failure.

=cut

    method verify_connected ($mail, $client, $hostname, $port, $ssl = 0) {
        return $mail if ($mail && $mail->connected);

        if ($self->config('socks_server') ne '') {
            require IO::Socket::Socks;
            $self->log_msg(WARN => "Attempting to connect to socks server at "
                        . $self->config('socks_server') . ":"
                        . $self->config('socks_port'));

            $mail = IO::Socket::Socks->new(
                        ProxyAddr => $self->config('socks_server'),
                        ProxyPort => $self->config('socks_port'),
                        ConnectAddr => $hostname,
                        ConnectPort => $port);
        } else {
            if ($ssl) {
                eval { require IO::Socket::SSL; };
                if ($@) {
                    $self->tee($client, "$ssl_not_supported_error$eol");
                    return;
                }

                $self->log_msg(WARN => "Attempting to connect to SSL server at $hostname:$port");

                $mail = IO::Socket::SSL->new(
                            Proto => "tcp",
                            PeerAddr => $hostname,
                            PeerPort => $port,
                            Timeout => $self->global_config('timeout'),
                            Domain => AF_INET);
            } else {
                $self->log_msg(WARN => "Attempting to connect to POP server at $hostname:$port");

                $mail = IO::Socket::INET->new(
                            Proto => "tcp",
                            PeerAddr => $hostname,
                            PeerPort => $port,
                            Timeout => $self->global_config('timeout'));
            }
        }

        if ($mail) {
            if ($mail->connected) {
                $self->log_msg(WARN => "Connected to $hostname:$port timeout " . $self->global_config('timeout'));

                if (!$ssl) {
                    binmode($mail);
                }

                if (!$ssl || ($mail->pending() == 0)) {
                    my $selector = IO::Select->new($mail);
                    last unless $selector->can_read($self->global_config('timeout'));
                }

                my $buf = '';
                my $max_length = 8192;
                my $n = sysread($mail, $buf, $max_length, length $buf);

                if (!($buf =~ /[\r\n]/)) {
                    my $hit_newline = 0;
                    my $temp_buf;
                    my $wait = 0;

                    for my $i (0..($self->global_config('timeout') * 100)) {
                        if (!$hit_newline) {
                            $temp_buf = $self->flush_extra($mail, $client, 1);
                            $hit_newline = ($temp_buf =~ /[\r\n]/);
                            $buf        .= $temp_buf;
                            if ($wait && !length $temp_buf) {
                                select undef, undef, undef, 0.01;
                            }
                        } else {
                            last;
                        }
                    }
                }

                $self->log_msg(INFO => "Connection returned: $buf");

                if ($buf eq '') {
                    close $mail;
                    last;
                }

                $connect_banner = $buf;

                for my $i (0..4) {
                    $self->flush_extra($mail, $client, 1);
                }

                return $mail;
            }
        }

        $self->log_msg(WARN => "IO::Socket::INET or IO::Socket::SSL gets an error: $@");
        $self->tee($client, "$connection_failed_error $hostname:$port$eol");
        return;
    }

=head2 set_service($svc)

Sets the classifier service reference used by subclasses to classify messages.
Returns the current service.

=cut

    method set_service ($svc = undef) {
        $service = $svc if defined $svc;
        return $service
    }

    method child ($client) {}


1;

