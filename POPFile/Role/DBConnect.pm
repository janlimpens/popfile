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
    $_mojo_db = $_mojo->db();
    my $dbh = $_mojo_db->dbh();
    $self->_apply_sqlite_optimizations($dbh);
    return $dbh
}

method connect_db(%overrides) {
    my $dbconnect = $overrides{dbconnect} // $self->config('dbconnect');
    my $sqlite = ($dbconnect =~ /sqlite/i);
    my $mysql = ($dbconnect =~ /mysql/i);
    my $dbname;
    my %opts;
    if ($sqlite) {
        $dbname = $dbconnect =~ /:memory:/i
            ? ':memory:'
            : $self->get_user_path($overrides{database} // $self->config('database'));
        $opts{sqlite_unicode} = 1;
    } else {
        $dbname = $overrides{database} // $self->config('database');
        $opts{mysql_auto_reconnect} = 1
            if $mysql;
    }
    $dbconnect =~ s/\$dbname/$dbname/g;
    $self->log_msg(INFO => "Connecting to $dbconnect");
    my $dsn;
    if ($sqlite) {
        $dsn = $dbname;
    } elsif ($mysql) {
        my $user = $overrides{dbuser} // $self->config('dbuser') // '';
        my $auth = $overrides{dbauth} // $self->config('dbauth') // '';
        my ($host) = ($dbconnect =~ /host=([^;]+)/i);
        $host //= 'localhost';
        $dsn = "mysql://$user:$auth\@$host/$dbname";
    } else {
        my $user = $overrides{dbuser} // $self->config('dbuser') // '';
        my $auth = $overrides{dbauth} // $self->config('dbauth') // '';
        my ($host) = ($dbconnect =~ /host=([^;]+)/i);
        $host //= 'localhost';
        $dsn = "postgresql://$user:$auth\@$host/$dbname";
    }
    return $self->_connect($dsn, %opts)
}

method get_handle () {
    return defined $_mojo_db ? $_mojo_db->dbh() : undef
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
