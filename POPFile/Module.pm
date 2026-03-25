package POPFile::Module;

#----------------------------------------------------------------------------
#
# This is POPFile's top level Module object.
#
# Copyright (c) 2001-2011 John Graham-Cumming
#
#   This file is part of POPFile
#
#   POPFile is free software; you can redistribute it and/or modify it
#   under the terms of version 2 of the GNU General Public License as
#   published by the Free Software Foundation.
#
#----------------------------------------------------------------------------

use Object::Pad;
use IO::Select;
use POPFile::Role::Logging;

# Class-wide slurp buffer — keyed by filehandle stringification so that
# handles can be shared between objects without losing buffered data.

my %slurp_data;

class POPFile::Module :repr(HASH) :does(POPFile::Role::Logging) {

    # References to core infrastructure (injected by Loader::CORE_link_components)
    field $configuration = 0;
    field $mq            = 0;

    # Module identity
    field $name = '';

    # Set to 0 to terminate loops inside this module
    field $alive = 1;

    # Loader callbacks
    field $pipeready = 0;
    field $forker    = 0;
    field $childexit = 0;
    field $version   = '';

=head1 NAME

POPFile::Module - base class for all POPFile loadable modules

=head1 DESCRIPTION

Defines the lifecycle interface (C<initialize>, C<start>, C<service>, C<stop>),
infrastructure accessors (C<configuration>, C<logger>, C<mq>), and protected
helper methods available to all subclasses.

Lifecycle: C<initialize> → C<start> → C<service> [loop] → C<stop>

=head1 LIFECYCLE METHODS

Subclasses override these as needed.

=head2 initialize

Called once before C<start>.  Register configuration parameters here.
Returns 1 on success, 0 to abort loading.

=head2 start

Called to open connections and begin operation.
Returns 1 on success, 0 to abort, 2 to unload the module.

=head2 service

Called repeatedly in the main loop.  Do per-tick work here.
Returns 1 to continue, 0 to request shutdown.

=head2 stop

Called on shutdown.  Clean up resources here.

=head2 prefork / forked / postfork / childexit / reaper / deliver

Fork-lifecycle and message-queue hooks — see individual subclass docs.

=cut

    method initialize { return 1 }

    method start      { return 1 }

    method stop       {}

    method service    { return 1 }

    method prefork    {}

    method forked ($writer = undef) {}

    method postfork ($pid = undef, $reader = undef) {}

    method childexit  {}

    method reaper     {}

    method deliver ($type, @message) {}

=head1 PROTECTED HELPERS

=head2 config_

Get or set a module-specific configuration parameter.

    my $val = $self->config_( 'param' );
    $self->config_( 'param', $value );

=cut

    method config_ ($param, $val = undef) {
        return $self->module_config_( $name, $param, $val );
    }

=head2 global_config_

Get or set a global (GLOBAL-namespaced) configuration parameter.

=cut

    method global_config_ ($param, $val = undef) {
        return $self->module_config_( 'GLOBAL', $param, $val );
    }

=head2 module_config_

Get or set a configuration parameter under an explicit module namespace.

=cut

    method module_config_ ($module, $param, $val = undef) {
        return $configuration->parameter( $module . '_' . $param, $val );
    }

=head2 mq_post_

Post a message to the message queue.

=cut

    method mq_post_ ($type, @message) {
        return $mq->post( $type, @message );
    }

=head2 mq_register_

Register this object to receive messages of C<$type> from the MQ.

=cut

    method mq_register_ ($type, $object) {
        return $mq->register( $type, $object );
    }

    method register_configuration_item_ ($type, $item_name, $templ, $object) {
        return $self->mq_post_( 'UIREG', $type, $item_name, $templ, $object );
    }

=head2 get_user_path_

Return the full path to a user-space file or directory.

=cut

    method get_user_path_ ($path, $sandbox = undef) {
        return $configuration->get_user_path( $path, $sandbox );
    }

=head2 get_root_path_

Return the full path to a POPFile-root-relative file or directory.

=cut

    method get_root_path_ ($path, $sandbox = undef) {
        return $configuration->get_root_path( $path, $sandbox );
    }

    # -------------------------------------------------------------------------
    # slurp_ — line-buffered reader tolerating CR, CRLF and LF endings
    # -------------------------------------------------------------------------

    method flush_slurp_data ($handle) {
        if ( $slurp_data{"$handle"}{data} =~ s/^([^\015\012]*\012)// ) {
            return $1;
        }
        if ( $slurp_data{"$handle"}{data} =~ s/^([^\015\012]*\015\012)// ) {
            return $1;
        }
        if ( $slurp_data{"$handle"}{data} =~ s/^([^\015\012]*\015)// ) {
            my $cr = $1;
            if ( $slurp_data{"$handle"}{data} eq '' ) {
                if ( $self->can_read( $handle ) ) {
                    my $c;
                    my $retcode = sysread( $handle, $c, 1 );
                    if ( $retcode == 1 ) {
                        if ( $c eq "\012" ) {
                            $cr .= $c;
                        } else {
                            $slurp_data{"$handle"}{data} = $c;
                        }
                    }
                }
            }
            return $cr;
        }
        return '';
    }

