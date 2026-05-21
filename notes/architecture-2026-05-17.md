# POPFile Architecture — Session Notes 2026-05-17

## The two-process trap

POPFile starts two processes: a launcher (`script/popfile`) and the actual
server. The launcher sets `POPFILE_USER` (default `~/.popfile`) and then
`exec`s the real server. If you start manually with `carton exec perl
script/popfile start` without env vars, `POPFILE_USER` is unset and defaults
to `./` — so the DB lands in CWD. Two parallel starts from different
directories produce two processes competing for the same IMAP account,
sharing the same config file.

## Configuration: dual paths

There are TWO config paths that matter:

| What                           | Controlled by                       | Default                         |
| ------------------------------ | ----------------------------------- | ------------------------------- |
| Config file (JSON)             | `POPFILE_PATH` or `XDG_CONFIG_HOME` | `~/.config/popfile/config.json` |
| User data (DB, messages, logs) | `POPFILE_USER`                      | `./`                            |

The `bin/popfile` wrapper sets `POPFILE_USER=~/.popfile` but
_does not set `POPFILE_PATH`_. The startup banner used to show the
`POPFILE_USER` path (misleading — it's not where the config is loaded from).

The config schema lives at `POPFile/config.schema.json`. It enforces
structure and provides defaults. A migration step in `POPFile::Config` can
rewrite old values at load time (e.g., integer logger levels → string names).

The legacy config format (`popfile.cfg` with `-->` separators) is still read
by `POPFile::ConfigFile` but the canonical format is now JSON at the XDG path.

For testing: **always set both `POPFILE_USER` and `POPFILE_PATH`** to temp
directories. Without `POPFILE_PATH`, the test instance writes to the
production config.

## Database: IMAP folder state vs. corpus vs. history

Three separate concerns in the SQLite DB:

- **`imap_folder_state`** — UIDNEXT/UIDVALIDITY per folder (where the IMAP
  scanner left off)
- **`imap_watched_folders`** — which folders to monitor for new mail
- **`imap_folder_mappings`** — bucket → output folder assignments
- **`history`** — classified messages (populated only by
  `classify_message()`, NOT by training)
- **`matrix`** + **`words`** — the Naive Bayes corpus

The migration from config strings to DB tables happened recently
(`_migrate_folder_config` in `Services::IMAP`). If the old config had no
`watched_folders` key, the migration creates empty tables. This is why
watched folders can silently disappear after a refactor.

## IMAP message flow — watched vs. output

The critical distinction:

- **Watched folder** → new messages are _classified_ (`classify_message()` →
  `classify_and_modify()` → `reserve_slot()` → `commit_slot()` →
  `commit_history()`). This creates history entries.
- **Output folder** → new messages are assumed to be _user reclassifications_
  and are _trained_ directly (`insert_message_into_bucket()`). This does NOT
  create history entries.

Without any watched folders, history stays empty forever. Messages in output
folders get auto-trained, which is wrong on a fresh setup (the messages were
there before POPFile was configured). Fixed by adding a `_training_mode()`
guard — output folder training now only happens when explicitly triggered
via the UI's "Train" button.

## Subprocess model

The IMAP poll runs in a `Mojo::IOLoop::Subprocess`. The subprocess inherits
the parent's module graph (MQ, history, classifier, DB handle). Progress
events stream back to the parent via `$subprocess->progress()`. The parent
writes results to config, clears training flags, and posts `IMAP_DONE` to
the MQ.

## Logging architecture

Layered: `POPFile::Role::Logging` (the `log_msg()` method) → `Log::Any` →
`POPFile::Log::Adapter` (custom adapter, writes to file + optional stdout).

The adapter maintains a ring buffer (10 lines) for the UI and masks
sensitive IMAP credentials. Log level is configured as `logger.level` in the
JSON config, now an enum string (`error`|`warn`|`info`|`debug`|`trace`).

The raw IMAP protocol dumps were at DEBUG level, filling the log with
hundreds of thousands of lines per hour. They now live at TRACE level.

## Module lifecycle

All components inherit from `POPFile::Module` and follow:
`initialize()` → `start()` → `service()` loop → `stop()`.

The `POPFile::Loader` discovers modules in `POPFile/`, `Classifier/`,
`Services/`, `Proxy/`, wires them together (config, MQ, classifier, history,
DB), and drives the lifecycle. Modules communicate via the MQ (message
queue): `COMIT` (history commit), `TICKD` (hourly cleanup), `IMAP_DONE`
(poll results).

## Pain points

- The `bin/popfile` wrapper and `POPFile::Config->resolve_path()` use
  different default paths for the config file.
- Two competing POPFile processes share the same config and IMAP account,
  corrupting UIDNEXT state.
- The `imap_watched_folders` table can be empty after migration if the old
  config format had no `watched_folders` key. This silently disables all
  classification.
- History entries are only created by `classify_and_modify()`, never by
  training paths. A fresh setup with only output folders will never build
  history.

## Session 2026-05-20 — Proxy extraction, URL parsing, IMAP cleanup

### Proxy module pattern

All three proxy modules (NNTP, POP3, SMTP) now follow the same architecture:
`child()` is a dispatcher (~30 lines) that delegates to focused command
handlers via a `_dispatch()` chain. Each handler returns `($mail, $action)`
tuples where `$action` is `'next'` or `'last'`.

| Proxy | child() before | child() after | handlers |
| ----- | -------------- | ------------- | -------- |
| NNTP  | ~230 lines     | 33 lines      | 13       |
| POP3  | ~200 lines     | 37 lines      | 18       |
| SMTP  | ~115 lines     | 27 lines      | 6        |

All handler methods are ≤43 lines. No blank lines within methods.

### URL parsing (MailParse.pm)

Replaced `add_url`'s 6 destructive `s///` chain and 66-line TLD/ccTLD regex
lists with the official RFC 3986 URI regex (same as `URI::Split`):

    my $URI_RE = qr|(?:([^:/?\#]+):)?(?://([^/?\#]*))?([^?\#]*)(?:\?([^\#]*))?(?:\#(.*))?|;

Bare hostnames (from gTLD/ccTLD matchers) are handled by prepending `//`.
Three anti-spam countermeasures preserved on the authority component:
percent-encoding detection, authinfo detection, hex/octal/decimal IP
normalization (extracted to `_normalize_ip`).

Benchmark: RFC regex 3947/s vs manual 2727/s (+45%), Mojo::URL 201/s (−93%).
Mojo::URL and URI are ~15× slower — not worth it for the structual parse,
but Mojo::URL wins over URI because it's already a dependency.

Replaced 106-line hardcoded `%entityhash` (100 ISO-Latin1 entities) with
`HTML::Entities::entity2char` (253 entities, full set). `HTML::Entities`
is already pulled in by `HTML::Tagset`. Kept `%color_map` (147 CSS named
colors) — no Mojolicious/CPAN module provides this, and the list hasn't
changed since CSS1.

### Config schema cleanup

Removed from `config.schema.json`:

- `api.page_size`, `api.word_page_size` → moved to browser localStorage
- `api.session_dividers`, `api.wordtable_format` → dead code (no component read them)
- Fixed `bayes.unclassified_weight`: `integer` → `number` (test passes 0.000001)

Removed from Settings UI: `api_page_size`, `session_dividers`, `wordtable_format`.

### Frontend: paging_size in localStorage

History and WordSearch now share a single `localStorage` key `paging_size`
(options: 25, 50, 100, 500). No more PUT to `/api/v1/config` on page size
change, no server config fallback. `WordSearch` defaults changed 50→25.

### Frontend: local fonts

Replaced Google Fonts CDN links in `index.html` with the already-bundled
`@fontsource-variable/material-symbols-outlined` (741KB `.woff2` served
from app assets). The CDN preconnect/stylesheet links were redundant.

### IMAP.pm cleanup

Removed 9 thin config wrapper methods (`_host`, `_port`, `_login`, …):

    method _host() { $self->config->get('hostname') }  # → inlined

Added `:reader` to `$training_mode` and `$training_error` fields, removed
`_training_mode()` and `_training_error()` wrapper methods. Fixed
`$self->training_mode == 1` → `$self->training_mode` (Perl boolean idiom).

Removed `_now()` wrapper (just `time()`). Kept `_poll_age()` — it's a
legitimate test seam used by `t/imap-watchdog.t`.

### Test fixes

`t/imap-dovecot-integration.t` and `t/pop3-proxy.t` were broken by the
config refactor (`$config->parameter()` removed, `$bayes->config($k,$v)`
signature changed). Fixed with `TestHelper::set_config()`. IMAP training
test now creates filesystem flag files (`popfile.train.*`) to trigger
training mode (it's a lifetime flag, not a config value). Dovecot container
started via `docker compose -f docker-compose.test.yml up -d imap`.

### Dead code removal

- `POPFile::MQ` POD: removed `UIREG` message type (never posted or handled)
- `POPFile::Config`: removed `page_size`, `word_page_size` from schema
- Settings UI: removed `api_page_size`, `session_dividers`, `wordtable_format`
