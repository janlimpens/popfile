# Cross-Bucket Word Search Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the per-bucket WordView and the Stopwords page with a single cross-bucket word search that shows per-bucket counts, is sortable by any column, and integrates stopword management.

**Architecture:** Two-query approach — Q1 fetches matching words with aggregate stats (SQL-sorted + paged for word/coverage/total sort; all-fetched for bucket-name sort), Q2 fetches per-bucket counts for the paged set, Perl pivots the result. Query::Builder constructs all queries. Frontend is a single Svelte component replacing both WordView and Stopwords.

**Tech Stack:** Perl 5.40, Object::Pad, Query::Builder (vendor/perl-querybuilder), Mojolicious, Svelte 5 (runes), Test2::V0, Test::Mojo.

---

### Task 1: Fix Query::Builder — GROUP BY / ORDER BY ordering bug

**Files:**
- Modify: `vendor/perl-querybuilder/lib/Query/Expression/Select.pm:44-48`
- Modify: `vendor/perl-querybuilder/t/test_select.t`

The `_build` method emits `ORDER BY` before `GROUP BY`, producing invalid SQL. Verified by running:
```
carton exec perl -Ivendor/perl-querybuilder/lib -e '...' | grep 'ORDER BY.*GROUP BY'
```

- [ ] **Step 1: Write the failing test in vendor/perl-querybuilder/t/test_select.t**

Add before `done_testing()`:
```perl
subtest 'GROUP BY comes before ORDER BY' => sub {
    my $qb = Query::Builder->new(dialect => 'sqlite');
    my $sql = $qb->select('word', 'COUNT(*) AS c')
        ->from('matrix')
        ->group_by('word')
        ->order_by($qb->order_by('c', 'DESC'));
    like "$sql", qr/GROUP BY word ORDER BY c DESC/, 'GROUP BY precedes ORDER BY';
};
```

- [ ] **Step 2: Run to confirm it fails**

```bash
cd vendor/perl-querybuilder && perl -Ilib t/test_select.t 2>&1 | tail -10
```
Expected: FAIL — current output has `ORDER BY c DESC GROUP BY word`.

- [ ] **Step 3: Fix Select.pm — swap the two add_part calls**

In `vendor/perl-querybuilder/lib/Query/Expression/Select.pm`, change the `_build` method. Find:
```perl
    $self->add_part(Query::Expression->new(parts => ['ORDER BY' => $self->_comma($order_by->@*)]))
        if $order_by->@*;
    $self->add_part(Query::Expression->new(parts => ['GROUP BY' => $self->_comma($group_by->@*)]))
        if $group_by->@*;
```
Replace with:
```perl
    $self->add_part(Query::Expression->new(parts => ['GROUP BY' => $self->_comma($group_by->@*)]))
        if $group_by->@*;
    $self->add_part(Query::Expression->new(parts => ['ORDER BY' => $self->_comma($order_by->@*)]))
        if $order_by->@*;
```

- [ ] **Step 4: Run tests**

```bash
cd vendor/perl-querybuilder && perl -Ilib t/test_select.t 2>&1
```
Expected: all subtests pass.

- [ ] **Step 5: Run full query builder test suite**

```bash
cd vendor/perl-querybuilder && perl -Ilib -MTest2::V0 t/*.t 2>&1 | tail -5
```
Expected: no failures.

- [ ] **Step 6: Commit and push PR in submodule**

```bash
cd vendor/perl-querybuilder
git checkout -b fix/group-by-order-by
git add lib/Query/Expression/Select.pm t/test_select.t
git commit -m "fix: emit GROUP BY before ORDER BY in Select _build"
git push origin fix/group-by-order-by
```
Then open a PR at https://github.com/janlimpens/perl-querybuilder from `fix/group-by-order-by` to `main`.

- [ ] **Step 7: Update submodule pointer in popfile repo**

```bash
cd /path/to/popfile
git add vendor/perl-querybuilder
git commit -m "chore: update perl-querybuilder — fix GROUP BY ordering"
```

---

### Task 2: Add search_words_cross_bucket to Classifier::Bayes

**Files:**
- Modify: `Classifier/Bayes.pm` — add method after `get_words_for_bucket` (~line 3276)
- Create: `t/bayes-word-search.t`

