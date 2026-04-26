# POPFile Architecture

This document describes the architecture of POPFile as it exists on `main` at commit `b5dead7` (`fixes missing import`). The current `agent1` worktree is older than `main`, so this document is intentionally based on `main`, not the checked-out branch state.

## What POPFile Is

POPFile is a Perl application that classifies email with a Naive Bayes engine.

It has two primary operating modes:

- IMAP mode: the main modern path. POPFile connects to an IMAP server, polls watched folders, classifies new mail, and moves messages into bucket-mapped folders.
- Proxy mode: legacy POP3/SMTP/NNTP proxies that sit between a mail client and an upstream server and inject classification results into messages as they pass through.

It also exposes a web application:

- Backend: an in-process Mojolicious HTTP API.
- Frontend: a Svelte single-page app built with Vite and served from `public/`.

## High-Level Structure

At runtime, the system looks like this:

```text
bin/popfile
  -> bootstraps dependencies and UI build
  -> execs script/popfile

script/popfile
  -> parses verbs/options
  -> creates POPFile::Loader
  -> loads modules
  -> links modules together
  -> starts Mojo::IOLoop

Mojo::IOLoop hosts:
  - POPFile::API               HTTP server + SPA static files
  - Services::IMAP             recurring poll timer
  - Proxy::* servers           legacy POP3/SMTP/NNTP listeners
  - POPFile::MQ                async in-process event delivery
  - POPFile::Logger            hourly ticks / logging
  - POPFile::Configuration     periodic pid/config maintenance

Core domain services:
  - Classifier::Bayes          classification and training engine
  - POPFile::History           message history and cached message files
  - Services::Classifier       long-lived facade over Bayes

Persistence:
  - SQLite by default (`popfile.db`)
  - config file (`popfile.cfg`)
  - cached message bodies (`messages/`)
  - runtime state (`*.pid`, `popfile.port`, logs, IMAP training flags)
```

## Startup and Lifecycle

The entrypoint for normal use is [`bin/popfile`](bin/popfile), which:

- ensures Perl dependencies are installed via Carton
- ensures UI dependencies are installed in `ui/`
- rebuilds the frontend into `public/` when `ui/src` is newer
- execs [`script/popfile`](script/popfile) with `POPFILE_ROOT` set

[`script/popfile`](script/popfile) is the real application bootstrap. It:

- parses CLI verbs such as `start`, `stop`, `status`, `train`, `insert`, `classify`, and `pipe`
- creates `POPFile::Loader`
- runs the standard lifecycle:
  1. `CORE_loader_init`
  2. `CORE_signals`
  3. `CORE_load`
  4. `CORE_link_components`
  5. `CORE_initialize`
  6. `CORE_config`
  7. `CORE_start`
  8. `CORE_register_timers`
  9. `Mojo::IOLoop->start`
  10. `CORE_stop`

Every loadable component derives from [`POPFile::Module`](POPFile/Module.pm), which provides:

- the common lifecycle methods: `initialize`, `start`, `service`, `stop`
- access to configuration and the message queue
- shared socket/filehandle helpers such as `slurp`, `flush_extra`, and `can_read`

## Module Loading and Wiring

[`POPFile::Loader`](POPFile/Loader.pm) is the orchestrator. It scans module directories and instantiates:

- `POPFile/` as `core`
- `Classifier/` as `classifier`
- `Services/` as `services`
- `Proxy/` as `proxy`

Then it wires references into the loaded modules:

- all modules receive `configuration`, `mq`, and `version`
- modules that support it receive `classifier` and `history`
- proxy/core modules that need high-level classification receive `Services::Classifier`
- `POPFile::API` receives `Services::IMAP`
- `Classifier::Bayes` and `POPFile::History` are linked to each other
- `Classifier::MailParse` is wired to `Classifier::WordMangle`

This keeps modules loosely coupled: most things talk through injected collaborators instead of discovering each other ad hoc.

## Main Runtime Components

### Core Infrastructure

- [`POPFile::Configuration`](POPFile/Configuration.pm)
  Owns registered config parameters, loads/saves `popfile.cfg`, applies command-line overrides, resolves user/root-relative paths, and manages the pid file.

- [`POPFile::Logger`](POPFile/Logger.pm)
  Configures `Log::Any`, writes rotating log files, can also log to stdout, and emits hourly `TICKD` events.

- [`POPFile::MQ`](POPFile/MQ.pm)
  In-process asynchronous FIFO message bus. Modules register for message types and receive them via `deliver()`.

- [`POPFile::History`](POPFile/History.pm)
  Stores classification history in the database, manages cached message files in `messages/`, supports history queries, and handles reclassification bookkeeping.

