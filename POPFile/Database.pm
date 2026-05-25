# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use File::Copy qw(copy);
use Encode ();
use POPFile::Mutex;

my $_instance;

class POPFile::Database;

use POPFile::Features;

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
field $_is_sqlite = 0;
field $_mojo_db = undef;
field $_dbh = undef;
field $_config = {};
field $write_mutex = undef;

method instance :common (%config) {
    $_instance //= __PACKAGE__->new();
    $_instance->configure(%config)
        if %config;
    return $_instance
}

method configure(%config) {
    $_config->%* = ($_config->%*, %config);
    undef $_dbh;
}

method get_handle(%overrides) {
    return $_dbh
        if defined $_dbh && $_pid == $$ && !%overrides;
    $_dbh = $self->_connect(%overrides);
    $_pid = $$;
    return $_dbh
}

method txn($coderef) {
    $write_mutex //= POPFile::Mutex->new('db_write');
    $write_mutex->acquire(30)
        or die 'Could not acquire database write lock';
    my $dbh = $self->get_handle();
    $dbh->begin_work();
    try {
        $coderef->();
        $dbh->commit();
    } catch ($e) {
        $dbh->rollback();
        die $e;
    } finally {
        $write_mutex->release();
    }
}

method disconnect() {
    undef $_mojo_db;
    undef $_dbh;
}

method backup($db_path) {
    return
        unless $_is_sqlite;
    copy($db_path, "$db_path.backup")
        or die "Failed to backup database: $!";
}

method _connect(%overrides) {
    my %c = ($_config->%*, %overrides);
    my $dbconnect = $c{dbconnect} || 'dbi:SQLite:dbname=$dbname';
    my $sqlite = ($dbconnect =~ /sqlite/i);
    my $mysql = ($dbconnect =~ /mysql/i);
    my $dbname = $c{database} || 'popfile.db';
    $dbconnect =~ s/\$dbname/$dbname/g;
    if ($sqlite) {
        require Mojo::SQLite;
        my $mojo = Mojo::SQLite->new($dbname);
        $_mojo_db = $mojo->db();
        $_is_sqlite = 1;
        $_mojo_db->query('PRAGMA journal_mode=WAL');
        $_mojo_db->query('PRAGMA synchronous=NORMAL');
        $_mojo_db->query('PRAGMA busy_timeout=10000');
        my $jm = $c{sqlite_journal_mode} // '';
        $_mojo_db->query('PRAGMA journal_mode=' . $jm)
            if $jm;
    } elsif ($mysql) {
        my $user = $c{dbuser} // '';
        my $auth = $c{dbauth} // '';
        require Mojo::mysql;
        my $mojo = Mojo::mysql->new("mysql://$user:$auth\@localhost/$dbname");
        $mojo->options({mysql_auto_reconnect => 1});
        $_mojo_db = $mojo->db();
    } else {
        my $user = $c{dbuser} // '';
        my $auth = $c{dbauth} // '';
        require Mojo::Pg;
        my $mojo = Mojo::Pg->new("postgresql://$user:$auth\@localhost/$dbname");
        $_mojo_db = $mojo->db();
    }
    return $self->_install_fetch_callback($_mojo_db)
}

method _install_fetch_callback($dbh) {
    $dbh->ping();
    my $raw = $dbh->dbh();
    $raw->{Callbacks}{ChildCallbacks}{fetch} = sub {
        my ($h, $row) = @_;
        return
            unless $row;
        for my $val ($row->@*) {
            next
                unless defined $val && !ref $val && !utf8::is_utf8($val);
            $val = Encode::decode('iso-8859-1', $val);
        }
        return
    };
    return $raw
}

1;