- [ ] **Step 1: Write the failing test**

Create `t/bayes-word-search.t`:
```perl
#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/lib", "$Bin/..", "$Bin/../vendor/perl-querybuilder/lib";

use Test2::V0;
use TestHelper;

my ($config, $mq, $tmpdir) = TestHelper::setup();
my ($wm, $bayes) = TestHelper::setup_bayes($config, $mq);
my $session = $bayes->get_session_key('admin', '');

TestHelper::load_fixture($bayes, $session, {
    buckets => [qw(spam ham)],
    train => {
        spam => ['spam.eml'],
        ham => ['ham.eml'],
    },
});

subtest 'returns bucket list' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '');
    is ref $result->{buckets}, 'ARRAY', 'buckets is arrayref';
    my %bset = map { $_ => 1 } $result->{buckets}->@*;
    ok $bset{spam}, 'spam in bucket list';
    ok $bset{ham}, 'ham in bucket list';
};

subtest 'prefix filter works' => sub {
    my $result = $bayes->search_words_cross_bucket($session, 'zzz_no_match_xyz');
    is $result->{total}, 0, 'no results for unmatched prefix';
    is scalar $result->{words}->@*, 0, 'empty word list';
};

subtest 'result structure' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', per_page => 5);
    ok $result->{total} > 0, 'total > 0 after training';
    my $first = $result->{words}[0];
    ok defined $first->{word}, 'word key present';
    ok defined $first->{coverage}, 'coverage key present';
    ok defined $first->{is_stopword}, 'is_stopword key present';
    ok ref $first->{buckets} eq 'HASH', 'buckets hash present';
    ok exists $first->{buckets}{spam}, 'spam key in buckets hash';
    ok exists $first->{buckets}{ham}, 'ham key in buckets hash';
};

subtest 'sort by word asc' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', sort => 'word', dir => 'asc', per_page => 100);
    my @words = map { $_->{word} } $result->{words}->@*;
    my @sorted = sort @words;
    is \@words, \@sorted, 'words sorted alphabetically';
};

subtest 'sort by unknown bucket falls back to word sort' => sub {
    my $result = $bayes->search_words_cross_bucket($session, '', sort => 'no_such_bucket', dir => 'desc');
    ok ref $result->{words} eq 'ARRAY', 'returns array even with unknown sort';
};

subtest 'is_stopword flag' => sub {
    my @some_words = map { $_->{word} } $bayes->search_words_cross_bucket($session, '', per_page => 5)->{words}->@*;
    my $word = $some_words[0];
    $bayes->add_stopword($session, $word);
    my $result = $bayes->search_words_cross_bucket($session, $word);
    my ($row) = grep { $_->{word} eq $word } $result->{words}->@*;
    ok $row && $row->{is_stopword}, 'stopword flagged correctly';
    $bayes->remove_stopword($session, $word);
};

subtest 'pagination' => sub {
    my $p1 = $bayes->search_words_cross_bucket($session, '', page => 1, per_page => 3);
    my $p2 = $bayes->search_words_cross_bucket($session, '', page => 2, per_page => 3);
    ok $p1->{total} == $p2->{total}, 'total consistent across pages';
    my %p1_words = map { $_->{word} => 1 } $p1->{words}->@*;
    my @overlap = grep { $p1_words{$_->{word}} } $p2->{words}->@*;
    is scalar @overlap, 0, 'no word appears on both pages';
};

done_testing;
```

- [ ] **Step 2: Run to confirm it fails**

```bash
carton exec prove -l t/bayes-word-search.t 2>&1 | tail -10
```
Expected: FAIL — method does not exist.

- [ ] **Step 3: Add method to Classifier/Bayes.pm**

Add after the `get_words_for_bucket` method (after line ~3276), before `remove_word_from_bucket`:

```perl
=head2 search_words_cross_bucket

Search words across all non-pseudo buckets, returning per-bucket counts.

C<$session> A valid session key
C<$prefix> Word prefix to search (empty string matches all)
C<%opts> sort (word|coverage|total|<bucket-name>), dir (asc|desc), page, per_page

Returns hashref: { words => [...], total => N, buckets => [...] }.

=cut

method search_words_cross_bucket ($session, $prefix, %opts) {
    my $userid = $self->valid_session_key($session);
    return { words => [], total => 0, buckets => [] }
        unless defined $userid;
    my $page = ($opts{page} // 1) + 0;
    my $per_page = ($opts{per_page} // 50) + 0;
    $page = 1 if $page < 1;
    $per_page = 50 if $per_page < 1 || $per_page > 500;
    my $offset = ($page - 1) * $per_page;
    my $sort = $opts{sort} // 'word';
    my $dir = ($opts{dir} // '') eq 'desc' ? 'DESC' : 'ASC';
    my @bucket_names = map { $_->[0] }
        $self->validate_sql_prepare_and_execute(
            'SELECT name FROM buckets WHERE userid = ? AND pseudo = 0 ORDER BY name',
            $userid)->fetchall_arrayref->@*;
    return { words => [], total => 0, buckets => \@bucket_names }
        unless @bucket_names;
    my %stopwords = map { $_ => 1 } $self->get_stopword_list($session);
    my $qb = $self->qb();
    my $pattern = ($prefix // '') . '%';
    my @joins = (
        $qb->join('matrix m', on => $qb->compare('m.wordid', \'w.id')),
        $qb->join('buckets b', on => $qb->compare('b.id', \'m.bucketid')));
    my $where = $qb->combine_and(
        $qb->like('w.word', $pattern),
        $qb->compare('b.userid', $userid),
        $qb->is_false('b.pseudo'));
    my %sql_sort = (word => 'w.word', coverage => 'coverage', total => 'total');
    my $sort_in_sql = exists $sql_sort{$sort};
    my (@paged_words, $total);
    if ($sort_in_sql) {
        my $count_q = $qb->select('COUNT(DISTINCT w.id)')
            ->from('words w')
            ->joins(@joins)
            ->where($where);
        my $count_row = $self->validate_sql_prepare_and_execute(
            $count_q->as_sql(), $count_q->params())->fetchrow_arrayref;
        $total = $count_row ? $count_row->[0] + 0 : 0;
        my $paged_q = $qb->select('w.word', 'COUNT(DISTINCT m.bucketid) AS coverage', 'SUM(m.times) AS total')
            ->from('words w')
            ->joins(@joins)
            ->where($where)
            ->group_by('w.id', 'w.word')
            ->order_by($qb->order_by($sql_sort{$sort}, $dir))
            ->limit($per_page)
            ->offset($offset);
        @paged_words = map { $_->[0] }
            $self->validate_sql_prepare_and_execute(
                $paged_q->as_sql(), $paged_q->params())->fetchall_arrayref->@*;
    } else {
        my $all_q = $qb->select('w.word')
            ->from('words w')
            ->joins(@joins)
            ->where($where)
            ->group_by('w.id', 'w.word');
        my $all_rows = $self->validate_sql_prepare_and_execute(
            $all_q->as_sql(), $all_q->params())->fetchall_arrayref;
        $total = scalar $all_rows->@*;
        @paged_words = map { $_->[0] } $all_rows->@*;
    }
    return { words => [], total => $total, buckets => \@bucket_names }
        unless @paged_words;
    my $where2 = $qb->combine_and(
        $qb->compare('w.word', \@paged_words),
        $qb->compare('b.userid', $userid),
        $qb->is_false('b.pseudo'));
    my $q2 = $qb->select('w.word', 'b.name', 'm.times')
        ->from('words w')
        ->joins(@joins)
        ->where($where2);
    my %bucket_data;
    my $sth = $self->validate_sql_prepare_and_execute($q2->as_sql(), $q2->params());
    while (my $row = $sth->fetchrow_hashref()) {
        $bucket_data{$row->{word}}{$row->{name}} = $row->{times} + 0;
    }
    if (!$sort_in_sql) {
        @paged_words = map { $_->[0] }
            (sort {
                ($bucket_data{$b->[0]}{$sort} // 0) <=> ($bucket_data{$a->[0]}{$sort} // 0)
            } map { [$_] } @paged_words);
        @paged_words = reverse @paged_words
            if $dir eq 'ASC';
        @paged_words = grep { defined }
            @paged_words[$offset .. $offset + $per_page - 1];
    }
    my @result = map {
        my $word = $_;
        my %b = map { $_ => ($bucket_data{$word}{$_} // 0) } @bucket_names;
        my $cov = scalar grep { $b{$_} > 0 } @bucket_names;
        { word => $word,
          buckets => \%b,
          coverage => $cov,
          is_stopword => exists $stopwords{$word} ? \1 : \0 }
    } @paged_words;
    return { words => \@result, total => $total, buckets => \@bucket_names }
}
```

