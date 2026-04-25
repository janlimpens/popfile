# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::SQL;
use POPFile::Role::Logging qw(LOG_ERROR LOG_INFO LOG_DEBUG);

use lib 'vendor/perl-querybuilder/lib';
use Carp;
use Query::Builder;

field $_qb = undef;

my %driver_map = (
    SQLite  => 'sqlite',
    SQLite2 => 'sqlite',
    mysql => 'mysql',
    Pg => 'pg' );

=head2 qb

Returns a Query::Builder instance configured for the active database dialect.
The instance is lazily created and cached per object.

=cut

method qb() {
    return $_qb
        if defined $_qb;
    my $driver = $self->db()->{Driver}{Name} // 'SQLite';
    my $dialect = $driver_map{$driver} // 'sqlite';
    $_qb = Query::Builder->new(dialect => $dialect);
    return $_qb
}

=head2 normalize_sql

Collapses runs of whitespace in an SQL string to single spaces and strips
leading/trailing whitespace.

=cut

method normalize_sql ($sql) {
    $sql =~ s/\s+/ /g;
    $sql =~ s/^ | $//g;
    return $sql
}

=head2 check_for_nullbytes

Checks a string for null bytes (C<\x00>), logs a warning for each one found,
strips them, and returns the cleaned string.  Returns C<undef> when passed
C<undef> or the empty string.

=cut

method check_for_nullbytes($string) {
    return
        unless defined $string && length $string;
    my $backup = $string;
    if (my $count = ($string =~ s/\x00//g)) {
        my ($package, $file, $line) = caller(1);
        $self->log_msg(LOG_ERROR, "Found $count null-character(s) in string '$backup'. Called from package '$package' ($file), line $line.");
    }
    return $string
}

=head2 validate_sql_prepare_and_execute

Prepares and executes an SQL statement, scrubbing null bytes from the SQL and
all bind parameters first.  Accepts either a plain SQL string or an already-
prepared DBI statement handle (in which case only execution is performed).

Returns the executed statement handle.

C<$sql_or_sth> — SQL string or prepared statement handle
C<@args>       — optional bind parameters

=cut

method validate_sql_prepare_and_execute ($sql_or_sth, @args) {
    my $dbh = $self->db() or croak 'Could not get handle';
    my $sth;
    if ((ref $sql_or_sth) =~ m/^DBI::/) {
        $sth = $sql_or_sth;
    } else {
        my $sql = $self->normalize_sql($sql_or_sth);
        $sql = $self->check_for_nullbytes($sql);
        $sth = $dbh->prepare($sql);
    }
    for my $arg (@args) {
        $arg = $self->check_for_nullbytes($arg);
    }
    my $execute_result = $sth->execute(@args);
    if ($self->module_config('logger', 'log_sql')) {
        my @vals = @args;
        (my $logged = $sth->{Statement} // '') =~ s/\?/do { my $v = shift @vals; defined $v ? "'$v'" : 'NULL' }/ge;
        $self->log_msg(LOG_INFO, "[SQL] $logged");
    }
    unless ($execute_result) {
        my ($package, $file, $line) = caller;
        $self->log_msg(LOG_ERROR, "DBI::execute failed.  Called from package '$package' ($file), line $line.");
    }
    return $sth
}

1;
