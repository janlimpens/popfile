# POPFile

POPFile classifies email automatically. It watches your IMAP inbox, runs incoming
messages through a Naive Bayes classifier, and moves them to the right folder —
spam to Spam, newsletters to Subscriptions, work mail to Work. You correct
misclassifications in the web UI and it learns from every correction.

It also speaks POP3, SMTP, and NNTP for setups that need a proxy, but IMAP is
where most of the action is.

## What it does

- **IMAP polling** — watches folders at a configurable interval, classifies
  new messages, moves them to mapped folders.
- **Training from folders** — point it at existing sorted mail and it trains
  the classifier from what's already there.
- **Web UI** — history view with search/filter, corpus word browser, magnet
  rules, per-bucket statistics, and full configuration.
- **Self-correcting** — every reclassification feeds back into the corpus.
- **Magnets** — hard rules based on headers (from, to, subject, cc) for
  messages you always want in a specific bucket.
- **REST API** — everything the UI does is available programmatically under
  `/api/v1/`.

## Quick start

```sh
docker compose up
```

Opens the web UI on `http://localhost:8080`. Configure your IMAP server under
Settings → IMAP, add watched folders and bucket mappings, and you're running.

### From source (perlbrew + Carton)

```sh
carton install
carton exec perl popfile.pl
```

Set `POPFILE_ROOT` to point at a different directory for config, database, and
message cache (default: `./`).

## CLI

```sh
carton exec perl bayes.pl <message-file>      # classify and show word scores
carton exec perl insert.pl <bucket> <file>    # train a message into a bucket
```

## About this revival

POPFile originally ran from 2001–2012. This 2026 reboot is a ground-up
modernisation — Mojolicious REST backend, Svelte 5 frontend, Object::Pad
throughout, IMAP replacing POP3 as the primary interface.

Most of the code was written by LLM coding agents (Claude Code, DeepSeek, pi,
and others) as a real-world testbed for AI-assisted development across a
non-trivial, multi-module Perl codebase. The commit history is the lab
notebook. All contributions, human and synthetic, are welcome.

## Development

```sh
make test          # full suite with Dovecot
make test-no-dovecot  # skip IMAP/POP3 integration tests
make build            # rebuild Svelte frontend → public/
```

The frontend lives in `ui/` (Svelte 5, built with Vite). See `development.md`
for the Dovecot test server setup and `ARCHITECTURE.md` for module layout.