- [ ] **Step 4: Run tests**

```bash
carton exec prove -l t/bayes-word-search.t 2>&1
```
Expected: all subtests pass.

- [ ] **Step 5: Run full test suite**

```bash
carton exec prove -l t/ 2>&1 | tail -10
```
Expected: no regressions.

- [ ] **Step 6: Commit**

```bash
git add Classifier/Bayes.pm t/bayes-word-search.t
git commit -m "feat: add search_words_cross_bucket to Classifier::Bayes"
```

---

### Task 3: Services delegation + API controller + route + test

**Files:**
- Modify: `Services/Classifier.pm` — add delegation method after `get_stopword_candidates` (~line 355)
- Modify: `POPFile/API/Controller/Corpus.pm` — add `search_words` action
- Modify: `POPFile/API.pm` — add route
- Create: `t/mojo-word-search.t`

- [ ] **Step 1: Write the failing API test**

Create `t/mojo-word-search.t`:
```perl
#!/usr/bin/perl
BEGIN {
    @INC = grep { !/\/lib$/ && $_ ne 'lib' && !/thread-multi/ } @INC;
    require FindBin;
    require Cwd;
    my $root = Cwd::abs_path("$FindBin::Bin/..");
    require lib;
    lib->import("$root/local/lib/perl5");
    unshift @INC, "$FindBin::Bin/lib", $root;
}
use strict;
use warnings;

use Test2::V0;
use Test::Mojo;

my @buckets_list = ('ham', 'spam');
my %search_result = (
    words => [
        { word => 'font-size', buckets => { ham => 38, spam => 42 }, coverage => 2, is_stopword => \0 },
        { word => 'invoice', buckets => { ham => 1, spam => 80 }, coverage => 2, is_stopword => \0 },
    ],
    total => 2,
    buckets => \@buckets_list,
);

package MockSvc;
sub get_all_buckets { () }
sub is_bucket { 0 }
sub is_pseudo_bucket { 0 }
sub get_bucket_color { '#666666' }
sub get_bucket_word_count { 0 }
sub get_bucket_parameter { 0 }
sub get_bucket_word_list { () }
sub create_bucket { 1 }
sub delete_bucket { }
sub rename_bucket { }
sub clear_bucket { }
sub set_bucket_color { }
sub get_magnet_types { () }
sub get_buckets_with_magnets { () }
sub get_magnet_types_in_bucket { () }
sub get_magnets { () }
sub create_magnet { }
sub delete_magnet { }
sub remove_message_from_bucket { }
sub add_message_to_bucket { }
sub classify { 'ham' }
sub mangle_word { lc($_[1]) }
sub get_word_colors { () }
sub get_stopword_list { () }
sub add_stopword { 1 }
sub remove_stopword { }
sub get_stopword_candidates { () }
sub history_obj { undef }
sub bayes { undef }
sub get_words_for_bucket { { words => [], total => 0 } }
sub remove_word_from_bucket { }
sub move_word_between_buckets { }
sub search_words_cross_bucket {
    my ($self, $prefix, %opts) = @_;
    return \%search_result;
}

package StubMQ;
sub post { }
sub register { }

package main;

require POPFile::API;
require POPFile::Configuration;

my $mq = bless {}, 'StubMQ';
my $config = POPFile::Configuration->new();
$config->set_configuration($config);
$config->set_mq($mq);
$config->initialize();
$config->set_started(1);

my $mock_svc = bless {}, 'MockSvc';

my $ui = POPFile::API->new();
$ui->set_configuration($config);
$ui->set_mq($mq);
$ui->initialize();
$ui->set_service($mock_svc);

my $app = $ui->build_app($mock_svc, 'test-session');
$app->log->level('fatal');
my $t = Test::Mojo->new($app);

subtest 'GET /api/v1/words/search returns structure' => sub {
    $t->get_ok('/api/v1/words/search?q=font')
      ->status_is(200)
      ->json_has('/words')
      ->json_has('/total')
      ->json_has('/buckets');
    my $body = $t->tx->res->json;
    is $body->{total}, 2, 'total is 2';
    is scalar $body->{buckets}->@*, 2, 'two buckets';
    my $first = $body->{words}[0];
    ok exists $first->{word}, 'word key present';
    ok exists $first->{coverage}, 'coverage key present';
    ok exists $first->{is_stopword}, 'is_stopword key present';
    ok ref $first->{buckets} eq 'HASH', 'per-bucket hash present';
};

subtest 'GET /api/v1/words/search passes sort and dir params' => sub {
    $t->get_ok('/api/v1/words/search?q=&sort=coverage&dir=desc')
      ->status_is(200);
};

done_testing;
```