- [`POPFile::API`](POPFile/API.pm)
  Mojolicious app that serves the SPA and the REST API under `/api/v1/*`.

### Classification Layer

- [`Classifier::Bayes`](Classifier/Bayes.pm)
  The main Naive Bayes engine. It manages buckets, corpus words, magnets, stopwords, classification, training, and session-key based access.

- [`Classifier::MailParse`](Classifier/MailParse.pm)
  Parses message structure and extracts tokens.

- [`Classifier::WordMangle`](Classifier/WordMangle.pm)
  Normalizes tokens: lowercasing, language-sensitive handling, stemming, stopword filtering, and related cleanup.

- [`Services::Classifier`](Services/Classifier.pm)
  Thin facade around `Classifier::Bayes` that acquires one long-lived admin session and exposes simpler service methods to API/controllers and proxy modules.

### IMAP Path

- [`Services::IMAP`](Services/IMAP.pm)
  Main modern ingestion path. Runs on a recurring `Mojo::IOLoop` timer, polls watched folders, classifies new messages, moves them to destination folders, detects user reclassification by observing moves into output folders, and supports archive training.

- [`Services::IMAP::Client`](Services/IMAP/Client.pm)
  Low-level IMAP4 client implementation over raw sockets / SSL sockets. Handles connect, login, mailbox listing, `STATUS`, `SELECT`, `UID SEARCH`, `UID FETCH`, folder creation, moves, and expunge behavior.

### Legacy Proxy Path

- [`Proxy::Proxy`](Proxy/Proxy.pm)
  Base class for TCP proxy servers. Opens local listeners on `Mojo::IOLoop`, then hands each accepted connection to a subprocess.

- [`Proxy::POP3`](Proxy/POP3.pm), [`Proxy::SMTP`](Proxy/SMTP.pm), [`Proxy::NNTP`](Proxy/NNTP.pm)
  Protocol-specific proxies. POP3 is the most classification-heavy path; it retrieves messages from the upstream server, passes them through the classifier, and returns modified messages to the client.

## Web Application

### Backend API

[`POPFile::API`](POPFile/API.pm) builds a Mojolicious app and:

- serves static frontend assets from `public/`
- rewrites non-API routes to `index.html` for SPA navigation
- exposes REST endpoints under `/api/v1`

Main controller responsibilities:

- [`POPFile::API::Controller::Config`](POPFile/API/Controller/Config.pm)
  Reads and updates persisted configuration, and provides status/diagnostic checks.

- [`POPFile::API::Controller::Corpus`](POPFile/API/Controller/Corpus.pm)
  Bucket CRUD, word inspection/moves, stopwords, stopword candidates.

- [`POPFile::API::Controller::History`](POPFile/API/Controller/History.pm)
  History listing, detail view, message-body preview, single and bulk reclassification.

- [`POPFile::API::Controller::IMAP`](POPFile/API/Controller/IMAP.pm)
  IMAP watched folders, bucket-folder mappings, live folder discovery, connection testing, and training triggers.

- `Locale` / `Magnets` controllers
  Internationalization payloads and magnet management.

The API mostly delegates real work to `Services::Classifier`, `POPFile::History`, and `Services::IMAP`.

### Frontend

The frontend lives in `ui/` and is built with:

- Svelte 5
- Vite 8
- `@sveltejs/vite-plugin-svelte`

Key files:

- [`ui/src/App.svelte`](ui/src/App.svelte)
  Top-level shell, hash-based navigation, theme switch, initial bucket/config fetch, page routing.

- [`ui/src/lib/*.svelte`](ui/src/lib)
  Feature screens: history, corpus, magnets, IMAP, status, settings.

- [`ui/src/lib/connectivity.svelte.js`](ui/src/lib/connectivity.svelte.js)
  Wraps `fetch` globally, detects backend outages, and drives reconnect behavior.

- [`ui/src/lib/locale.svelte.js`](ui/src/lib/locale.svelte.js)
  Loads language bundles from the backend and resolves translation keys.

[`ui/vite.config.js`](ui/vite.config.js) proxies `/api` to `http://localhost:8080` in development and builds production assets into `../public`.

## Main Data Flows

### 1. IMAP Classification Flow

```text
Mojo recurring timer
  -> Services::IMAP::poll()
  -> subprocess does IMAP/network + DB-heavy work
  -> Services::IMAP::Client fetches new messages
  -> Classifier::Bayes classifies message
  -> POPFile::History records history/cache entry
  -> IMAP client moves message to folder mapped from bucket
  -> parent callback updates uid tracking and posts MQ event
```

