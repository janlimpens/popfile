# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::DBAccess;

=head2 _db

Returns the raw database handle stored by this role (may be C<undef>).
Used by composing classes to check whether the handle has been initialised
before delegating to their own lazy-loading C<db()> accessor.

=cut

field $db = undef;

method _db() {
    return $db
}

=head2 _set_db

Stores a database handle (or C<undef>) in the role's backing field.

=cut

method _set_db($handle) {
    $db = $handle
}

=head2 _clear_db

Clears the stored database handle.  Composing classes call this from their
C<forked()> and C<stop()> implementations.

=cut

method _clear_db() {
    undef $db
}

1;
