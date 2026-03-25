package UI::HTTP;

#----------------------------------------------------------------------------
#
# This package contains an HTTP server used as a base class for other
# modules that service requests over HTTP (e.g. the UI)
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

use IO::Socket::INET qw(:DEFAULT :crlf);
use IO::Select;
use Date::Format qw(time2str);

my $eol = "\015\012";

class UI::HTTP :isa(POPFile::Module) {

    field $server      = undef;
    field $selector    = undef;
    field $url_handler = undef;
    field %form;
    field $history     = undef;

=head2 start

Opens the HTTP listening socket. Returns 1 on success, 0 if the port
cannot be bound.

=cut

    method start {
        $self->log_( 1, "Trying to open listening socket on port " . $self->config_('port') . '.' );
        $server = IO::Socket::INET->new(                             # PROFILE BLOCK START
                                Proto     => 'tcp',
                                $self->config_( 'local' ) == 1 ? (LocalAddr => 'localhost') : (),
                                LocalPort => $self->config_( 'port' ),
                                Listen    => SOMAXCONN,
                                Reuse     => 1 );                    # PROFILE BLOCK STOP

        if ( !defined( $server ) ) {
            my $port = $self->config_( 'port' );
            my $name = $self->name();
            $self->log_( 0, "Couldn't start the $name interface because POPFile could not bind to the listen port $port" );
            print STDERR <<EOM;                                      # PROFILE BLOCK START

\nCouldn't start the $name interface because POPFile could not bind to the
listen port $port. This could be because there is another service
using that port or because you do not have the right privileges on
your system (On Unix systems this can happen if you are not root
and the port you specified is less than 1024).

EOM
# PROFILE BLOCK STOP

            return 0;
        }

        $selector = IO::Select->new( $server );

        return 1;
    }

=head2 stop

Closes the HTTP listening socket.

=cut

    method stop {
        close $server if defined $server;
    }

=head2 service

Accepts one pending HTTP request and dispatches it via C<handle_url>.
Returns 1 normally, 0 to request POPFile shutdown.

=cut

