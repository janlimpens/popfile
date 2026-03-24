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

package POPFile::Module;

use Object::Pad;
use IO::Select;

# ----------------------------------------------------------------------------
#
# This module implements the base class for all POPFile Loadable Modules.
#
# Lifecycle: initialize() → start() → service() [loop] → stop()
#
# Protected methods (callable by subclasses): log_(), config_(), mq_post_(),
# mq_register_(), slurp_(), get_user_path_(), get_root_path_()
#
# Naming convention:
#   foo__  private (double underscore)
#   foo_   protected (single underscore)
#   foo    public
#
# ----------------------------------------------------------------------------

# Class-wide slurp buffer — keyed by filehandle stringification so that
# handles can be shared between objects without losing buffered data.

my %slurp_data__;

class POPFile::Module :repr(HASH) {

    BUILD {
        # References to core infrastructure (set by Loader::CORE_link_components)
        $self->{configuration__} = 0;
        $self->{logger__}        = 0;
        $self->{mq__}            = 0;

        # Module identity
        $self->{name__}          = '';

        # Set to 0 to terminate any loops inside this module
        $self->{alive_}          = 1;

        # Function references injected by the Loader
        $self->{pipeready_}      = 0;
        $self->{forker_}         = 0;
    }

    # -------------------------------------------------------------------------
    # Lifecycle hooks — subclasses override as needed
    # -------------------------------------------------------------------------

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

    # -------------------------------------------------------------------------
    # Protected helpers — called by subclasses via $self->foo_()
    # -------------------------------------------------------------------------

    method log_ ($level, $message) {
        my ( undef, undef, $line ) = caller;
        $self->{logger__}->debug( $level, "$self->{name__}: $line: $message" );
    }

    method config_ ($name, $value = undef) {
        return $self->module_config_( $self->{name__}, $name, $value );
    }

    method global_config_ ($name, $value = undef) {
        return $self->module_config_( 'GLOBAL', $name, $value );
    }

    method module_config_ ($module, $name, $value = undef) {
        return $self->{configuration__}->parameter( $module . '_' . $name, $value );
    }

    method mq_post_ ($type, @message) {
        return $self->{mq__}->post( $type, @message );
    }

    method mq_register_ ($type, $object) {
        return $self->{mq__}->register( $type, $object );
    }

    method register_configuration_item_ ($type, $name, $templ, $object) {
        return $self->mq_post_( 'UIREG', $type, $name, $templ, $object );
    }

    method get_user_path_ ($path, $sandbox = undef) {
        return $self->{configuration__}->get_user_path( $path, $sandbox );
    }

    method get_root_path_ ($path, $sandbox = undef) {
        return $self->{configuration__}->get_root_path( $path, $sandbox );
    }

    # -------------------------------------------------------------------------
    # slurp_ — line-buffered reader tolerating CR, CRLF and LF endings
    # -------------------------------------------------------------------------

    method flush_slurp_data__ ($handle) {
        if ( $slurp_data__{"$handle"}{data} =~ s/^([^\015\012]*\012)// ) {
            return $1;
        }
        if ( $slurp_data__{"$handle"}{data} =~ s/^([^\015\012]*\015\012)// ) {
            return $1;
        }
        if ( $slurp_data__{"$handle"}{data} =~ s/^([^\015\012]*\015)// ) {
            my $cr = $1;
            if ( $slurp_data__{"$handle"}{data} eq '' ) {
                if ( $self->can_read__( $handle ) ) {
                    my $c;
                    my $retcode = sysread( $handle, $c, 1 );
                    if ( $retcode == 1 ) {
                        if ( $c eq "\012" ) {
                            $cr .= $c;
                        } else {
                            $slurp_data__{"$handle"}{data} = $c;
                        }
                    }
                }
            }
            return $cr;
        }
        return '';
    }

    method slurp_data_size__ ($handle) {
        return defined( $slurp_data__{"$handle"}{data} )
            ? length( $slurp_data__{"$handle"}{data} ) : 0;
    }

