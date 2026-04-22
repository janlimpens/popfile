# POPFile

Bayesian email classifier written in Perl. POPFile connects to your IMAP
folders, classifies incoming messages with Naive Bayes, and inserts an
`X-Text-Classification:` header with the predicted category ("bucket").
You correct misclassifications through the web UI, which retrains the
classifier over time.

POP3, SMTP, and NNTP proxies are also included for legacy setups, but IMAP
is the primary interface.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) + [Compose](https://docs.docker.com/compose/)

## Run

```sh
docker compose up
```

### Local (with perlbrew + Carton)

```sh
carton install
carton exec perl popfile.pl
```

The web UI is available at `http://localhost:<port>/` — the port is printed to
the console on startup (default 8080, configurable via `api_port`).

`POPFILE_ROOT` overrides the root directory for config, database, and message
cache (default: `./`).

## CLI utilities

```sh
# Classify a message and show word scores
carton exec perl bayes.pl <message-file>

# Train a message into a bucket
carton exec perl insert.pl <bucket-name> <message-file>
```

## Svelte UI

The frontend lives in `ui/` and builds to `public/`.

```sh
cd ui && npm install

# Development (hot-reload, proxies /api to the POPFile port — default 8080)
npm run dev

# Production build → public/
npm run build
```

## Tests

```sh
carton exec prove -l t/
```

## Runtime files (gitignored)

| Path | Description |
|------|-------------|
| `popfile.cfg` | Generated configuration |
| `popfile.db` | SQLite database (corpus + history) |
| `messages/` | Cached message files |
| `*.pid`, `*.log` | Runtime state |