Important details:

- watched folders and bucket-folder mappings live in config
- UID tracking is persisted in `imap_uidnexts` and `imap_uidvalidities`
- training is triggered by filesystem flag files like `popfile.train` and `popfile.train.<bucket>`
- reclassification can happen implicitly when a known message appears in a mapped output folder

### 2. Web Reclassification Flow

```text
Svelte UI
  -> POST /api/v1/history/:slot/reclassify
  -> History controller updates history classification
  -> Services::Classifier removes old bucket training
  -> Services::Classifier adds new bucket training
  -> Services::IMAP is asked to move the corresponding IMAP message if possible
```

### 3. Proxy Classification Flow

```text
Mail client
  -> local POP3/SMTP/NNTP proxy
  -> upstream mail/news server
  -> proxy intercepts message stream
  -> Services::Classifier / Bayes classifies message
  -> message returned with POPFile classification headers
  -> history/cache updated
```

## Communication Patterns

The codebase uses a small number of communication patterns repeatedly:

- Direct method injection
  Loader injects collaborators such as config, MQ, classifier, history, and services.

- In-process event bus
  `POPFile::MQ` delivers async messages like `TICKD`, `COMIT`, `RELSE`, and `IMAP_DONE`.

- HTTP/JSON
  The Svelte frontend talks to the Mojolicious backend over REST endpoints.

- Filesystem signals
  IMAP training requests are queued by creating flag files in the user data directory.

- Database persistence
  Bayes and History share the SQLite-backed state.

- Network sockets
  IMAP client and legacy proxies talk to external mail servers over TCP/SSL.

## Persistence and State

### Config and Runtime Files

- `popfile.cfg`
  Main persisted configuration.

- `popfile.pid`
  Running instance marker.

- `popfile.port`
  The chosen API port when `api_port=0`.

- `messages/`
  Cached message files used by history and some reclassification flows.

- `popfile.train*`
  IMAP training request flags.

- log files
  Written by `POPFile::Logger`.

### Database

The default datastore is SQLite, using schema [`Classifier/popfile.sql`](Classifier/popfile.sql).

Important tables:

- `users`
  Currently effectively single-user (`admin`).

- `buckets`
  Real and pseudo buckets (`unclassified` is a pseudo bucket).

- `words`
  Unique token table.

- `matrix`
  Word frequency counts per bucket. This is the training corpus.

- `history`
  Classification history, metadata, hashes, previous bucket, magnet, and size.

- `magnets` and `magnet_types`
  Rule-like shortcuts for deterministic classification based on headers.

- `bucket_params` / `bucket_template`, `user_params` / `user_template`
  Extensible parameter storage.

## Technologies Used

### Backend

- Perl 5.40 via perlbrew
- Object::Pad for class syntax
- Mojolicious and Mojo::IOLoop for HTTP serving and timers
- DBI + DBD::SQLite for persistence
- Log::Any for logging
- Carton for dependency management

### Frontend

- Svelte 5
- Vite 8
- Plain CSS
- Hash-based client-side navigation

### Supporting Infrastructure

- Docker / Docker Compose for local runtime
- GitHub Actions for CI
- `vendor/perl-querybuilder` submodule for SQL query construction in parts of the codebase

## Architectural Characteristics

The current architecture is a hybrid:

- old POPFile concepts are still present: module lifecycle, proxies, MQ, history cache files
- newer infrastructure has been introduced: Mojolicious API, Svelte SPA, `Mojo::IOLoop`, subprocess-backed IMAP polling

That leads to a few important design traits:

- single-process core runtime, but with subprocesses for blocking or isolated work
- strong backward compatibility with legacy proxy behavior
- modern UI/API layered on top of an older classifier core
- mostly stateful modules with explicit lifecycle rather than stateless services
- configuration-driven runtime wiring

## Directory Map

- `script/`, `bin/`
  Startup scripts.

- `POPFile/`
  Core runtime modules, API app, configuration, logging, loader, MQ, history.

- `Classifier/`
  Bayes engine, parsing, token normalization, SQL schema.

- `Services/`
  Higher-level runtime services, especially IMAP and the classifier facade.

- `Proxy/`
  Legacy protocol proxy servers.

- `ui/`
  Svelte source tree.

- `public/`
  Built frontend assets served by Mojolicious.

- `languages/`
  Translation bundles.

- `t/`
  Test suite.

## In One Sentence

POPFile on `main` is a Perl-based mail-classification engine with a loader-driven module system, SQLite-backed Bayes/history core, modern in-process Mojolicious API and Svelte UI, IMAP-first message processing, and legacy proxy support retained for older mail client setups.
