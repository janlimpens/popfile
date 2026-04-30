# POPFile

POPFile is a personal email sorting tool. It watches your IMAP inbox, learns
what belongs where from the corrections you make, and moves messages to the
right folders automatically.

Under the hood it uses Naive Bayes — a simple statistical method that counts
which words appear in which folders and uses the tallies to guess where new
messages belong. The more you correct it, the better it gets.

**This is not an LLM or cloud service.** POPFile runs entirely on your
machine. No email ever leaves your computer. No data is sent anywhere. Every
word it reads stays local. The classifier is a few hundred lines of Perl —
there is no giant model, no API keys, no telemetry.

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
- **30 languages** — Arabic, Bulgarian, Catalan, Chinese (simplified &
  traditional), Czech, Danish, Dutch, English (UK & US), Finnish, French,
  German, Greek, Hebrew, Hungarian, Italian, Japanese, Korean, Norwegian,
  Polish, Portuguese (BR & PT), Russian, Slovak, Spanish, Swedish, Turkish,
  Ukrainian.

## Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/janlimpens/popfile/main/install.sh | sh
```

Opens `http://localhost:7070` when ready. The script detects whether you have
Docker and uses it if available; otherwise falls back to Perl + Carton. The
setup wizard guides you through IMAP or POP3 configuration on first launch.

To stop: `docker stop popfile` (Docker) or `kill $(cat ~/.popfile/popfile.pid)`
(source install). Your data lives in a Docker volume or `~/.popfile/` and
survives restarts and updates.

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

The UI is available in 30 languages (Arabic through Ukrainian). Translations
live in `languages/*.msg` as simple key–value files. Missing keys fall back to
English automatically.
