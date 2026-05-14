# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::SQL;

use lib 'vendor/perl-querybuilder/lib';
use Carp;

use Query::Builder;

field $_qb = undef;

my %driver_map = (
    SQLite => 'sqlite',
    SQLite2 => 'sqlite',
    mysql => 'mysql',
    Pg => 'pg' );

method qb() {
    return $_qb
        if defined $_qb;
    my $driver = $self->get_handle()->{Driver}{Name} // 'SQLite';
    my $dialect = $driver_map{$driver} // 'sqlite';
    $_qb = Query::Builder->new(dialect => $dialect);
    return $_qb
}

method normalize_sql ($sql) {
    return $sql
        unless defined $sql;
    $sql =~ s/\s+/ /g;
    $sql =~ s/^ | $//g;
    return $sql
}

method check_for_nullbytes ($string) {
    return
        unless defined $string && length $string;
    my $backup = $string;
    if (my $count = ($string =~ s/\x00//g)) {
        my ($package, $file, $line) = caller(1);
        $self->log_msg(WARN => "Found $count null-character(s) in string '$backup'. Called from package '$package' ($file), line $line.");
    }
    return $string
}

method validate_sql_prepare_and_execute ($sql_or_sth, @args) {
    my $dbh = $self->get_handle()
        or croak 'Could not get handle';
    my $sth;
    if ((ref $sql_or_sth) =~ m/^DBI::/) {
        $sth = $sql_or_sth;
    } else {
        my $sql = $self->normalize_sql($sql_or_sth);
        $sql = $self->check_for_nullbytes($sql);
        $sth = $dbh->prepare($sql);
        unless (defined $sth) {
            my ($package, $file, $line) = caller;
            $self->log_msg(WARN => "DBI::prepare failed for SQL: $sql.  Called from package '$package' ($file), line $line.");
            return
        }
    }
    for my $arg (@args) {
        $arg = $self->check_for_nullbytes($arg);
    }
    my $execute_result = $sth->execute(@args);
    if ($self->module_config('logger', 'log_sql')) {
        my @vals = @args;
        (my $logged = $sth->{Statement} // '') =~ s/\?/do { my $v = shift @vals; defined $v ? "'$v'" : 'NULL' }/ge;
        $self->log_msg(INFO => "[SQL] $logged");
    }
    unless ($execute_result) {
        my ($package, $file, $line) = caller;
        $self->log_msg(WARN => "DBI::execute failed.  Called from package '$package' ($file), line $line.");
    }
    return $sth
}

1;
