# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Features;

my $_instance;

class POPFile::Database;

=head1 NAME

POPFile::Database — shared database connection singleton

=head1 DESCRIPTION

A single DBI handle is created on first access and shared across all
modules.  The handle is lazily re-created after a fork (detected via
PID change) so that subprocesses spawned by C<Mojo::IOLoop> remain safe.

Connection parameters are passed through C<configure(%params)> during
startup.  The singleton knows nothing about module namespaces or the
POPFile API object.

Modules call C<get_handle()> instead of managing their own connections.
Transaction wrapping is provided by C<txn($coderef)>.

=cut

field $_pid = $$;
field $_mojo_db = undef;
field $_dbh = undef;
field $_config = {};

method instance :common (%config) {
    $_instance //= __PACKAGE__->new();
    $_instance->configure(%config)
        if %config;
    return $_instance
}

method configure(%config) {
    %$_config = (%$_config, %config);
}

method get_handle(%overrides) {
    return $_dbh
        if defined $_dbh && $_pid == $$ && !%overrides;
    $_dbh = $self->_connect(%overrides);
    $_pid = $$;
    return $_dbh
}

method txn($coderef) {
    my $dbh = $self->get_handle();
    $dbh->begin_work();
    try {
        $coderef->();
        $dbh->commit();
    } catch ($e) {
        $dbh->rollback();
        die $e;
    }
}

method disconnect() {
    undef $_mojo_db;
    undef $_dbh;
}

method _connect(%overrides) {
    my %c = (%$_config, %overrides);
    my $dbconnect = $c{dbconnect} // 'dbi:SQLite:dbname=$dbname';
    my $sqlite = ($dbconnect =~ /sqlite/i);
    my $mysql = ($dbconnect =~ /mysql/i);
    my $dbname = $c{database} // 'popfile.db';
    $dbconnect =~ s/\$dbname/$dbname/g;
    my $dsn;
    if ($sqlite) {
        $dsn = $dbname;
        require Mojo::SQLite;
        $_mojo_db = Mojo::SQLite->new($dsn);
        $_mojo_db->options(sqlite_unicode => 1);
    } elsif ($mysql) {
        my $user = $c{dbuser} // '';
        my $auth = $c{dbauth} // '';
        $dsn = "mysql://$user:$auth\@localhost/$dbname";
        require Mojo::mysql;
        $_mojo_db = Mojo::mysql->new($dsn);
        $_mojo_db->options(mysql_auto_reconnect => 1);
    } else {
        my $user = $c{dbuser} // '';
        my $auth = $c{dbauth} // '';
        $dsn = "postgresql://$user:$auth\@localhost/$dbname";
        require Mojo::Pg;
        $_mojo_db = Mojo::Pg->new($dsn);
    }
    return $_mojo_db->db()
}

1;
