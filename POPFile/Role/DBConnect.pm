# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::DBConnect;

field $_mojo    = undef;
field $_mojo_db = undef;
field $_is_sqlite = 0;

method _connect ($dsn, %opts) {
    $_is_sqlite = ($dsn =~ /(\.db|:memory:)/ || $dsn !~ /^mysql:|^postgresql:/);
    if ($dsn =~ /^mysql:/) {
        require Mojo::mysql;
        $_mojo = Mojo::mysql->new($dsn);
    } elsif ($dsn =~ /^postgresql:/) {
        require Mojo::Pg;
        $_mojo = Mojo::Pg->new($dsn);
    } else {
        require Mojo::SQLite;
        $_mojo = Mojo::SQLite->new($dsn);
    }
    $_mojo->options(\%opts)
        if %opts;
    $_mojo_db = $_mojo->db;
    my $dbh = $_mojo_db->dbh;
    $self->_apply_sqlite_optimizations($dbh);
    return $dbh
}

method db () {
    return defined $_mojo_db ? $_mojo_db->dbh : undef
}

method mojo () { return $_mojo }

method _disconnect () {
    undef $_mojo_db;
    undef $_mojo;
    return 1
}

method is_sqlite () { return $_is_sqlite }

method _apply_sqlite_optimizations ($dbh) {
    return
        unless $_is_sqlite;
    if ($self->can('log_msg')) {
        $self->log_msg(INFO => "Using SQLite library version " . $dbh->{sqlite_version});
    }
    my $fast_writes = $self->can('config')
        ? $self->config('sqlite_fast_writes') : 0;
    if ($fast_writes) {
        $self->log_msg(INFO => "sqlite_fast_writes: synchronous=off")
            if $self->can('log_msg');
        $dbh->do('pragma synchronous=off');
    }
    if ($dbh->{sqlite_version} ge '3.6.0') {
        my $journal_mode = $self->can('config')
            ? $self->config('sqlite_journal_mode') : '';
        if ($journal_mode =~ /^(delete|truncate|persist|memory|off)$/i) {
            $dbh->do("pragma journal_mode=$journal_mode");
        }
    }
}

1;
