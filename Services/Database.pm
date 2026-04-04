# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Role::SQL;

class Services::Database :isa(POPFile::Module) :does(POPFile::Role::SQL);

=head1 NAME

Services::Database — shared DBI connection manager for POPFile modules

=head1 DESCRIPTION

C<Services::Database> owns the database connection lifecycle.  It creates and
caches L<DBI> handles on demand, reconnecting automatically if a cached handle
is no longer live.  Modules that need a database handle call C<get_handle()>
(or the convenience alias C<db()>) instead of opening their own connections.

Multiple named handles are supported; the default name is C<'default'>.  After
a C<fork()>, all cached handles are discarded so child processes do not share
connection state with the parent.

=head1 METHODS

=cut

use DBI;

field %handles;
field $dsn :writer = '';
field $user :writer = '';
field $auth :writer = '';
field $options :writer = {};
field $dialect :reader = 'sqlite';

BUILD {
    $self->set_name('database');
}

=head2 initialize()

Registers the C<dbtype> configuration parameter (default C<'sqlite'>).
Returns 1.

=cut

method initialize() {
    $self->config('dbtype', 'sqlite');
    return 1
}

=head2 start()

Reads the C<dbtype> config value and stores it as the active SQL dialect.
Returns 1.

=cut

method start() {
    $dialect = $self->config('dbtype') || 'sqlite';
    return 1
}

=head2 db()

Convenience alias for C<get_handle()> using the default connection name.

=cut

method db() {
    return $self->get_handle()
}

=head2 get_handle($name)

Returns a live DBI handle for C<$name> (default C<'default'>).  If no
handle exists for that name, or if the existing handle fails C<ping()>, a
new connection is opened using the DSN, credentials, and options configured
via the writer accessors.

=cut

method get_handle ($name = 'default') {
    return $handles{$name}
        if defined $handles{$name} && $handles{$name}->ping();
    $handles{$name} = DBI->connect($dsn, $user, $auth, $options);
    return $handles{$name}
}

=head2 forked($writer)

Discards all cached handles after a C<fork()> so the child process does not
share connection state with the parent.

=cut

method forked ($writer = undef) {
    %handles = ();
}

=head2 stop()

Disconnects all cached handles and clears the handle cache.

=cut

method stop() {
    $_->disconnect()
        for values %handles;
    %handles = ();
}

1;
