# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package POPFile::HistoryQueries;

=head1 NAME

POPFile::HistoryQueries — paged query sessions over the history table

=head1 DESCRIPTION

Manages named query sessions that support filtering, full-text search, sorting,
and lazy result caching. Each session is identified by a random hex ID.

All database access is done through a DBI handle passed in method signatures.
Query::Builder is used for dynamic SQL construction (filtering, search, sorting).

=cut

use Object::Pad;
use POPFile::Features;
use lib 'vendor/perl-querybuilder/lib';
use Query::Builder;
use DBI;

class POPFile::HistoryQueries;

my %driver_map = (
    SQLite => 'sqlite',
    mysql => 'mysql',
    Pg => 'postgresql');

field $_qb;

method _init_qb($dbh) {
    return $_qb if defined $_qb;
    my $driver = $dbh->{Driver}->{Name};
    my $dialect = $driver_map{$driver} // 'sqlite';
    $_qb = Query::Builder->new(dialect => $dialect);
    return $_qb
}

my @fields = (
    'history.id AS "slot"',
    'hdr_from AS "from"',
    'hdr_to AS "to"',
    'hdr_cc AS "cc"',
    'hdr_subject AS "subject"',
    'hdr_date AS "date"',
    'hash',
    'inserted',
    'buckets.name AS "bucket"',
    'usedtobe',
    'history.bucketid AS "bucket_id"',
    'magnets.val AS "magnet"',
    'size',
    'mid');

my $fields_slot = join ', ', @fields;

field %sessions;

method start() {
    while (1) {
        my $id = sprintf('%8.8x', int(rand(4294967295)));
        unless (defined $sessions{$id}) {
            $sessions{$id}{query} = 0;
            $sessions{$id}{count} = 0;
            $sessions{$id}{cache} = ();
            return $id
        }
    }
}

method stop($id) {
    my $query_sth = $sessions{$id}{query};
    if (defined $query_sth && $query_sth != 0) {
        if ($#{$sessions{$id}{cache}} != $sessions{$id}{count}) {
            $query_sth->finish();
            undef $sessions{$id}{query};
        }
    }
    delete $sessions{$id};
}

method set($id, $filter, $search, $sort, $not, $dbh) {
    $search =~ s/\0//g;
    $sort = ''
        if $sort !~ /^(\-)?(inserted|from|to|cc|subject|bucket|date|size)$/;
    if (defined($sessions{$id}{fields})
        && $sessions{$id}{fields} eq "$filter:$search:$sort:$not") {
        return;
    }
    $sessions{$id}{fields} = "$filter:$search:$sort:$not";
    my $qb = $self->_init_qb($dbh);
    $sessions{$id}{base} =
        'select XXX from history, buckets
                left join magnets on magnets.id = history.magnetid
                where history.userid = 1 and committed = 1';
    $sessions{$id}{base} .= ' and history.bucketid = buckets.id';
    $sessions{$id}{params} = [];
    my $not_equal = $not ? '!=' : '=';
    my $equal = $not ? '=' : '!=';
    if ($search ne '') {
        my $pat = '%' . $search . '%';
        my $like_expr = $qb->combine_or(
            $qb->like('hdr_from', $pat),
            $qb->like('hdr_subject', $pat));
        my $expr = $not ? $qb->negate($like_expr) : $like_expr;
        $sessions{$id}{base} .= ' and ' . $expr->as_sql();
        push $sessions{$id}{params}->@*, $expr->params();
    }
    if ($filter ne '') {
        if ($filter eq '__filter__magnet') {
            $sessions{$id}{base} .= " and history.magnetid $equal 0";
        } elsif ($filter eq '__filter__reclassified') {
            $sessions{$id}{base} .= " and history.usedtobe $equal 0";
        } else {
            my $expr = $qb->compare('buckets.name', $filter,
                comparator => $not_equal);
            $sessions{$id}{base} .= ' and ' . $expr->as_sql();
            push $sessions{$id}{params}->@*, $expr->params();
        }
    }
    if ($sort ne '') {
        $sort =~ s/^(\-)//;
        my $direction = defined($1) ? 'desc' : 'asc';
        if ($sort eq 'bucket') { $sort = 'buckets.name' }
        elsif ($sort =~ /from|to|cc/) { $sort = "sort_$sort" }
        elsif ($sort ne 'inserted' && $sort ne 'size') { $sort = "hdr_$sort" }
        $sessions{$id}{base} .= " order by $sort $direction;";
    } else {
        $sessions{$id}{base} .= ' order by inserted desc;';
    }
    my $count = $sessions{$id}{base};
    $count =~ s/XXX/COUNT(*)/;
    my $sth = $dbh->prepare($count);
    $sth->execute($sessions{$id}{params}->@*);
    $sessions{$id}{count} = $sth->fetchrow_arrayref->[0];
    $sth->finish();
    my $select = $sessions{$id}{base};
    $select =~ s/XXX/$fields_slot/;
    $sessions{$id}{query} = $dbh->prepare($select);
    $sessions{$id}{cache} = ();
    return $sessions{$id}{count}
}

