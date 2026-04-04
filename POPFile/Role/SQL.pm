# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::SQL {

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
            unless $string;
        my $backup = $string;
        if (my $count = ($string =~ s/\x00//g)) {
            my ($package, $file, $line) = caller(1);
            $self->log_msg(0, "Found $count null-character(s) in string '$backup'. Called from package '$package' ($file), line $line.");
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
        my $dbh = $self->db();
        my $sth;
        if ((ref $sql_or_sth) =~ m/^DBI::/) {
            $sth = $sql_or_sth;
        }
        else {
            my $sql = $self->normalize_sql($sql_or_sth);
            $sql = $self->check_for_nullbytes($sql);
            $sth = $dbh->prepare($sql);
        }
        for my $arg (@args) {
            $arg = $self->check_for_nullbytes($arg);
        }
        my $execute_result = $sth->execute(@args);
        if ($self->module_config('logger', 'log_sql') && $self->module_config('logger', 'log_to_stdout')) {
            my @vals = @args;
            (my $logged = $sth->{Statement} // '') =~ s/\?/do { my $v = shift @vals; defined $v ? "'$v'" : 'NULL' }/ge;
            print "[SQL] $logged\n";
        }
        unless ($execute_result) {
            my ($package, $file, $line) = caller;
            $self->log_msg(0, "DBI::execute failed.  Called from package '$package' ($file), line $line.");
        }
        return $sth
    }
}
