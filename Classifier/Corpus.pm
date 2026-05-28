# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Jan Limpens
package Classifier::Corpus;

use Object::Pad;
use POPFile::Features;
use List::Util qw(max);
use lib 'vendor/perl-querybuilder/lib';

class Classifier::Corpus;

=head1 NAME

Classifier::Corpus — word-count queries backed by Bayes' in-memory caches

=head1 DESCRIPTION

Stateless query methods for the word-count caches maintained by Bayes.
All cache hashes and DB handles are passed as parameters.

=cut

method bucket_count($bcount, $userid, $bucket) {
    return $bcount->{$userid}{$bucket}
        // 0
}

method bucket_unique($bunique, $userid, $bucket) {
    return $bunique->{$userid}{$bucket}
        // 0
}

method total_count($bcount, $bidcache, $userid) {
    my $total = 0;
    for my $name (sort keys $bidcache->{$userid}->%*) {
        next
            if $bidcache->{$userid}{$name}{pseudo};
        $total += $bcount->{$userid}{$name}
            // 0;
    }
    return $total
}

method total_unique($bunique, $bidcache, $userid) {
    my $total = 0;
    for my $name (sort keys $bidcache->{$userid}->%*) {
        next
            if $bidcache->{$userid}{$name}{pseudo};
        $total += $bunique->{$userid}{$name}
            // 0;
    }
    return $total
}

method word_count($dbh, $bidcache, $userid, $bucket, $word) {
    return
        unless defined $bidcache->{$userid}{$bucket};
    my $bucketid = $bidcache->{$userid}{$bucket}{id};
    my $h = $dbh->prepare('SELECT id FROM words WHERE word = ?');
    $h->execute($word);
    my $row = $h->fetchrow_arrayref;
    return
        unless defined $row;
    my $wordid = $row->[0];
    my $h2 = $dbh->prepare('SELECT times FROM matrix WHERE bucketid = ? AND wordid = ?');
    $h2->execute($bucketid, $wordid);
    $row = $h2->fetchrow_arrayref;
    return $row->[0]
        if defined $row;
    return
}

