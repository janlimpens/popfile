# POPFILE LOADABLE MODULE
package UI::XMLRPC;

#----------------------------------------------------------------------------
#
# This package contains the XML-RPC interface for POPFile, all the methods
# in Classifier::Bayes can be accessed through the XMLRPC interface and
# a typical method would be accessed as follows
#
#     Classifier/Bayes.get_buckets
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
#----------------------------------------------------------------------------

use Object::Pad;
use locale;

use POPFile::API;

use IO::Socket;
use IO::Select;

my $eol = "\015\012";

class UI::XMLRPC :isa(POPFile::Module) {

    field $api        = undef;
    field $server     = undef;
    field $selector   = undef;
    field $classifier = undef;
    field $history    = undef;

    BUILD {
        $self->name('xmlrpc');
    }

=head2 initialize

Registers configuration defaults and creates the internal C<POPFile::API>
object. Returns 1 on success.

=cut

    method initialize {
        $self->config_( 'enabled', 0 );
        $self->config_( 'port',    8081 );
        $self->config_( 'local',   1 );

        $api = POPFile::API->new();

        return 1;
    }

=head2 start

Opens the XMLRPC listening socket and registers UI configuration items.
Returns 1 on success, 0 on failure to bind, 2 if disabled.

=cut

    method start {
        return 2 if $self->config_( 'enabled' ) == 0;

        require XMLRPC::Transport::HTTP;

        $self->register_configuration_item_( 'configuration',
                                             'xmlrpc_port',
                                             'xmlrpc-port.thtml',
                                             $self );

        $self->register_configuration_item_( 'security',
                                             'xmlrpc_local',
                                             'xmlrpc-local.thtml',
                                             $self );

        $server = XMLRPC::Transport::HTTP::Daemon->new(
                                     Proto     => 'tcp',
                                     $self->config_( 'local' ) == 1 ? (LocalAddr => 'localhost') : (),
                                     LocalPort => $self->config_( 'port' ),
                                     Listen    => SOMAXCONN,
                                     Reuse     => 1 );

        if ( !defined( $server ) ) {
            my $port = $self->config_( 'port' );
            my $name = $self->name();
            $self->log_( 0, "Couldn't start the $name interface because POPFile could not bind to the listen port $port" );
            print <<EOM;

\nCouldn't start the $name interface because POPFile could not bind to the
listen port $port. This could be because there is another service
using that port or because you do not have the right privileges on
your system (On Unix systems this can happen if you are not root
and the port you specified is less than 1024).

EOM
            return 0;
        }

        $api->{c} = $classifier;
        $server->dispatch_to( $api );

        # Access the private _daemon handle from XMLRPC::Transport::HTTP::Daemon
        # (which is a SOAP::Transport::HTTP::Daemon -> HTTP::Daemon -> IO::Socket::INET)
        # to build a non-blocking selector.
        $selector = IO::Select->new( $server->{_daemon} );

        return 1;
    }

=head2 service

Polls for a pending XMLRPC connection and handles one request per call.
Returns 1.

=cut

    method service {
        my ( $ready ) = $selector->can_read(0);

        if ( defined( $ready ) ) {
            if ( my $client = $server->accept() ) {
                my ( $remote_port, $remote_host ) = sockaddr_in( $client->peername() );

                if ( ( $self->config_( 'local' ) == 0 ) ||
                     ( $remote_host eq inet_aton( "127.0.0.1" ) ) ) {
                    my $request = $client->get_request();

                    if ( defined( $request ) ) {
                        $server->request( $request );
                        $server->SOAP::Transport::HTTP::Server::handle();
                        $client->send_response( $server->response );
                    }
                    $client->close();
                }
            }
        }

        return 1;
    }

=head2 configure_item

Fills template parameters for the XMLRPC port and local-only settings.

=cut

    method configure_item ($name, $templ, $language = undef) {
        if ( $name eq 'xmlrpc_port' ) {
            $templ->param( 'XMLRPC_Port' => $self->config_( 'port' ) );
        }

        if ( $name eq 'xmlrpc_local' ) {
            $templ->param( 'XMLRPC_local_on' =>
                $self->config_( 'local' ) == 1 ? 1 : 0 );
        }
    }

=head2 validate_item

Validates and applies form changes for port and local-only settings.

=cut

    method validate_item ($name, $templ, $language, $form) {
        if ( $name eq 'xmlrpc_port' ) {
            if ( defined($$form{xmlrpc_port}) ) {
                if ( ( $$form{xmlrpc_port} >= 1 ) && ( $$form{xmlrpc_port} < 65536 ) ) {
                    $self->config_( 'port', $$form{xmlrpc_port} );
                    $templ->param( 'XMLRPC_port_if_error' => 0 );
                    $templ->param( 'XMLRPC_port_updated' =>
                        sprintf( $$language{Configuration_XMLRPCUpdate}, $self->config_( 'port' ) ) );
                } else {
                    $templ->param( 'XMLRPC_port_if_error' => 1 );
                }
            }
        }

        if ( $name eq 'xmlrpc_local' ) {
            $self->config_( 'local', $$form{xmlrpc_local} - 1 )
                if defined($$form{xmlrpc_local});
        }

        return '';
    }

    # GETTERS / SETTERS

    method classifier ($val = undef) {
        $classifier = $val if defined $val;
        return $classifier;
    }

    method history ($val = undef) {
        $history = $val if defined $val;
        return $history;
    }

} # end class UI::XMLRPC

1;
