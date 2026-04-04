# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
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
use POPFile::Role::Loadable;
use POPFile::Role::Logging;

# Class-wide slurp buffer — keyed by filehandle stringification so that
# handles can be shared between objects without losing buffered data.

my %slurp_data;

class POPFile::Module :repr(HASH) :does(POPFile::Loadable) :does(POPFile::Role::Logging);    # References to core infrastructure (injected by Loader::CORE_link_components)
    field $configuration :reader :writer = 0;
    field $mq :reader :writer = 0;

    # Module identity
    field $name :reader :writer = '';

    # Set to 0 to terminate loops inside this module
    field $alive :reader :writer = 1;

    # Loader callbacks
    field $pipeready :reader :writer = 0;
    field $forker :reader :writer = 0;
    field $childexit = 0;
    field $version :reader :writer = '';

=head1 NAME

POPFile::Module - base class for all POPFile loadable modules

=head1 DESCRIPTION

Defines the lifecycle interface (C<initialize>, C<start>, C<service>, C<stop>),
infrastructure accessors (C<configuration>, C<logger>, C<mq>), and protected
helper methods available to all subclasses.

Lifecycle: C<initialize> → C<start> → C<service> [loop] → C<stop>


=head1 PROTECTED HELPERS

=head2 config

Get or set a module-specific configuration parameter.

    my $val = $self->config('param');
    $self->config('param', $value);

=cut

    method config ($param, $val = undef) {
        return $self->module_config($name, $param, $val);
    }

=head2 global_config

Get or set a global (GLOBAL-namespaced) configuration parameter.

=cut

    method global_config ($param, $val = undef) {
        return $self->module_config('GLOBAL', $param, $val);
    }

=head2 module_config

Get or set a configuration parameter under an explicit module namespace.

=cut

    method module_config ($module, $param, $val = undef) {
        return $configuration->parameter($module . '_' . $param, $val);
    }

=head2 mq_post

Post a message to the message queue.

=cut

    method mq_post ($type, @message) {
        return $mq->post($type, @message);
    }

=head2 mq_register

Register this object to receive messages of C<$type> from the MQ.

=cut

    method mq_register ($type, $object) {
        return $mq->register($type, $object);
    }

=head2 get_user_path

Return the full path to a user-space file or directory.

=cut

    method get_user_path ($path, $sandbox = undef) {
        return $configuration->get_user_path($path, $sandbox);
    }

=head2 get_root_path

Return the full path to a POPFile-root-relative file or directory.

