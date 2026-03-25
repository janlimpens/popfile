# POPFile

Bayesian email classifier written in Perl. Acts as a proxy between mail clients
and mail servers (POP3, SMTP, NNTP), inserting an `X-Text-Classification:` header
with the predicted category. Users correct misclassifications through the web UI,
which trains the classifier over time.

## Prerequisites

- [perlbrew](https://perlbrew.pl/) with perl ≥ 5.38
- [cpanm](https://metacpan.org/pod/App::cpanminus)

## Setup

```sh
# Install dependencies into local/
cpanm --installdeps --local-lib local .
```

## Run

```sh
perl -Ilocal/lib/perl5 popfile.pl
```

The web UI is available at <http://localhost:8080> by default.

`POPFILE_ROOT` overrides the root directory for config, database, and message
cache (default: `./`).

## CLI utilities

```sh
# Classify a message and show word scores
perl -Ilocal/lib/perl5 bayes.pl <message-file>

# Train a message into a bucket
perl -Ilocal/lib/perl5 insert.pl <bucket-name> <message-file>
```

## Svelte UI

The frontend lives in `ui/` and builds to `public/`.

```sh
cd ui && npm install

# Development (hot-reload, proxies /api to localhost:8080)
npm run dev

# Production build → public/
npm run build
```

## Tests

```sh
perl -Ilocal/lib/perl5 -I. t/mailparse.t
```

## Runtime files (gitignored)

| Path | Description |
|------|-------------|
| `popfile.cfg` | Generated configuration |
| `popfile.db` | SQLite database (corpus + history) |
| `messages/` | Cached message files |
| `*.pid`, `*.log` | Runtime state |
