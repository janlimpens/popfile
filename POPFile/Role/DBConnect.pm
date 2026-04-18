# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::DBConnect;

field $_mojo    = undef;
field $_mojo_db = undef;

method _connect ($dbname, %opts) {
    my $type = $self->config('dbtype') // 'sqlite';
    if ($type eq 'mysql') {
        require Mojo::mysql;
        my $user = $self->config('dbuser') // '';
        my $auth = $self->config('dbauth') // '';
        $_mojo = Mojo::mysql->new("mysql://$user:$auth\@$dbname");
    } elsif ($type eq 'pg') {
        require Mojo::Pg;
        my $user = $self->config('dbuser') // '';
        my $auth = $self->config('dbauth') // '';
        $_mojo = Mojo::Pg->new("postgresql://$user:$auth\@$dbname");
    } else {
        require Mojo::SQLite;
        $_mojo = Mojo::SQLite->new($dbname);
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
