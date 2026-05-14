# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Features;

class Classifier::Schema;

=head1 NAME

Classifier::Schema — POPFile database schema creation and upgrade

=head1 DESCRIPTION

Reads C<Classifier/popfile.sql>, creates the initial schema on fresh
databases, and performs a full dump-and-reload upgrade when the schema
version changes.

Receives a config reference (usually the Bayes module) at construction
time so it can resolve paths and read language settings itself instead
of requiring them as method parameters.

=cut

field $_serial = 0;
field $_config :param = undef;

method ensure_schema($dbh, $root_path, $is_sqlite) {
    my $version = $self->_schema_version($root_path);
    return 0
        unless defined $version;
    my $need_upgrade = 1;
    my $sqlquotechar = $dbh->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } $dbh->tables();
    for my $table (@tables) {
        if ($table =~ /\.?popfile$/) {
            my @row = $dbh->selectrow_array('select version from popfile');
            if (@row) {
                $need_upgrade = ($row[0] != $version);
            }
        }
    }
    if ($need_upgrade && @tables) {
        $self->_upgrade($dbh, $root_path, $is_sqlite);
    } elsif (!@tables) {
        return $self->_create($dbh, $root_path, $is_sqlite)
    }
    return 1
}

method setup($dbh) {
    my $driver = $dbh->{Driver}->{Name};
    my $root = $_config ? $_config->get_root_path('') : '.';
    return 0
        unless $self->ensure_schema($dbh, $root, $driver =~ /SQLite/i);
    if ($driver =~ /SQLite/i
        && $_config && $_config->can('parser')
        && $_config->parser()->lang() eq 'Nihongo') {
        $dbh->do('pragma case_sensitive_like=1');
    }
    $self->_ensure_mid_column($dbh);
    return 1
}

method _ensure_mid_column($dbh) {
    my $driver = $dbh->{Driver}->{Name};
    my $has_mid;
    if ($driver =~ /SQLite/i) {
        $has_mid = grep { $_->[1] eq 'mid' }
            $dbh->selectall_arrayref("PRAGMA table_info(history)")->@*;
    } elsif ($driver =~ /mysql/i) {
        $has_mid = grep { $_->[0] eq 'mid' }
            $dbh->selectall_arrayref("SHOW COLUMNS FROM history")->@*;
    } else {
        $has_mid = grep { $_->[0] eq 'mid' }
            $dbh->selectall_arrayref(
                q{SELECT column_name FROM information_schema.columns
                 WHERE table_name='history' AND column_name='mid'})->@*;
    }
    $dbh->do("ALTER TABLE history ADD COLUMN mid TEXT")
        unless $has_mid;
}

method _schema_version($root_path) {
    my $sql_file = "$root_path/Classifier/popfile.sql";
    return undef
        unless -e $sql_file;
    open my $fh, '<', $sql_file
        or return undef;
    <$fh> =~ /-- POPFILE SCHEMA (\d+)/;
    my $version = $1;
    close $fh;
    return $version
}

method _create($dbh, $root_path, $is_sqlite) {
    my $sql_file = "$root_path/Classifier/popfile.sql";
    return 0
        unless -e $sql_file;
    open my $fh, '<', $sql_file
        or return 0;
    my $schema = '';
    while (<$fh>) {
        next
            if /^--/ || !/[a-z;]/;
        s/--.*$//;
        next
            if $is_sqlite && /^alter/i;
        $schema .= $_;
        if (/end;/ || /\);/ || /^alter/i) {
            $dbh->do($schema);
            $schema = '';
        }
    }
    close $fh;
    return 1
}

method _upgrade($dbh, $root_path, $is_sqlite) {
    print "\n\nDatabase schema is outdated, performing automatic upgrade\n";
    my $user_path = $root_path;
    $user_path =~ s!/Classifier/*$!!;
    return $self->_dump_restore($dbh, $root_path, $user_path, $is_sqlite)
}

method _dump_restore($dbh, $root_path, $user_path, $is_sqlite) {
    my $sqlquotechar = $dbh->get_info(29) || '';
    my @tables = map { s/$sqlquotechar//g; $_ } $dbh->tables();
    my $ins_file = "$user_path/insert.sql";
    $_serial = 0;
    open my $fh, '>', $ins_file
        or return 0;
    for my $table (@tables) {
        next
            if $table =~ /\.?popfile$/
            || ($is_sqlite && $table =~ /(?:^|\.)sqlite_/);
        print "    Saving table $table\n    ";
        my $sth = $dbh->prepare("select * from $table");
        $sth->execute();
        while (my $row = $sth->fetchrow_arrayref) {
            $self->_progress();
            my $kw = $is_sqlite ? 'INSERT OR IGNORE' : 'INSERT';
            my @names = @{$sth->{NAME}};
            my @vals = map {
                my $v = $row->[$_];
                $sth->{TYPE}->[$_] !~ /^int/i
                    ? $dbh->quote(defined($v) ? do { $v =~ s/\x00//g; $v } : '')
                    : (defined($v) ? $v : 'NULL')
            } 0 .. $#{$row};
            print $fh "$kw INTO $table (" . join(',', @names)
                . ') VALUES (' . join(',', @vals) . ");\n";
        }
        $sth->finish();
    }
    close $fh;
    for my $table (@tables) {
        next
            if $is_sqlite && $table =~ /(?:^|\.)sqlite_/;
        print "    Dropping old table $table\n";
        $dbh->do("DROP TABLE $table");
    }
    print "    Inserting new database schema\n";
    $self->_create($dbh, $root_path, $is_sqlite)
        or return 0;
    print "    Restoring old data\n    ";
    $_serial = 0;
    $dbh->begin_work();
    open my $infh, '<', $ins_file
        or return 0;
    while (<$infh>) {
        $self->_progress();
        s/[\r\n]//g;
        $dbh->do($_);
    }
    close $infh;
    $dbh->commit();
    unlink $ins_file;
    print "\nDatabase upgrade complete\n\n";
    return 1
}

method _progress() {
    $_serial++;
    if ($_serial % 100 == 0) {
        print "[$_serial]";
        STDOUT->flush();
    }
    if ($_serial % 1000 == 0) {
        print "\n";
        STDOUT->flush();
    }
}

1;
