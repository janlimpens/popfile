package POPFile::Mutex;

#----------------------------------------------------------------------------
#
# This is a mutex object that uses mkdir() to provide exclusive access
# to a region on a per thread or per process basis.
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

class POPFile::Mutex {

    field $name__;
    field $locked__ = undef;

    BUILD ($name) {
        $name__ = "popfile_mutex_${name}.mtx";
        $self->release();
    }

    #------------------------------------------------------------------------
    #
    # acquire
    #
    #   Returns 1 if it manages to grab the mutex (and will block if
    #   necessary) and 0 if it fails.
    #
    #   $timeout    Timeout in seconds to wait (undef = infinite)
    #
    #------------------------------------------------------------------------
    method acquire ($timeout = undef) {
        return 0 if defined $locked__;

        $timeout = 0xFFFFFFFF if !defined $timeout;
        my $now = time;

        do {
            if ( mkdir( $name__, 0755 ) ) {
                $locked__ = 1;
                return 1;
            }
            select( undef, undef, undef, 0.01 );
        } while ( time < ( $now + $timeout ) );

        return 0;
    }

    #------------------------------------------------------------------------
    #
    # release
    #
    #   Release the lock if we acquired it with a call to acquire()
    #
    #------------------------------------------------------------------------
    method release {
        rmdir $name__;
        $locked__ = undef;
    }
}

1;
