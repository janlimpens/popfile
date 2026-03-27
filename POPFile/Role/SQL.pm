use Object::Pad;

role POPFile::Role::SQL {

    method normalize_sql ($sql) {
        $sql =~ s/\s+/ /g;
        $sql =~ s/^ | $//g;
        return $sql
    }
}
