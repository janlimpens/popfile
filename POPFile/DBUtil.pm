# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
#
# POPFile::DBUtil — dependency-free SQL helpers usable by any Perl class
#
#   use POPFile::DBUtil qw(normalize_sql scrub);
#   my $sql  = normalize_sql(' SELECT 1   FROM  x ');
#   my $safe = scrub($user_input);          # strips \0 silently
#   my $cleaned = scrub($val, sub { warn "null-byte in $_[0]" });
#
# These are plain subroutines — no Object::Pad, no POPFile::Module needed.

package POPFile::DBUtil;

use Exporter qw(import);
our @EXPORT_OK = qw(db_exec normalize_sql scrub);

sub normalize_sql {
    my $sql = shift;
    return $sql
        unless defined $sql;
    $sql =~ s/\s+/ /g;
    $sql =~ s/^ | $//g;
    return $sql
}

sub scrub {
    my ($value, $on_null) = @_;
    return $value
        unless defined $value && length $value;
    my $count = $value =~ tr/\x00//;
    if ($count) {
        $on_null->($value)
            if $on_null;
        $value =~ s/\x00//g;
    }
    return $value
}

sub db_exec {
    my ($dbh, $sql, @params) = @_;
    $sql = normalize_sql($sql);
    $sql = scrub($sql);
    @params = map { scrub($_) } @params;
    my $sth = $dbh->prepare($sql)
        or return;
    $sth->execute(@params)
        or return;
    $sth
}

1;
