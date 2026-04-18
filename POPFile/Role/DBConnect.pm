# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::DBConnect;

field $_mojo    = undef;
field $_mojo_db = undef;

method _connect ($dsn, %opts) {
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
    return $_mojo_db->dbh
}

method db () {
    return defined $_mojo_db ? $_mojo_db->dbh : undef
}

method mojo () { return $_mojo }

method _disconnect () {
    undef $_mojo_db;
    undef $_mojo
}

1;