method search($dbh, %args) {
    my $qb = $self->_init_qb($dbh);
    my $where = $qb->combine(AND =>
        $qb->compare('history.userid', \1),
        $qb->compare('committed', \1),
        $qb->compare('history.bucketid' => \'buckets.id'));
    my $base_query = $qb
        ->select()
        ->from(qw(history buckets))
        ->joins($qb->join('magnets')->on($qb->compare('magnets.id', \'history.magnetid')))
        ->where($where);
    if (my $search_term = $args{search}) {
        $search_term =~ s/\0//g;
        $search_term =~ s/^\s+|\s+$//g;
        my $pat = "%$search_term%";
        my $like_expr = $qb->combine(OR =>
            $qb->like('hdr_from', $pat),
            $qb->like('hdr_subject', $pat));
        $where->add_expression($like_expr);
    }
    if (my $bucket = $args{bucket}) {
        $where->add_expression($qb->compare('buckets.name', $bucket));
    }
    my $count_q = $base_query->clone(columns => ['COUNT(*)']);
    my ($total) = $dbh->selectcol_arrayref($count_q->as_sql(), undef, $count_q->params())->@*;
    my $pagination = Data::Page->new();
    $pagination->total_entries($total);
    $pagination->entries_per_page($args{per_page} // 25);
    $pagination->current_page($args{page} // 1);
    my @columns = split /\s?,\s?/, $fields_slot;
    my $rows_q = $base_query->clone(columns => \@columns);
    if (my $sort_spec = $args{sort}) {
        ($sort_spec, my $direction) = split / /, $sort_spec;
        if ($sort_spec =~ /^-?(inserted|from|to|cc|subject|bucket|date|size)$/i) {
            $rows_q->order_by($qb->order_by($1, $direction // 'ASC'));
        }
    }
    $rows_q->limit($pagination->entries_per_page());
    $rows_q->offset($pagination->skipped());
    my $rows = $dbh->selectall_arrayref($rows_q->as_sql(), { Slice => {} }, $rows_q->params());
    return ($total + 0, $rows)
}

method session_count($id) {
    return $sessions{$id}{count}
}

method rows($id, $start, $count) {
    my $size = $#{$sessions{$id}{cache}} + 1;
    if ($size < ($start + $count - 1)) {
        $sessions{$id}{query}->execute($sessions{$id}{params}->@*);
        $sessions{$id}{cache} = $sessions{$id}{query}->fetchall_arrayref(
            undef, $start + $count - 1);
        $sessions{$id}{query}->finish();
    }
    my ($from, $to) = ($start - 1, $start + $count - 2);
    return $sessions{$id}{cache}->@[$from .. $to]
}

method invalidate_all() {
    $sessions{$_}{fields} = '' for keys %sessions
}

method delete_ids($id, $dbh) {
    my $delete = $sessions{$id}{base};
    $delete =~ s/XXX/history.id/;
    my $sth = $dbh->prepare($delete);
    $sth->execute($sessions{$id}{params}->@*);
    my @ids = map { $_->[0] } $sth->fetchall_arrayref->@*;
    $sth->finish();
    return \@ids
}

method base_query($id) {
    return $sessions{$id}{base}
}

method session_exists($id) {
    return exists $sessions{$id}
}

1;
