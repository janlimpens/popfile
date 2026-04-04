# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
use Object::Pad;

role POPFile::Role::SQL {
    method normalize_sql ($sql) {
        $sql =~ s/\s+/ /g;
        $sql =~ s/^ | $//g;
        return $sql
    }
}