=cut

    method get_root_path ($path, $sandbox = undef) {
        return $configuration->get_root_path($path, $sandbox);
    }

    # -------------------------------------------------------------------------
    # slurp_ — line-buffered reader tolerating CR, CRLF and LF endings
    # -------------------------------------------------------------------------

    method flush_slurp_data ($handle) {
        if ($slurp_data{"$handle"}{data} =~ s/^([^\015\012]*\012)//) {
            return $1;
        }
        if ($slurp_data{"$handle"}{data} =~ s/^([^\015\012]*\015\012)//) {
            return $1;
        }
        if ($slurp_data{"$handle"}{data} =~ s/^([^\015\012]*\015)//) {
            my $cr = $1;
            if ($slurp_data{"$handle"}{data} eq '') {
                if ($self->can_read($handle)) {
                    my $c;
                    my $retcode = sysread($handle, $c, 1);
                    if ($retcode == 1) {
                        if ($c eq "\012") {
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
        return defined($slurp_data{"$handle"}{data})
            ? length($slurp_data{"$handle"}{data}) : 0;
    }

    method slurp_buffer ($handle, $length) {
        while ($self->slurp_data_size($handle) < $length) {
            my $c;
            if ($self->can_read($handle, 0.01)
                 && (sysread($handle, $c, $length) > 0)) {
                $slurp_data{"$handle"}{data} .= $c;
            } else {
                last;
            }
        }

        my $result = '';
        if ($self->slurp_data_size($handle) < $length) {
            $result = $slurp_data{"$handle"}{data};
            $slurp_data{"$handle"}{data} = '';
        } else {
            $result = substr($slurp_data{"$handle"}{data}, 0, $length);
            $slurp_data{"$handle"}{data} =
                substr($slurp_data{"$handle"}{data}, $length);
        }
        return ($result ne '') ? $result : undef;
    }

=head2 slurp

Read one line from C<$handle>, tolerating CR, LF, and CRLF endings.
Blocks up to C<$timeout> seconds (defaults to the global C<timeout> config).
Returns C<undef> on timeout or closed connection.

=cut

    method slurp ($handle, $timeout = undef) {
        $timeout = $self->global_config('timeout') if !defined $timeout;

        if (!defined($slurp_data{"$handle"}{data})) {
            $slurp_data{"$handle"}{select} = IO::Select->new($handle);
            $slurp_data{"$handle"}{data} = '';
        }

        my $result = $self->flush_slurp_data($handle);
        return $result if $result ne '';

        my $c;
        if ($self->can_read($handle, $timeout)) {
            while (sysread($handle, $c, 160) > 0) {
                $slurp_data{"$handle"}{data} .= $c;
                $self->log_msg(2, "Read slurp data $c");
                $result = $self->flush_slurp_data($handle);
                return $result if $result ne '';
            }
        } else {
            $self->done_slurp($handle);
            close $handle;
            return undef;
        }

        my $remaining = $slurp_data{"$handle"}{data};
        $self->done_slurp($handle);
        return ($remaining eq '') ? undef : $remaining;
    }

    method done_slurp ($handle) {
        delete $slurp_data{"$handle"}{select};
        delete $slurp_data{"$handle"}{data};
        delete $slurp_data{"$handle"};
    }

    method flush_extra ($mail, $client, $discard = 0) {
        if ($self->slurp_data_size($mail)) {
            print $client $slurp_data{"$mail"}{data} if $discard != 1;
            $slurp_data{"$mail"}{data} = '';
        }

        my $selector = IO::Select->new($mail);
        my $buf = '';
        my $full_buf = '';
        my $max_length = 8192;
        my $n;

        while (defined($selector->can_read(0.01))) {
            $n = sysread($mail, $buf, $max_length, length $buf);
            if ($n > 0) {
                print $client $buf if $discard != 1;
                $full_buf .= $buf;
            } else {
                last if $n == 0;
            }
        }
        return $full_buf;
    }

    method can_read ($handle, $timeout = undef) {
        $timeout = $self->global_config('timeout') if !defined $timeout;

        my $can_read = 0;
        if ($handle =~ /ssl/i) {
            $can_read = ($handle->pending() > 0);
        }
        if (!$can_read) {
            if (defined($slurp_data{"$handle"}{select})) {
                $can_read = defined(
                    $slurp_data{"$handle"}{select}->can_read($timeout));
            } else {
                my $selector = IO::Select->new($handle);
                $can_read = defined($selector->can_read($timeout));
            }
        }
        return $can_read;
    }

=head1 ACCESSORS

Fields C<configuration>, C<mq>, C<name>, C<alive>, C<forker>, C<pipeready>,
and C<version> have C<:reader> and C<:writer> generated accessors.
Getters use the field name; setters use the C<set_> prefix (e.g. C<set_name>).

C<setchildexit> is a combined getter/setter for the loader's child-exit callback
(the name is kept to avoid a clash with the C<childexit> lifecycle hook).

=cut

    method setchildexit ($val = undef) {
        $childexit = $val if defined $val;
        return $childexit;
    }

    method initialize() { return 1 }
    method start() { return 1 }
    method stop() {}
    method service() { return 1 }
    method prefork() {}
    method forked ($writer = undef) {}
    method postfork ($pid = undef, $reader = undef) {}
    method childexit() {}
    method reaper() {}
    method deliver ($type, @message) {}

1;
