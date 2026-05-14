# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::DBConnect;

use POPFile::Database;

=head1 NAME

POPFile::Role::DBConnect — thin wrapper around the shared Database singleton

=head1 DESCRIPTION

Modules that consume this role automatically share a single DBI handle
managed by L<POPFile::Database>.  The role delegates C<get_handle()>,
C<txn()>, and C<is_sqlite()> to the singleton so that every module
operates on the same connection without needing to know about the
singleton itself.

=cut

method get_handle() {
    POPFile::Database->instance()->get_handle()
}

1;
