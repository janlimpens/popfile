# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is POPFile

POPFile is a Bayesian email classifier written in Perl. It acts as a proxy between mail clients and mail servers (POP3, SMTP, NNTP), intercepting messages and inserting an `X-Text-Classification:` header with the predicted category ("bucket"). Users correct misclassifications through the web UI, which trains the classifier over time.

## Commands

### Install dependencies

```sh
perl Makefile.PL
make
# or install CPAN deps directly:
cpan DBI DBD::SQLite HTTP::Daemon HTTP::Status LWP::UserAgent Digest::MD5 \
     MIME::Base64 MIME::QuotedPrint Date::Parse HTML::Template HTML::Tagset \
     Sort::Key::Natural
```

### Run POPFile

```sh
perl popfile.pl
```

The `POPFILE_ROOT` environment variable overrides the root directory (default: `./`).

### CLI utilities

```sh
# Classify a message file and show word scores
perl bayes.pl <message-file>

# Train a message into a specific bucket
perl insert.pl <bucket-name> <message-file>
```

### Runtime files (gitignored)

- `popfile.cfg` — generated configuration
- `popfile.db` — SQLite database (corpus + history)
- `messages/` — cached message files
- `*.pid`, `*.log` — runtime state

## Architecture

### Module system

All POPFile components inherit from `POPFile::Module` and follow a strict lifecycle:

1. `initialize()` — set defaults, register config parameters
2. `start()` — open connections, start workers
3. `service()` — called in a loop by the main process; do per-tick work
4. `stop()` — clean up

`POPFile::Loader` discovers, loads, links, and drives all modules through this lifecycle. The main entry point (`popfile.pl`) delegates entirely to `POPFile::Loader`.

### Module groups

| Namespace | Role |
|-----------|------|
| `POPFile::` | Core infrastructure: `Loader`, `Module` (base), `Configuration`, `History`, `MQ` (message queue), `Mutex`, `Logger`, `API` |
| `Classifier::` | `Bayes` (Naive Bayes engine), `MailParse` (MIME/email parsing), `WordMangle` (word normalization) |
| `Proxy::` | `Proxy` (base), `POP3`, `SMTP`, `NNTP` — sit between mail client and server |
| `UI::` | `HTTP` (web server), `HTML` (page rendering), `XMLRPC` (XML-RPC interface) |
| `Platform::` | `MSWin32` — Windows-specific adaptations |

### `POPFile::API`

Thin wrapper around `Classifier::Bayes` that exposes the classifier through XML-RPC. Uses a session-key pattern: callers obtain a session with `get_session_key('admin', '')` and release it with `release_session_key($session)` when done.

### Database

SQLite 3.x (via `DBD::SQLite >= 1.00`) is the default backend; MySQL and PostgreSQL are also supported. The schema is in `Classifier/popfile.sql`. Key tables: `users`, `buckets`, `words`, `matrix` (word×bucket corpus), `history`, `magnets`, `magnet_types`.

### Bundled libraries

`lib/` contains vendored copies of third-party Perl modules. Prefer these over system-installed versions when running POPFile directly from the source tree.

### Internationalization

UI strings live in `languages/*.msg` files, one per locale.
