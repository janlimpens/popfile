# POPFile Changelog

## main (unreleased) — post-v1.1.3 rewrite

This branch represents a substantial modernisation of POPFile beyond the last
released version (v1.1.3, 2012).

### Architecture

- Replaced the legacy fork-per-request HTTP UI with an in-process
  [Mojolicious](https://mojolicious.org) HTTP server running on `Mojo::IOLoop`.
- Replaced all Perl-templated HTML pages with a Svelte 5 single-page
  application served from `public/`.
- REST API exposed under `/api/v1/*`; backend and frontend are fully decoupled.
- Switched from ad-hoc `print` logging to `Log::Any` with a custom adapter
  (`POPFile::Log::Adapter`) that supports file output, stdout, ring buffer, and
  level filtering — all live-reconfigurable from the UI.
- Adopted `Object::Pad` class syntax and `use feature 'signatures'` throughout.
- Dependency management moved to Carton (`cpanfile` + `local/`).
- CI via GitHub Actions.

### Classification

- `Classifier::Bayes` now computes a **per-bucket** `not_likely` floor
  (previously global), eliminating classification bias when one bucket
  dominates the corpus.
- `Classifier::WordMangle` filters noise tokens before they reach the corpus:
  - HTML/CSS pseudo-tokens that carry embedded values
    (`html:css*`, `html:comment`, `html:fontcolor*`, `html:backcolor*`,
    `html:fontsize*`, `html:imgwidth*`, `html:imgheight*`).
  - Zero-width character entity artifacts (`zwnj`, `zwj`).
  - Random opaque strings detected via impossible consonant bigrams
    (`jk` anywhere; `hg`, `bk`, `dk` at word start) — tracks tracking IDs
    and hashed CSS class names out of the corpus.
- Database indices added for `matrix(bucketid)`, `history(userid, committed)`,
  `history(bucketid)`, `history(hash)`, `history(inserted)`,
  `magnets(bucketid)`.

### IMAP

- New `Services::IMAP` module: recurring poll timer, per-folder UID tracking,
  automatic classification and folder moves, reclassification detection by
  observing message moves into mapped output folders.
- UID-next state persisted in `imap_folder_state` table; override bug that
  caused repeated reclassification of old messages fixed.
- Message-ID-backed direct moves for reclassification from the web UI.
- Training triggers via filesystem flag files (`popfile.train*`).
- `poll_sync()` method for synchronous integration tests.

### Web UI

- History view: pagination with configurable page size (persisted to config and
  `sessionStorage`), search, bucket filter, bulk reclassify.
- Corpus / Word view: sortable columns, per-bucket word inspector, stopword
  management, word move and delete.
- Settings page exposes all runtime configuration including logging options.
- IMAP configuration page: watched folders, bucket-folder mappings, live folder
  discovery, connection test.
- Self-hosted Material Symbols icons; no external font CDN dependency.

### Recent additions (April 2026)

**Word Search**
- New `GET /api/v1/words/search` endpoint with cross-bucket coverage,
  sortable columns, and stopword management.
- `WordSearch.svelte` replaces the old `WordView` and `Stopwords` views.
- `search_words_cross_bucket` in `Classifier::Bayes` with coverage and
  bucket-sort support.

**Security Hardening**
- API authentication via `X-POPFile-Token` header (#259, #261).
- GET/HEAD exempt when `api_local=1` (localhost); all requests require
  token when `api_local=0`.
- CSRF protection: all mutating API requests (POST/PUT/DELETE) require
  the auth token when a password is set.
- Rate limiting: 60 requests per second per IP for API endpoints (#263).
- Security headers: `X-Content-Type-Options`, `X-Frame-Options`,
  `Referrer-Policy`, `Permissions-Policy` (#260).
- Request body size limit: 10 MB via `max_request_size` (#265).
- Atomic port file writes via tempfile+rename to prevent TOCTOU (#262).
- Symlink resolution in static file serving (#266).
- Config error messages no longer leak full filesystem paths (#268).
- Browser auto-open URL validated before launching (#267).
- Sensitive config values encrypted at rest (`imap_password`) via AES-256-CBC.
- IMAP credentials removed from config-update diagnostic logging.

**Test Infrastructure**
- Centralised test helper (`TestHelper.pm`): `setup()`, `setup_bayes()`,
  `setup_mojo_services()`, `configure_db()`, `load_fixture()`, `reset_db()`.
- All mojo controller tests converted to use real file-based SQLite databases
  (eliminated `:memory:` and inline mocks).
- `TestMocks.pm` slimmed from 254 to 173 lines; unused mock methods and log
  fields removed.
- Dovecot Docker container started/stopped automatically via `make test`;
  `docker compose -f docker-compose.test.yml` integrated into CI.
- End-to-end POP3 classification test; IMAP training and watched-folder
  classification integration tests.

**UI Polish**
- IMAP moved into Settings as a sub-tab alongside POP3/SMTP/NNTP.
- Service status indicators (green/grey dot) in settings navigation.
- IMAP enable toggle positioned first, training mode/limit in collapsible
  "Advanced" section at the bottom.
- SSL toggle now precedes port field; port auto-switches 143↔993 on SSL change.
- Section labels simplified ("POP3 Proxy" → "POP3", etc.).
- `api_local` moved from UI section to Security; preventing uncheck when no
  password is set.

**Bug Fixes**
- SQL injection in `delete_slot()` replaced with `Query::Builder`.
- SQLite 999-variable limit avoided in `get_word_colors`, `classify`,
  `add_words_to_bucket`, and `search_words_fetch` via chunked IN clauses.
- `GROUP BY` emitted before `ORDER BY` in query builder.
- IMAP `uid_next` reset restored in `request_folder_move` fallback path.
- Various Perl warnings silenced (`used only once`, uninitialised values).
- Database schema upgrade no longer triggered spuriously on fresh test
  databases (file-based SQLite in temp dir).
- Uninitialised `$file` warning in `add_message_to_bucket` fixed.
- `t/services-classifier.t` SEGV resolved.

---

## v1.1.3 (2012)

Last release by the original POPFile Core Team. See `v1.1.3.change.txt` for
the original release notes.