method word_list_for_bucket($dbh, $bucketid, $prefix) {
    $prefix = '' unless defined $prefix;
    $prefix =~ s/\0//g;
    my $rows = $dbh->selectall_arrayref('
        SELECT words.id, words.word, matrix.times
        FROM matrix, words
        WHERE matrix.wordid = words.id
            AND matrix.bucketid = ?
            AND words.word LIKE ?', undef, $bucketid, "$prefix%");
    return $rows->@*
}

# ── word-count cache refresh (mutates hashes passed by reference) ──

method refresh_counts($dbh, $bcount, $bunique, $id_cache, $userid,
                       $updated_bucket, $deleted_bucket) {
    if (defined $updated_bucket
            && defined $id_cache->{$userid}{$updated_bucket}) {
        my $bid = $id_cache->{$userid}{$updated_bucket}{id};
        my $row = $dbh->selectrow_arrayref(
            'SELECT sum(times), count(*) FROM matrix WHERE bucketid = ?',
            undef, $bid);
        $bcount->{$userid}{$updated_bucket} =
            (defined $row->[0] ? $row->[0] : 0);
        $bunique->{$userid}{$updated_bucket} = $row->[1];
        return 1
    }
    if (defined $deleted_bucket) {
        delete $bcount->{$userid}{$deleted_bucket};
        delete $bunique->{$userid}{$deleted_bucket};
        return 1
    }
    delete $bcount->{$userid};
    delete $bunique->{$userid};
    my $sth = $dbh->prepare(
        'SELECT sum(matrix.times), count(matrix.id), buckets.name
         FROM matrix, buckets
         WHERE matrix.bucketid = buckets.id
            AND buckets.userid = ?
         GROUP BY buckets.name');
    $sth->execute($userid);
    for my $b (sort keys $id_cache->{$userid}->%*) {
        $bcount->{$userid}{$b} = 0;
        $bunique->{$userid}{$b} = 0;
    }
    while (my $row = $sth->fetchrow_arrayref) {
        $bcount->{$userid}{$row->[2]} = $row->[0];
        $bunique->{$userid}{$row->[2]} = $row->[1];
    }
    0
}

# ── training ──

method add_words($dbh, $bucketid, $subtract, %words) {
    my @sorted_words = sort keys %words;
    my @id_list;
    my %wordmap;
    my $chunk_size = 2000;
    my @chunks = @sorted_words;
    while (@chunks) {
        my @chunk = splice @chunks, 0, $chunk_size;
        my $placeholders = join(', ', ('?') x @chunk);
        my $sth = $dbh->prepare(
            "SELECT id, word FROM words WHERE word IN ($placeholders)");
        $sth->execute(@chunk);
        while (my $row = $sth->fetchrow_arrayref) {
            push @id_list, $row->[0];
            $wordmap{$row->[1]} = $row->[0];
        }
    }
    my %counts;
    if (@id_list) {
        my @id_chunks = @id_list;
        while (@id_chunks) {
            my @chunk = splice @id_chunks, 0, $chunk_size;
            my $placeholders = join(', ', ('?') x @chunk);
            my @params = (@chunk, $bucketid);
            my $sth = $dbh->prepare(
                "SELECT matrix.times, matrix.wordid FROM matrix
                 WHERE matrix.wordid IN ($placeholders)
                    AND matrix.bucketid = ?");
            $sth->execute(@params);
            while (my $row = $sth->fetchrow_arrayref) {
                $counts{$row->[1]} = $row->[0];
            }
        }
    }
    $dbh->begin_work;
    for my $word (sort keys %words) {
        if (defined $wordmap{$word} && defined $counts{$wordmap{$word}}) {
            my $new = max(0, $counts{$wordmap{$word}}
                + $subtract * $words{$word});
            $dbh->do(
                'REPLACE INTO matrix (bucketid, wordid, times, lastseen)
                 VALUES (?, ?, ?, date(\'now\'))',
                undef, $bucketid, $wordmap{$word}, $new);
        } elsif ($subtract == 1) {
            my $sth = $dbh->prepare(
                'SELECT id FROM words WHERE word = ?');
            $sth->execute($word);
            my $row = $sth->fetchrow_arrayref;
            unless (defined $row) {
                $dbh->do(
                    'INSERT INTO words (word) VALUES (?)',
                    undef, $word);
                $row = $dbh->selectrow_arrayref(
                    'SELECT id FROM words WHERE word = ?',
                    undef, $word);
            }
            my $wordid = $row->[0];
            $dbh->do(
                'REPLACE INTO matrix (bucketid, wordid, times, lastseen)
                 VALUES (?, ?, ?, date(\'now\'))',
                undef, $bucketid, $wordid, $words{$word});
        }
    }
    if ($subtract == -1) {
        $dbh->do(
            'DELETE FROM matrix
             WHERE (matrix.times <= 0 OR matrix.times IS NULL)
                AND matrix.bucketid = ?',
            undef, $bucketid);
    }
    $dbh->commit;
}

method remove_word($dbh, $bucketid, $word) {
    my $row = $dbh->selectrow_arrayref(
        'SELECT id FROM words WHERE word = ?', undef, $word);
    return
        unless defined $row;
    $dbh->do(
        'DELETE FROM matrix WHERE bucketid = ? AND wordid = ?',
        undef, $bucketid, $row->[0]);
    1
}

method move_word($dbh, $from_id, $to_id, $word) {
    my $word_row = $dbh->selectrow_arrayref(
        'SELECT id FROM words WHERE word = ?', undef, $word);
    return
        unless defined $word_row;
    my $wordid = $word_row->[0];
    my $count_row = $dbh->selectrow_arrayref(
        'SELECT times FROM matrix WHERE bucketid = ? AND wordid = ?',
        undef, $from_id, $wordid);
    return
        unless defined $count_row;
    my $count = $count_row->[0];
    $dbh->do(
        'DELETE FROM matrix WHERE bucketid = ? AND wordid = ?',
        undef, $from_id, $wordid);
    my $existing = $dbh->selectrow_arrayref(
        'SELECT times FROM matrix WHERE bucketid = ? AND wordid = ?',
        undef, $to_id, $wordid);
    if (defined $existing) {
        $dbh->do(
            'UPDATE matrix SET times = times + ?, lastseen = date(\'now\')
             WHERE bucketid = ? AND wordid = ?',
            undef, $count, $to_id, $wordid);
    } else {
        $dbh->do(
            'INSERT INTO matrix (bucketid, wordid, times) VALUES (?, ?, ?)',
            undef, $to_id, $wordid, $count);
    }
    1
}

method word_count_get($dbh, $bucketid, $word) {
    state $sth_wordid;
    state $sth_count;
    unless ($sth_wordid) {
        $sth_wordid = $dbh->prepare(
            'SELECT id FROM words WHERE word = ? LIMIT 1');
        $sth_count = $dbh->prepare(
            'SELECT matrix.times FROM matrix
             WHERE matrix.bucketid = ? AND matrix.wordid = ? LIMIT 1');
    }
    $sth_wordid->execute($word);
    my $row = $sth_wordid->fetchrow_arrayref;
    return
        unless defined $row;
    $sth_count->execute($bucketid, $row->[0]);
    $row = $sth_count->fetchrow_arrayref;
    return $row->[0]
        if defined $row;
    return
}

method word_count_set($dbh, $bucketid, $word, $count) {
    state $sth_wordid;
    state $sth_put;
    unless ($sth_wordid) {
        $sth_wordid = $dbh->prepare(
            'SELECT id FROM words WHERE word = ? LIMIT 1');
        $sth_put = $dbh->prepare(
            'REPLACE INTO matrix (bucketid, wordid, times, lastseen)
             VALUES (?, ?, ?, date(\'now\'))');
    }
    $sth_wordid->execute($word);
    my $row = $sth_wordid->fetchrow_arrayref;
    unless (defined $row) {
        $dbh->do('INSERT INTO words (word) VALUES (?)',
            undef, $word);
        $sth_wordid->execute($word);
        $row = $sth_wordid->fetchrow_arrayref;
    }
    return
        unless defined $row;
    $sth_put->execute($bucketid, $row->[0], $count);
    1
}

method raw_word_prefixes($dbh, $bucketid) {
    return $dbh->selectcol_arrayref("
        SELECT words.word FROM matrix, words
        WHERE matrix.wordid = words.id
            AND matrix.bucketid = ?", undef, $bucketid)
}

method word_for_id($dbh, $id) {
    my $row = $dbh->selectrow_arrayref(
        'SELECT word FROM words WHERE id = ?', undef, $id);
    return $row ? $row->[0] : undef
}

# ── word search ──

my %sort_map = (
    relevance => 'CAST(bucket_count AS FLOAT) / (total_count + 10)',
    count     => 'bucket_count',
    total     => 'total_count',
    word      => 'word',
);

method bucket_word_page($dbh, $bucketid, $sort, $dir, $per_page, $offset) {
    my $sort_col = $sort_map{ $sort // 'relevance' } // $sort_map{relevance};
    my $total = $dbh->selectrow_array(
        'SELECT COUNT(*) FROM matrix WHERE bucketid = ?',
        undef, $bucketid) // 0;
    my $rows = $dbh->selectall_arrayref(
        "WITH wc AS (
             SELECT w.id, w.word,
                    m.times AS bucket_count,
                    COALESCE((SELECT SUM(m2.times)
                              FROM matrix m2
                              WHERE m2.wordid = m.wordid), 0) AS total_count
             FROM matrix m
             JOIN words w ON w.id = m.wordid
             WHERE m.bucketid = ?
         )
         SELECT id, word, bucket_count, total_count
         FROM wc
         ORDER BY $sort_col $dir
         LIMIT ? OFFSET ?",
        { Slice => {} }, $bucketid, $per_page, $offset);
    return ([], 0)
        unless $rows && $rows->@*;
    my @words = map {
        my $c = $_->{bucket_count} + 0;
        my $tc = $_->{total_count} + 0;
        my $acc = $tc > 0 ? $c / $tc : 0;
        { id => $_->{id} + 0,
          word => $_->{word},
          count => $c,
          total => $tc,
          accuracy => $acc }
    } $rows->@*;
    return (\@words, $total)
}

method search_words_cross($dbh, $qb, $userid, $prefix, $bucket_filter,
                           $sort, $dir, $per_page, $offset) {
    my $pattern = ($prefix // '') . '%';
    my @joins = (
        $qb->join('matrix m', on => $qb->compare('m.wordid', \'w.id')),
        $qb->join('buckets b', on => $qb->compare('b.id', \'m.bucketid')));
    my $where = $qb->combine_and(
        $qb->like('w.word', $pattern),
        $qb->compare('b.userid', $userid),
        $qb->is_false('b.pseudo'));
    if ($bucket_filter ne '') {
        my $exists = $qb->exists(
            $qb->select('1')
                ->from('matrix mf')
                ->joins($qb->join('buckets bf',
                    on => $qb->combine_and(
                        $qb->compare('bf.id', \'mf.bucketid'),
                        $qb->compare('bf.name', $bucket_filter))))
                ->where($qb->compare('mf.wordid', \'w.id')));
        $where->add_expression($exists);
    }
    my %sql_sort = (word => 'w.word', coverage => 'coverage', total => 'total');
    my (@words, $total);
    if (exists $sql_sort{$sort}) {
        my $count_q = $qb->select('COUNT(DISTINCT w.id)')
            ->from('words w')->joins(@joins)->where($where);
        my $row = do {
            try {
                $dbh->selectrow_arrayref(
                    $count_q->as_sql(), undef, $count_q->params())
            } catch ($e) { undef }
        };
        $total = $row ? $row->[0] + 0 : 0;
        my $q = $qb->select(
                'w.word',
                'COUNT(DISTINCT m.bucketid) AS coverage',
                'SUM(m.times) AS total')
            ->from('words w')->joins(@joins)->where($where)
            ->group_by('w.id', 'w.word')
            ->order_by($qb->order_by($sql_sort{$sort}, $dir))
            ->limit($per_page)->offset($offset);
        @words = do {
            try {
                map { $_->[0] }
                    $dbh->selectall_arrayref(
                        $q->as_sql(), undef, $q->params())->@*
            } catch ($e) { () }
        };
    } else {
        my $q = $qb->select('w.word')->from('words w')
            ->joins(@joins)->where($where)->group_by('w.id', 'w.word');
        my $all = do {
            try {
                $dbh->selectall_arrayref(
                    $q->as_sql(), undef, $q->params())
            } catch ($e) { undef }
        };
        $total = $all ? scalar $all->@* : 0;
        @words = $all ? map { $_->[0] } $all->@* : ();
    }
    return (\@words, $total, {})
        unless @words;
    my %data;
    my $chunk_size = 2000;
    my @remaining = @words;
    while (@remaining) {
        my @chunk = splice @remaining, 0, $chunk_size;
        my $where2 = $qb->combine_and(
            $qb->compare('w.word', \@chunk),
            $qb->compare('b.userid', $userid),
            $qb->is_false('b.pseudo'));
        my $q2 = $qb->select('w.word', 'b.name', 'm.times')
            ->from('words w')->joins(@joins)->where($where2);
        my $sth;
        try {
            $sth = $dbh->prepare($q2->as_sql());
            $sth->execute($q2->params())
                if $sth
        } catch ($e) {
            $sth = undef
        }
        next
            unless $sth;
        while (my $r = do { try { $sth->fetchrow_hashref() } catch ($e) { undef } }) {
            $data{$r->{word}}{$r->{name}} = $r->{times} + 0;
        }
    }
    if (!exists $sql_sort{$sort}) {
        @words = map { $_->[0] }
            sort { ($data{$b->[0]}{$sort} // 0) <=> ($data{$a->[0]}{$sort} // 0) }
            map { [$_] } @words;
        @words = reverse @words
            if $dir eq 'ASC';
        @words = grep { defined } @words[$offset .. $offset + $per_page - 1];
    }
    return (\@words, $total, \%data)
}

method resolve_word_ids($dbh, $words) {
    my @id_list;
    my %idmap;
    my $chunk_size = 2000;
    my @chunks = $words->@*;
    while (@chunks) {
        my @chunk = splice @chunks, 0, $chunk_size;
        my $ph = join(', ', ('?') x @chunk);
        my $sth = $dbh->prepare(
            "SELECT id, word FROM words WHERE word IN ($ph) ORDER BY id");
        $sth->execute(@chunk);
        while (my $row = $sth->fetchrow_arrayref) {
            push @id_list, $row->[0];
            $idmap{$row->[0]} = $row->[1];
        }
    }
    return (\@id_list, \%idmap)
}

method fetch_matrix($dbh, $ids, $userid) {
    my %matrix;
    return \%matrix
        unless $ids->@*;
    my $chunk_size = 2000;
    my @chunks = $ids->@*;
    while (@chunks) {
        my @chunk = splice @chunks, 0, $chunk_size;
        my $ph = join(', ', ('?') x @chunk);
        my $sth = $dbh->prepare(
            "SELECT matrix.times, matrix.wordid, buckets.name
             FROM matrix, buckets
             WHERE matrix.wordid IN ($ph)
                AND matrix.bucketid = buckets.id
                AND buckets.userid = ?");
        $sth->execute(@chunk, $userid);
        while (my $row = $sth->fetchrow_arrayref) {
            $matrix{$row->[1]}{$row->[2]} = $row->[0];
        }
    }
    return \%matrix
}

method resolve_and_fetch_matrix($dbh, $words, $userid) {
    my @id_list;
    my %idmap;
    my %matrix;
    return (\@id_list, \%idmap, \%matrix)
        unless $words->@*;
    my $chunk_size = 2000;
    my @chunks = $words->@*;
    while (@chunks) {
        my @chunk = splice @chunks, 0, $chunk_size;
        my $ph = join(', ', ('?') x @chunk);
        my $sth = $dbh->prepare(
            "SELECT w.id, w.word, m.times, b.name
             FROM words w
             LEFT JOIN matrix m ON m.wordid = w.id
             LEFT JOIN buckets b ON b.id = m.bucketid AND b.userid = ?
             WHERE w.word IN ($ph)
             ORDER BY w.id");
        $sth->execute($userid, @chunk);
        while (my $row = $sth->fetchrow_arrayref) {
            my ($id, $word, $times, $bucket) = $row->@*;
            unless (exists $idmap{$id}) {
                push @id_list, $id;
                $idmap{$id} = $word;
            }
            $matrix{$id}{$bucket} = $times
                if defined $bucket && defined $times && $times > 0;
        }
    }
    return (\@id_list, \%idmap, \%matrix)
}

1;