- [ ] **Step 2: Run to confirm it fails**

```bash
carton exec prove -l t/mojo-word-search.t 2>&1 | tail -10
```
Expected: FAIL — route not found (404).

- [ ] **Step 3: Add delegation to Services/Classifier.pm**

After the `get_stopword_candidates` line (~line 355), add:
```perl
method search_words_cross_bucket ($prefix, %opts) { $classifier->search_words_cross_bucket($session, $prefix, %opts) }
```

- [ ] **Step 4: Add controller action to POPFile/API/Controller/Corpus.pm**

After the `list_stopword_candidates` sub (~line 161), add:
```perl
sub search_words ($self) {
    my $svc = $self->popfile_svc;
    my $q = $self->param('q') // '';
    my $sort = $self->param('sort') // 'word';
    my $dir = $self->param('dir') // 'asc';
    my $page = ($self->param('page') // 1) + 0;
    my $per_page = ($self->param('per_page') // 50) + 0;
    my $result = $svc->search_words_cross_bucket(
        $q,
        sort => $sort,
        dir => $dir,
        page => $page,
        per_page => $per_page);
    $self->render(json => $result);
}
```

- [ ] **Step 5: Add route to POPFile/API.pm**

After the `get('/api/v1/stopword-candidates')` route (~line 243), add:
```perl
$r->get('/api/v1/words/search')->to('corpus#search_words');
```

- [ ] **Step 6: Run tests**

```bash
carton exec prove -l t/mojo-word-search.t 2>&1
```
Expected: all subtests pass.

- [ ] **Step 7: Run full test suite**

```bash
carton exec prove -l t/ 2>&1 | tail -10
```
Expected: no regressions.

- [ ] **Step 8: Commit**

```bash
git add Services/Classifier.pm POPFile/API/Controller/Corpus.pm POPFile/API.pm t/mojo-word-search.t
git commit -m "feat: add GET /api/v1/words/search endpoint"
```

---

### Task 4: Add i18n keys to English.msg

**Files:**
- Modify: `languages/English.msg`

- [ ] **Step 1: Replace old WordView and Stopwords keys, add new WordSearch keys**

Find the block starting at `NavWordView` (~line 379) and the `Corpus_Stopword*`/`WordView_*` block (~lines 441-467). Replace the entire block:

Remove these keys (they belong to components being deleted):
```
NavWordView
Corpus_StopwordCandidates
Corpus_StopwordCandidatesDesc
Corpus_StopwordRatio
Corpus_LoadCandidates
Corpus_AddStopword
Corpus_StopwordsTitle
Corpus_StopwordsDesc
Corpus_RemoveStopword
Corpus_NoCandidates
Corpus_NoStopwords
WordView_Title
WordView_SelectBucket
WordView_Words
WordView_Loading
WordView_Empty
WordView_ColWord
WordView_ColCount
WordView_ColTotal
WordView_ColAccuracy
WordView_TipCount
WordView_TipTotal
WordView_TipAccuracy
WordView_ColActions
WordView_Remove
WordView_MoveTo
WordView_Move
```

Replace `NavWordView` line with:
```
NavWordSearch                           Words & Stopwords
```