    method service {
        my $code = 1;

        return $code if !defined $selector;

        my ( $ready ) = $selector->can_read(0);

        if ( ( defined( $ready ) ) && ( $ready == $server ) ) {

            if ( my $client = $server->accept() ) {

                my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

                if ( ( $self->config_( 'local' ) == 0 ) ||                # PROFILE BLOCK START
                     ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {     # PROFILE BLOCK STOP

                    $client->autoflush(1);

                    if ( ( defined( $client ) ) &&                          # PROFILE BLOCK START
                         ( my $request = $self->slurp_( $client ) ) ) {    # PROFILE BLOCK STOP
                        my $content_length = 0;
                        my $content        = '';
                        my $status_code    = 200;

                        $self->log_( 2, $request );

                        while ( my $line = $self->slurp_( $client ) ) {
                            $content_length = $1 if $line =~ /Content-Length: (\d+)/i;
                            last if $line !~ /:/;
                        }

                        if ( $content_length > 0 ) {
                            $content = $self->slurp_buffer_( $client,  # PROFILE BLOCK START
                                $content_length );                      # PROFILE BLOCK STOP
                            if ( !defined( $content ) ) {
                                $status_code = 400;
                            } else {
                                $self->log_( 2, $content );
                            }
                        }

                        if ( $status_code != 200 ) {
                            $self->http_error_( $client, $status_code );
                        } else {
                            if ( $request =~ /^(GET|POST) (.*) HTTP\/1\./i ) {
                                $code = $self->handle_url( $client, $2, $1, $content );
                                $self->log_( 2,                                    # PROFILE BLOCK START
                                    "HTTP handle_url returned code $code\n" );     # PROFILE BLOCK STOP
                            } else {
                                $self->http_error_( $client, 500 );
                            }
                        }
                    }
                }

                $self->log_( 2, "Close HTTP connection on $client\n" );
                $self->done_slurp_( $client );
                close $client;
            }
        }

        return $code;
    }

=head2 forked

Called when POPFile forks; closes the server socket in the child.

=cut

    method forked ($writer = undef) {
        close $server;
    }

=head2 handle_url

Dispatches an incoming HTTP request to the registered C<url_handler>.

=cut

    method handle_url ($client, $url, $command, $content) {
        return $url_handler->( $self, $client, $url, $command, $content );
    }

=head2 parse_form_

Parses URL-encoded form data and populates the C<%form> hash.

=cut

    method parse_form_ ($arguments) {
        return if !defined $arguments;

        $arguments =~ s/&amp;/&/g;

        while ( $arguments =~ m/\G(.*?)=(.*?)(&|\r|\n|$)/g ) {
            my $arg = $1;

            my $need_array = defined( $form{$arg} );

            if ( $need_array ) {
                if ( $#{ $form{$arg . "_array"} } == -1 ) {
                    push( @{ $form{$arg . "_array"} }, $form{$arg} );
                }
            }

            $form{$arg} = $2;
            $form{$arg} =~ s/\+/ /g;
            $form{$arg} =~ s/%([0-9A-F][0-9A-F])/chr hex $1/gie;

            if ( $need_array ) {
                push( @{ $form{$arg . "_array"} }, $form{$arg} );
            }
        }
    }

=head2 url_encode_

URL-encodes the given text per RFC 2396.

=cut

    method url_encode_ ($text) {
        $text =~ s/ /\+/;
        $text =~ s/([^a-zA-Z0-9_\-.\+\'!~*\(\)])/sprintf("%%%02x",ord($1))/eg;
        return $text;
    }

=head2 http_redirect_

Sends an HTTP 302 redirect to the client.

=cut

    method http_redirect_ ($client, $url) {
        print $client "HTTP/1.0 302 Found$eol" .
                      "Location: $url$eol" .
                      "$eol";
    }

=head2 http_error_

Sends a simple HTML error page with the given HTTP status code.

=cut

    method http_error_ ($client, $error) {
        $self->log_( 0, "HTTP error $error returned" );

        my $text =                                                         # PROFILE BLOCK START
                "<html><head><title>POPFile Web Server Error $error</title></head>
<body>
<h1>POPFile Web Server Error $error</h1>
An error has occurred which has caused POPFile to return the error $error.
<p>
Click <a href=\"/\">here</a> to continue.
</body>
</html>$eol";                                                              # PROFILE BLOCK STOP

        $self->log_( 1, $text );

        my $error_code = 500;
        $error_code = $error if $error =~ /^\d{3}$/;

        print $client "HTTP/1.0 $error_code Error$eol";
        print $client "Content-Type: text/html$eol";
        print $client "Content-Length: ";
        print $client length( $text );
        print $client "$eol$eol";
        print $client $text;
    }

=head2 http_file_

Reads a file from disk and sends it to the client with appropriate headers,
or returns a 404 if the file does not exist.

=cut

    method http_file_ ($client, $file, $type) {
        my $contents = '';

        if ( defined( $file ) && ( open FILE, "<$file" ) ) {
            binmode FILE;
            while (<FILE>) {
                $contents .= $_;
            }
            close FILE;

            my $header = $self->build_http_header_( 200, $type, time + 60 * 60,
                                                    length( $contents ) );
            print $client $header . $contents;
        } else {
            $self->http_error_( $client, 404 );
        }
    }

=head2 build_http_header_

Builds and returns an HTTP 1.0 response header string.

=cut

    method build_http_header_ ($status, $type, $expires, $length) {
        my $date = time2str( "%a, %d %h %Y %X %Z", time, 'GMT' );
        if ( $expires != 0 ) {
            $expires = time2str( "%a, %d %h %Y %X %Z", $expires, 'GMT' );
        }

        return "HTTP/1.0 $status OK$eol" .               # PROFILE BLOCK START
               "Connection: close$eol" .
               "Content-Type: $type$eol" .
               "Date: $date$eol" .
               "Expires: $expires$eol" .
               ( $expires eq '0' ?
                 "Pragma: no-cache$eol" .
                 "Cache-Control: no-cache$eol" : '' ) .
               "Content-Length: $length$eol" .
               "$eol";                                    # PROFILE BLOCK STOP
    }

    # GETTERS / SETTERS

    method history ($val = undef) {
        $history = $val if defined $val;
        return $history;
    }

    method url_handler ($val = undef) {
        $url_handler = $val if defined $val;
        return $url_handler;
    }

    method form ($val = undef) {
        return \%form;
    }

} # end class UI::HTTP

1;
