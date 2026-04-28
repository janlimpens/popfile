# Cross-Bucket Word Search — Design Spec

Date: 2026-04-28

## Overview

Replace the per-bucket `WordView` and the separate `Stopwords` page with a single cross-bucket word search view. The new view shows word counts per bucket side by side, is sortable by any column, and integrates stopword management directly.

## What Changes

- `ui/src/lib/WordView.svelte` → replaced by `WordSearch.svelte`
- `ui/src/lib/Stopwords.svelte` → removed
- `Corpus.svelte` → bucket word links updated, stopwords section removed
- `POPFile/API/Controller/Corpus.pm` → new action `search_words`
- `Classifier/Bayes.pm` → new method `search_words_cross_bucket`
- `Services/Classifier.pm` → new delegation method
- `POPFile/API.pm` → new route registered
- `languages/English.msg` → new i18n keys

## Backend

### Route

```
GET /api/v1/words/search?q=&sort=word&dir=asc&page=1&per_page=50
```

Parameters:
- `q` — word prefix (empty = all words, up to per_page limit)
- `sort` — `word` | `coverage` | `total` | `<bucket-name>`
- `dir` — `asc` | `desc`
- `page` — 1-based
- `per_page` — default 50

### Response shape

```json
{
    "buckets": ["ham", "newsletter", "spam"],
    "total": 142,
    "words": [
        {
            "word": "font-size",
            "buckets": { "ham": 38, "newsletter": 45, "spam": 42 },
            "coverage": 3,
            "is_stopword": false
        }
    ]
}
```

`coverage` is the number of buckets in which the word appears (not the total bucket count).

### Implementation — two-query approach

Query::Builder is used for full query construction (SELECT, FROM, JOIN, GROUP BY, ORDER BY, LIMIT, OFFSET, WHERE).

**Query 1**: fetch matching words with aggregate stats for SQL-level sort on `word`, `coverage`, `total`. Returns paged word list.

```sql
SELECT w.word, COUNT(DISTINCT m.bucketid) AS coverage, SUM(m.times) AS total
FROM words w
JOIN matrix m ON m.wordid = w.id
JOIN buckets b ON b.id = m.bucketid
WHERE b.userid = ? AND b.pseudo = 0 AND w.word LIKE ?
GROUP BY w.id, w.word
ORDER BY <dynamic> <dir>
LIMIT ? OFFSET ?
```

**Query 2**: per-bucket counts for the paged word set.

```sql
SELECT w.word, b.name, m.times
FROM words w
JOIN matrix m ON m.wordid = w.id
JOIN buckets b ON b.id = m.bucketid
WHERE b.userid = ? AND b.pseudo = 0 AND w.word IN (...)
```

Controller pivots Query 2 rows into the `buckets` hash per word.

**Sort by bucket name**: when `sort` matches a bucket name, Query 1 is run without ORDER BY (fetches all matching words), merged with Query 2, sorted and paginated in Perl. Acceptable because prefix-filtered result sets are small.

**`is_stopword`**: checked against existing `get_stopword_list`.

### New Bayes method

```perl
method search_words_cross_bucket ($session, $prefix, %opts)
```

Returns `{ words => [...], total => N, buckets => [...] }`.

### Existing endpoints kept

- `GET /api/v1/stopwords` — list
- `POST /api/v1/stopwords` — add
- `DELETE /api/v1/stopwords/:word` — remove

## Frontend

### New component: `WordSearch.svelte`

Replaces `WordView.svelte`. Accessed via `#corpus/words`.

**Layout:**

1. **Search bar** — text input (prefix) + Search button. Triggered on button click or Enter.
2. **Results table** — columns: Word | one column per bucket (count) | Buckets (coverage N/total). All column headers clickable to toggle sort asc/desc. Active sort column highlighted.
3. **Per-row actions** — "Add stopword" if not a stopword; "Stopword ✓ Remove" if already a stopword.
4. **Pagination** — prev/next with page size selector.
5. **Stopword list section** — below the table, collapsible. Existing stopwords as tags with remove button.

### Corpus.svelte changes

- Remove "Bucket_Lookup" search section.
- Remove "Stopwords" link section.
- Change bucket word links from `#corpus/{name}` to `#corpus/words`.
- Add "Words & Stopwords" nav entry pointing to `#corpus/words`.

### Routing

`initialBucket === 'words'` triggers `WordSearch` instead of `WordView`/`Stopwords`.

## i18n keys (English.msg)

```
WordSearch_Title = Word Search
WordSearch_Placeholder = prefix...
WordSearch_Search = Search
WordSearch_ColumnWord = Word
WordSearch_ColumnBuckets = Buckets
WordSearch_AddStopword = + Stopword
WordSearch_RemoveStopword = Stopword
WordSearch_StopwordList = Stopwords
WordSearch_NoResults = No words found.
WordSearch_NoStopwords = No stopwords defined.
```

## Tests

- Unit test for `search_words_cross_bucket`: prefix filter, sort by word, sort by coverage, sort by bucket name, is_stopword flag.
- Empty prefix returns up to `per_page` results.
- Sort by unknown bucket name falls back to word sort.

## Out of scope

- Removing existing corpus entries when adding a stopword.
- Live/as-you-type search.