Add the new WordSearch block after the corpus nav section:
```
WordSearch_Title                        Word Search
WordSearch_Placeholder                  prefix...
WordSearch_Search                       Search
WordSearch_ColumnWord                   Word
WordSearch_ColumnBuckets                Buckets
WordSearch_Coverage                     coverage
WordSearch_AddStopword                  + Stopword
WordSearch_RemoveStopword               Stopword
WordSearch_IsStopword                   stopword
WordSearch_StopwordList                 Stopwords
WordSearch_NoResults                    No words found.
WordSearch_NoStopwords                  No stopwords defined.
WordSearch_Loading                      Loading...
WordSearch_Total                        words
```

- [ ] **Step 2: Run i18n sync test**

```bash
carton exec prove -l t/i18n-sync.t 2>&1
```
Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add languages/English.msg
git commit -m "feat: replace WordView/Stopwords i18n keys with WordSearch keys"
```

---

### Task 5: Create WordSearch.svelte

**Files:**
- Create: `ui/src/lib/WordSearch.svelte`

- [ ] **Step 1: Create the component**

Create `ui/src/lib/WordSearch.svelte`:
```svelte
<script>
    import { onMount } from 'svelte';
    import { t } from './locale.svelte.js';

    let query = $state('');
    let sort = $state('word');
    let dir = $state('asc');
    let page = $state(1);
    let perPage = $state(50);
    let words = $state([]);
    let buckets = $state([]);
    let total = $state(0);
    let loading = $state(false);
    let stopwords = $state([]);
    let stopwordsOpen = $state(false);

    const PAGE_SIZES = [25, 50, 100, 200];

    async function search() {
        loading = true;
        page = 1;
        await loadWords();
        loading = false;
    }

    async function loadWords() {
        loading = true;
        const params = new URLSearchParams({
            q: query,
            sort,
            dir,
            page: String(page),
            per_page: String(perPage),
        });
        const res = await fetch(`/api/v1/words/search?${params}`);
        if (res.ok) {
            const data = await res.json();
            words = data.words ?? [];
            buckets = data.buckets ?? [];
            total = data.total ?? 0;
        }
        loading = false;
    }

    function toggleSort(col) {
        if (sort === col) {
            dir = dir === 'asc' ? 'desc' : 'asc';
        } else {
            sort = col;
            dir = col === 'word' ? 'asc' : 'desc';
        }
        page = 1;
        loadWords();
    }

    function totalPages() {
        return Math.max(1, Math.ceil(total / perPage));
    }

    async function gotoPage(p) {
        page = p;
        await loadWords();
    }

    async function loadStopwords() {
        const res = await fetch('/api/v1/stopwords');
        if (res.ok) stopwords = await res.json();
    }

    async function addStopword(word) {
        const res = await fetch('/api/v1/stopwords', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ word }),
        });
        if (res.ok) {
            await loadStopwords();
            loadWords();
        }
    }

    async function removeStopword(word) {
        await fetch(`/api/v1/stopwords/${encodeURIComponent(word)}`, { method: 'DELETE' });
        await loadStopwords();
        loadWords();
    }

    function sortIndicator(col) {
        return sort === col ? (dir === 'asc' ? ' ▲' : ' ▼') : '';
    }

    onMount(() => {
        loadStopwords();
    });
</script>

