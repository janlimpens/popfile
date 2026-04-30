# POPFile Changelog

## main (unreleased) — post-v1.1.3 rewrite

This branch is a ground-up modernisation of POPFile beyond the last released
version (v1.1.3, 2012).  Most of the code was written by LLM coding agents
as a real-world testbed for AI-assisted development.

### Architecture

- Mojolicious REST backend replacing the fork-per-request HTTP UI.
- Svelte 5 single-page application replacing Perl-templated HTML.
- `Object::Pad` class syntax and `use feature 'signatures'` throughout.
- `Log::Any` with a custom live-reconfigurable adapter replacing ad-hoc `print`.
- Carton dependency management (`cpanfile` + `local/`).
- CI via GitHub Actions.

### IMAP

IMAP is the primary interface for this release.  A new `Services::IMAP` module
polls watched folders, tracks UIDs per folder, classifies new messages, and
moves them to mapped output folders.  Reclassification from the web UI triggers
direct IMAP moves via Message-ID lookups.  Training mode scans existing sorted
folders and feeds the classifier.

IMAP folder state (UIDNEXT, UIDVALIDITY) is persisted in a new
`imap_folder_state` table so it survives restarts and config resets.

### Classification

`Classifier::Bayes` now uses a per-bucket `not_likely` floor, eliminating bias
when one bucket dominates the corpus.  `Classifier::WordMangle` filters HTML/CSS
pseudo-tokens, zero-width entity artifacts, and random opaque strings before
they reach the corpus.  Database indices added on `matrix(bucketid)`,
`history(userid, committed)`, `history(bucketid)`, `history(hash)`,
`history(inserted)`, and `magnets(bucketid)`.

### Cross-bucket word search

A new `GET /api/v1/words/search` endpoint returns words with per-bucket coverage
percentages, sortable across columns, with inline stopword management.
`WordSearch.svelte` provides the UI, replacing the old `WordView` and
`Stopwords` views.

### API & Security

- Token-based authentication (`X-POPFile-Token`) for all API endpoints.
  When `api_local=1` (localhost), GET and HEAD requests are exempt; when
  `api_local=0`, every request requires the token.
- CSRF protection: all state-changing requests (POST, PUT, DELETE) require
  the auth token when a password is set.
- Rate limiting: 60 requests/second/IP on API endpoints.
- Security headers: `X-Content-Type-Options`, `X-Frame-Options`,
  `Referrer-Policy`, `Permissions-Policy`.
- Request body size limited to 10 MB.
- Sensitive config values (`imap_password`) encrypted at rest with AES-256-CBC.
- SQL injection in `delete_slot()` replaced with parameterised queries via
  `Query::Builder`.
- SQLite 999-variable limit handled through chunked IN clauses in
  classification and word-search code paths.

### Test infrastructure

All mojo controller tests run against real file-based SQLite databases instead
of `:memory:` or inline mocks.  `TestHelper.pm` provides centralised setup
routines (`setup_bayes`, `setup_mojo_services`, `load_fixture`, `reset_db`).
`TestMocks.pm` is stripped to the minimum required by the three mock-based
controller tests.

A Dockerised Dovecot instance provides IMAP and POP3 for integration tests.
`make test` starts the container, runs the full suite, and tears it down.
The same Dovecot compose file is wired into CI.

End-to-end tests cover the IMAP training and watched-folder classification
pipeline, plus POP3 retrieval and classification.

### Web UI

- History: pagination, search, bucket filter, bulk reclassify.
- Corpus: per-bucket word inspector with sortable columns, word move/delete.
- Word search: cross-bucket coverage view with stopword management.
- Settings: all runtime configuration including logging, with service status
  indicators in the navigation sidebar.
- IMAP: connection setup, watched folders, bucket→folder mappings, live
  folder discovery, connection test.
- Material Symbols icons in navigation, self-hosted, no external CDN.

### Bug fixes

| Area | Fix |
|------|-----|
| IMAP | uid_next reset restored in fallback move path; orphan poll guard removed |
| Query::Builder | `GROUP BY` emitted before `ORDER BY` |
| Database | Schema upgrade no longer spuriously triggered on fresh test databases |
| Logging | IMAP credentials stripped from config-update diagnostic output |
| Port file | Atomic write via tempfile+rename prevents TOCTOU |
| Static files | Symlinks resolved before serving |

---

## v1.1.3 (2012)

Last release by the original POPFile Core Team. See `v1.1.3.change.txt` for
the original release notes.