    method slurp_buffer_ ($handle, $length) {
        while ( $self->slurp_data_size__( $handle ) < $length ) {
            my $c;
            if ( $self->can_read__( $handle, 0.01 )
                 && ( sysread( $handle, $c, $length ) > 0 ) ) {
                $slurp_data__{"$handle"}{data} .= $c;
            } else {
                last;
            }
        }

        my $result = '';
        if ( $self->slurp_data_size__( $handle ) < $length ) {
            $result = $slurp_data__{"$handle"}{data};
            $slurp_data__{"$handle"}{data} = '';
        } else {
            $result = substr( $slurp_data__{"$handle"}{data}, 0, $length );
            $slurp_data__{"$handle"}{data} =
                substr( $slurp_data__{"$handle"}{data}, $length );
        }
        return ( $result ne '' ) ? $result : undef;
    }

    method slurp_ ($handle, $timeout = undef) {
        $timeout = $self->global_config_( 'timeout' ) if !defined $timeout;

        if ( !defined( $slurp_data__{"$handle"}{data} ) ) {
            $slurp_data__{"$handle"}{select} = IO::Select->new( $handle );
            $slurp_data__{"$handle"}{data}   = '';
        }

        my $result = $self->flush_slurp_data__( $handle );
        return $result if $result ne '';

        my $c;
        if ( $self->can_read__( $handle, $timeout ) ) {
            while ( sysread( $handle, $c, 160 ) > 0 ) {
                $slurp_data__{"$handle"}{data} .= $c;
                $self->log_( 2, "Read slurp data $c" );
                $result = $self->flush_slurp_data__( $handle );
                return $result if $result ne '';
            }
        } else {
            $self->done_slurp_( $handle );
            close $handle;
            return undef;
        }

        my $remaining = $slurp_data__{"$handle"}{data};
        $self->done_slurp_( $handle );
        return ( $remaining eq '' ) ? undef : $remaining;
    }

    method done_slurp_ ($handle) {
        delete $slurp_data__{"$handle"}{select};
        delete $slurp_data__{"$handle"}{data};
        delete $slurp_data__{"$handle"};
    }

    method flush_extra_ ($mail, $client, $discard = 0) {
        if ( $self->slurp_data_size__( $mail ) ) {
            print $client $slurp_data__{"$mail"}{data} if $discard != 1;
            $slurp_data__{"$mail"}{data} = '';
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

    method can_read__ ($handle, $timeout = undef) {
        $timeout = $self->global_config_( 'timeout' ) if !defined $timeout;

        my $can_read = 0;
        if ( $handle =~ /ssl/i ) {
            $can_read = ( $handle->pending() > 0 );
        }
        if ( !$can_read ) {
            if ( defined( $slurp_data__{"$handle"}{select} ) ) {
                $can_read = defined(
                    $slurp_data__{"$handle"}{select}->can_read( $timeout ) );
            } else {
                my $selector = IO::Select->new( $handle );
                $can_read = defined( $selector->can_read( $timeout ) );
            }
        }
        return $can_read;
    }

    # -------------------------------------------------------------------------
    # Public accessors
    # -------------------------------------------------------------------------

    method mq ($value = undef) {
        $self->{mq__} = $value if defined $value;
        return $self->{mq__};
    }

    method configuration ($value = undef) {
        $self->{configuration__} = $value if defined $value;
        return $self->{configuration__};
    }

    method logger ($value = undef) {
        $self->{logger__} = $value if defined $value;
        return $self->{logger__};
    }

    method name ($value = undef) {
        $self->{name__} = $value if defined $value;
        return $self->{name__};
    }

    method alive ($value = undef) {
        $self->{alive_} = $value if defined $value;
        return $self->{alive_};
    }

    method forker ($value = undef) {
        $self->{forker_} = $value if defined $value;
        return $self->{forker_};
    }

    method pipeready ($value = undef) {
        $self->{pipeready_} = $value if defined $value;
        return $self->{pipeready_};
    }

    method setchildexit ($value = undef) {
        $self->{childexit_} = $value if defined $value;
        return $self->{childexit_};
    }

    method version ($value = undef) {
        $self->{version_} = $value if defined $value;
        return $self->{version_};
    }

    method last_ten_log_entries {
        return $self->{logger__}->last_ten();
    }
}

1;