<div class="page">
    <h2>{t('WordSearch_Title')}</h2>

    <div class="search-bar">
        <input
            type="text"
            placeholder={t('WordSearch_Placeholder')}
            bind:value={query}
            onkeydown={e => e.key === 'Enter' && search()}
        />
        <button onclick={search}>{t('WordSearch_Search')}</button>
        <label class="per-page-label">
            <select value={perPage} onchange={e => { perPage = parseInt(e.target.value); search(); }}>
                {#each PAGE_SIZES as n}
                    <option value={n}>{n}</option>
                {/each}
            </select>
        </label>
        {#if total > 0}
            <span class="total-label">{total} {t('WordSearch_Total')}</span>
        {/if}
    </div>

    {#if loading}
        <p class="desc">{t('WordSearch_Loading')}</p>
    {:else if words.length}
        <table>
            <thead>
                <tr>
                    <th class="sortable" class:active={sort === 'word'} onclick={() => toggleSort('word')}>
                        {t('WordSearch_ColumnWord')}{sortIndicator('word')}
                    </th>
                    {#each buckets as b}
                        <th class="sortable num" class:active={sort === b} onclick={() => toggleSort(b)}>
                            {b}{sortIndicator(b)}
                        </th>
                    {/each}
                    <th class="sortable num" class:active={sort === 'coverage'} onclick={() => toggleSort('coverage')}>
                        {t('WordSearch_ColumnBuckets')}{sortIndicator('coverage')}
                    </th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                {#each words as w (w.word)}
                    <tr class:stopword-row={w.is_stopword}>
                        <td class="word-col">
                            {w.word}
                            {#if w.is_stopword}
                                <span class="tag-stop">{t('WordSearch_IsStopword')}</span>
                            {/if}
                        </td>
                        {#each buckets as b}
                            <td class="num">{w.buckets[b] ?? 0}</td>
                        {/each}
                        <td class="num">{w.coverage}/{buckets.length}</td>
                        <td class="actions">
                            {#if w.is_stopword}
                                <button class="btn-small btn-danger" onclick={() => removeStopword(w.word)}>
                                    {t('WordSearch_RemoveStopword')} ✕
                                </button>
                            {:else}
                                <button class="btn-small" onclick={() => addStopword(w.word)}>
                                    {t('WordSearch_AddStopword')}
                                </button>
                            {/if}
                        </td>
                    </tr>
                {/each}
            </tbody>
        </table>

        {#if totalPages() > 1}
            <div class="pagination">
                <button disabled={page === 1} onclick={() => gotoPage(page - 1)}>{t('Previous')}</button>
                <span>{page} / {totalPages()}</span>
                <button disabled={page === totalPages()} onclick={() => gotoPage(page + 1)}>{t('Next')}</button>
            </div>
        {/if}
    {:else if query}
        <p class="desc">{t('WordSearch_NoResults')}</p>
    {/if}

    <section class="stopword-section">
        <h3>
            <button class="collapsible" onclick={() => stopwordsOpen = !stopwordsOpen}>
                {t('WordSearch_StopwordList')} {stopwordsOpen ? '▲' : '▼'}
            </button>
        </h3>
        {#if stopwordsOpen}
            {#if stopwords.length}
                <div class="tag-list">
                    {#each stopwords as sw}
                        <span class="tag">
                            {sw}
                            <button class="tag-remove" onclick={() => removeStopword(sw)}>✕</button>
                        </span>
                    {/each}
                </div>
            {:else}
                <p class="desc">{t('WordSearch_NoStopwords')}</p>
            {/if}
        {/if}
    </section>
</div>

<style>
    .page { padding: 1.75rem 2rem; max-width: 960px; }
    h2 { margin-bottom: 1rem; }
    .search-bar { display: flex; gap: 0.5rem; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; }
    .search-bar input { padding: 0.35rem 0.6rem; border: 1px solid var(--border); border-radius: 4px; background: var(--bg); color: var(--text); flex: 1; min-width: 10rem; }
    .per-page-label select { padding: 0.25rem; border: 1px solid var(--border); border-radius: 4px; background: var(--bg); color: var(--text); }
    .total-label { font-size: 0.85rem; color: var(--text-muted); }
    button { padding: 0.35rem 0.8rem; border: 1px solid var(--border); border-radius: 4px; cursor: pointer; background: var(--bg); color: var(--text); }
    button:disabled { opacity: 0.4; cursor: default; }
    .btn-small { padding: 0.1rem 0.4rem; font-size: 0.75rem; }
    .btn-danger { color: var(--danger); border-color: var(--danger); }
    table { width: 100%; border-collapse: collapse; font-size: 0.85rem; margin-bottom: 1rem; }
    th { text-align: left; padding: 0.4rem 0.5rem; border-bottom: 1px solid var(--border); color: var(--text-muted); font-weight: 500; }
    td { padding: 0.3rem 0.5rem; border-bottom: 1px solid var(--border, #eee); }
    .sortable { cursor: pointer; user-select: none; white-space: nowrap; }
    .sortable:hover { color: var(--accent); }
    .sortable.active { color: var(--accent); }
    .num { text-align: right; }
    .word-col { font-family: monospace; }
    .actions { text-align: right; white-space: nowrap; }
    .stopword-row td { color: var(--text-muted); }
    .tag-stop { font-size: 0.7rem; background: var(--accent, #666); color: #fff; border-radius: 3px; padding: 0.05rem 0.3rem; margin-left: 0.3rem; }
    .pagination { display: flex; gap: 0.75rem; align-items: center; justify-content: center; margin: 1rem 0; }
    .stopword-section { margin-top: 2rem; border-top: 1px solid var(--border); padding-top: 1rem; }
    h3 { margin: 0 0 0.5rem; }
    .collapsible { background: none; border: none; font-size: 1rem; font-weight: 600; color: var(--text); cursor: pointer; padding: 0; }
    .tag-list { display: flex; flex-wrap: wrap; gap: 0.4rem; margin-top: 0.5rem; }
    .tag { display: flex; align-items: center; gap: 0.25rem; background: var(--border, #ddd); border-radius: 3px; padding: 0.15rem 0.4rem; font-size: 0.8rem; }
    .tag-remove { background: none; border: none; cursor: pointer; padding: 0; font-size: 0.75rem; color: var(--text-muted); line-height: 1; }
    .tag-remove:hover { color: var(--danger); }
    .desc { font-size: 0.85rem; color: var(--text-muted, #888); }
</style>
```

- [ ] **Step 2: Commit**

```bash
git add ui/src/lib/WordSearch.svelte
git commit -m "feat: add WordSearch.svelte — cross-bucket word search with stopword management"
```

---

### Task 6: Update Corpus.svelte, remove old components

**Files:**
- Modify: `ui/src/lib/Corpus.svelte`
- Delete: `ui/src/lib/WordView.svelte`
- Delete: `ui/src/lib/Stopwords.svelte`

- [ ] **Step 1: Update Corpus.svelte**

Replace the import block at the top:
```js
import Stopwords from './Stopwords.svelte';
import WordView from './WordView.svelte';
```
with:
```js
import WordSearch from './WordSearch.svelte';
```

Remove the `searchWords` function and the `wordSearch`, `wordBucket`, `words` state variables.

Replace the routing block:
```svelte
{#if initialBucket === 'stopwords'}
    <Stopwords />
{:else if initialBucket}
    <WordView {buckets} {initialBucket} />
{:else}
```
with:
```svelte
{#if initialBucket === 'words'}
    <WordSearch />
{:else}
```

In the bucket table, change the `#corpus/{b.name}` words link to `#corpus/words`:
```svelte
<a class="btn-link" href="#corpus/words">{t('NavWordSearch')}</a>
```

Remove the entire "Bucket_Lookup" `<section>` block (the search section with wordBucket select and wordSearch input).

Remove the "Corpus_StopwordsTitle" `<section>` block (the stopwords link section).

Add a "Words & Stopwords" nav link entry in the bucket list header or toolbar area pointing to `#corpus/words`.

- [ ] **Step 2: Delete old components**

```bash
git rm ui/src/lib/WordView.svelte ui/src/lib/Stopwords.svelte
```

- [ ] **Step 3: Commit**

```bash
git add ui/src/lib/Corpus.svelte
git commit -m "feat: wire WordSearch into Corpus routing, remove WordView and Stopwords"
```

---

### Task 7: Build frontend and verify

**Files:**
- `public/assets/` — rebuilt by Vite

- [ ] **Step 1: Build**

```bash
cd ui && npm run build 2>&1 | tail -20
```
Expected: build succeeds, `public/assets/index-*.js` and `public/assets/index-*.css` updated.

- [ ] **Step 2: Run backend**

```bash
carton exec perl popfile.pl --debug=1 2>&1 | head -30
```
Expected: starts without errors.

- [ ] **Step 3: Run full test suite**

```bash
carton exec prove -l t/ 2>&1 | tail -10
```
Expected: all tests pass.

- [ ] **Step 4: Commit built assets**

```bash
git add public/assets/ public/index.html
git commit -m "build: rebuild frontend for cross-bucket word search"
```

- [ ] **Step 5: Sync to test directory**

```bash
rsync -av --exclude='local/' --exclude='*.db' --exclude='*.log' \
    /home/jan/Entwicklung/popfile/ ~/popfile/popfile/
```
