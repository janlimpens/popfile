# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;
use POPFile::Role::SQL;

class Services::Database :isa(POPFile::Module) :does(POPFile::Role::SQL);

use DBI;

field %handles;
field $dsn :writer = '';
field $user :writer = '';
field $auth :writer = '';
field $options :writer = {};
field $dialect :reader = 'sqlite';

BUILD {
    $self->set_name('database');
}

method initialize() {
    $self->config('dbtype', 'sqlite');
    return 1
}

method start() {
    $dialect = $self->config('dbtype') || 'sqlite';
    return 1
}

method db() {
    return $self->get_handle()
}

method get_handle ($name = 'default') {
    return $handles{$name}
        if defined $handles{$name} && $handles{$name}->ping();
    $handles{$name} = DBI->connect($dsn, $user, $auth, $options);
    return $handles{$name}
}

method forked ($writer = undef) {
    %handles = ();
}

method stop() {
    $_->disconnect()
        for values %handles;
    %handles = ();
}

1;
