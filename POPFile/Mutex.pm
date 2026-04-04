# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2001-2011 John Graham-Cumming
# Copyright (C) 2026 Jan Limpens
package POPFile::Mutex;

#----------------------------------------------------------------------------
#
# Mutex object that uses mkdir() to provide exclusive access on a per-thread
# or per-process basis.
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

class POPFile::Mutex;

=head1 NAME

POPFile::Mutex — advisory filesystem mutex using C<mkdir>

=head1 DESCRIPTION

Provides a simple cross-process mutual-exclusion lock.  The lock is
implemented by creating a directory on the filesystem; C<mkdir> is atomic on
POSIX systems, so two concurrent callers cannot both succeed.

Create one instance per lock name.  The name is used to construct a directory
path of the form C<popfile_mutex_E<lt>nameE<gt>.mtx> in the current working
directory.  Any stale lock directory left by a crashed process is cleaned up
by the constructor.

=head1 METHODS

=cut

    # Full filesystem path used as the lock directory
    field $lock_path;

    # Truthy while this object holds the lock
    field $locked = undef;

    BUILD ($mutex_name) {
        $lock_path = "popfile_mutex_${mutex_name}.mtx";
        $self->release();
    }

=head2 acquire

Attempts to grab the mutex. Blocks until the lock is obtained or the optional
timeout (in seconds) expires. Returns 1 on success, 0 on failure.

    $mutex->acquire();           # block indefinitely
    $mutex->acquire($timeout); # timeout in seconds

=cut

    method acquire ($timeout = undef) {
        return 0 if defined $locked;

        $timeout = 0xFFFFFFFF if !defined $timeout;
        my $now = time;

        do {
            if (mkdir($lock_path, 0755)) {
                $locked = 1;
                return 1;
            }
            select(undef, undef, undef, 0.01);
        } while (time < ($now + $timeout));

        return 0;
    }

=head2 release

Releases the lock if it was previously acquired with L</acquire>.

=cut

    method release() {
        rmdir $lock_path;
        $locked = undef;
    }

1;