    method slurp_data_size ($handle) {
        return defined( $slurp_data{"$handle"}{data} )
            ? length( $slurp_data{"$handle"}{data} ) : 0;
    }

    method slurp_buffer_ ($handle, $length) {
        while ( $self->slurp_data_size( $handle ) < $length ) {
            my $c;
            if ( $self->can_read( $handle, 0.01 )
                 && ( sysread( $handle, $c, $length ) > 0 ) ) {
                $slurp_data{"$handle"}{data} .= $c;
            } else {
                last;
            }
        }

        my $result = '';
        if ( $self->slurp_data_size( $handle ) < $length ) {
            $result = $slurp_data{"$handle"}{data};
            $slurp_data{"$handle"}{data} = '';
        } else {
            $result = substr( $slurp_data{"$handle"}{data}, 0, $length );
            $slurp_data{"$handle"}{data} =
                substr( $slurp_data{"$handle"}{data}, $length );
        }
        return ( $result ne '' ) ? $result : undef;
    }

=head2 slurp_

Read one line from C<$handle>, tolerating CR, LF, and CRLF endings.
Blocks up to C<$timeout> seconds (defaults to the global C<timeout> config).
Returns C<undef> on timeout or closed connection.

=cut

    method slurp_ ($handle, $timeout = undef) {
        $timeout = $self->global_config_( 'timeout' ) if !defined $timeout;

        if ( !defined( $slurp_data{"$handle"}{data} ) ) {
            $slurp_data{"$handle"}{select} = IO::Select->new( $handle );
            $slurp_data{"$handle"}{data}   = '';
        }

        my $result = $self->flush_slurp_data( $handle );
        return $result if $result ne '';

        my $c;
        if ( $self->can_read( $handle, $timeout ) ) {
            while ( sysread( $handle, $c, 160 ) > 0 ) {
                $slurp_data{"$handle"}{data} .= $c;
                $self->log_( 2, "Read slurp data $c" );
                $result = $self->flush_slurp_data( $handle );
                return $result if $result ne '';
            }
        } else {
            $self->done_slurp_( $handle );
            close $handle;
            return undef;
        }

        my $remaining = $slurp_data{"$handle"}{data};
        $self->done_slurp_( $handle );
        return ( $remaining eq '' ) ? undef : $remaining;
    }

    method done_slurp_ ($handle) {
        delete $slurp_data{"$handle"}{select};
        delete $slurp_data{"$handle"}{data};
        delete $slurp_data{"$handle"};
    }

    method flush_extra_ ($mail, $client, $discard = 0) {
        if ( $self->slurp_data_size( $mail ) ) {
            print $client $slurp_data{"$mail"}{data} if $discard != 1;
            $slurp_data{"$mail"}{data} = '';
        }

        my $selector    = IO::Select->new( $mail );
        my $buf         = '';
        my $full_buf    = '';
        my $max_length  = 8192;
        my $n;

        while ( defined( $selector->can_read(0.01) ) ) {
            $n = sysread( $mail, $buf, $max_length, length $buf );
            if ( $n > 0 ) {
                print $client $buf if $discard != 1;
                $full_buf .= $buf;
            } else {
                last if $n == 0;
            }
        }
        return $full_buf;
    }

    method can_read ($handle, $timeout = undef) {
        $timeout = $self->global_config_( 'timeout' ) if !defined $timeout;

        my $can_read = 0;
        if ( $handle =~ /ssl/i ) {
            $can_read = ( $handle->pending() > 0 );
        }
        if ( !$can_read ) {
            if ( defined( $slurp_data{"$handle"}{select} ) ) {
                $can_read = defined(
                    $slurp_data{"$handle"}{select}->can_read( $timeout ) );
            } else {
                my $selector = IO::Select->new( $handle );
                $can_read = defined( $selector->can_read( $timeout ) );
            }
        }
        return $can_read;
    }

=head1 ACCESSORS

=head2 configuration / mq / name / alive / forker / pipeready / version

Standard getter/setters injected by C<POPFile::Loader>.
Call with no argument to get; call with a value to set.

=cut

    method mq ($val = undef) {
        $mq = $val if defined $val;
        return $mq;
    }

    method configuration ($val = undef) {
        $configuration = $val if defined $val;
        return $configuration;
    }

    method name ($val = undef) {
        $name = $val if defined $val;
        return $name;
    }

    method alive ($val = undef) {
        $alive = $val if defined $val;
        return $alive;
    }

    method forker ($val = undef) {
        $forker = $val if defined $val;
        return $forker;
    }

    method pipeready ($val = undef) {
        $pipeready = $val if defined $val;
        return $pipeready;
    }

    method setchildexit ($val = undef) {
        $childexit = $val if defined $val;
        return $childexit;
    }

    method version ($val = undef) {
        $version = $val if defined $val;
        return $version;
    }

}

1;
