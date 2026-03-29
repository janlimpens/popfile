# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is POPFile

POPFile is a Bayesian email classifier written in Perl. It acts as a proxy between mail clients and mail servers (POP3, SMTP, NNTP), intercepting messages and inserting an `X-Text-Classification:` header with the predicted category ("bucket"). Users correct misclassifications through the web UI, which trains the classifier over time.

## Commands

### Install dependencies

Develop inside a container. Use docker-compose or similar to string services together.

Use carton/perlbrew/perlenv and install locally to the project — no system Perl or system Perl libs. Set things up so the environment does not need to be recreated verbosely.

Prefer well-established Perl modules:
- `Log::Any`
- `DBI`
- `Mojolicious`
- `Path::Tiny`
- `Cpanel::JSON::XS`

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

### Keep this file up to date

For architecture changes, update CLAUDE.md to reflect the new state, so future sessions don't start with the wrong picture.

## Coding Style Guidelines

When you reply: be friendly, precise and to the point. Don't congratulate yourself. Test your assumptions and communicate the results.

### General Principles

- Avoid comments in code — use aptly named variables or log entries instead
- No empty lines within methods/functions
- One empty line between methods/functions
- One empty line between blocks of `use` / `class` / `package` / field statements
- Closing `}` on its own line for scopes; for hashes, a space before `}` on the last value line

### Method Calls

- Always use parentheses on method calls, even if empty: `$obj->method()` not `$obj->method`
- Optional arguments as a `%args` hash
- Use field reader/writer shortcuts where possible

### Imports

- Core dependencies first, then alphabetically — unless there is a good reason not to

### Control Flow

- Avoid declaring without assigning: no `my $bad;`
- Prefer early returns over nested `if`
- Avoid deep nesting

### Postfix Conditionals

```perl
return $result
    if $condition;

$count += $_->@*
    for @items;

die 'error message'
    unless $required;
```

- Postfix `if`/`unless` must have a line break and indentation
- Prefer unnegated conditions

### Ternary

```perl
my $x = $cond
    ? $this
    : $that;
```

### Return Statements

No semicolon on the final return of a method:

```perl
return $value
```

### Loops and Iteration

- Prefer `for` to `foreach`
- Prefer `map`, `grep`, `builtin::any` with one-line blocks over `for` loops
- For multi-line blocks, prefer a support sub or coderef over inlining

### Module Structure

- No `1;` at end of file unless required by the Perl version
- Separate statement groups with one empty line

### General

- Use `qw()`
- **Never align vertically** — not `=>`, not `=`
- One `;` per line
- Use `$bla->@*` instead of `@{$bla}` (and analogues)
- Use fat comma where it reads naturally: `$self->apply(username => $email)`
- Use roles rather than inheritance where possible

### Example

```perl
use Init qw(:class :signatures :bool);

class MyClass;

use Another::Module;
use Other::Module;

ADJUST {
    # initialization
}

field $foo :param=123 :reader;
field $bar :param=true :reader :writer;

method first_method($param, %args) {
    return $self->second_method()
        if $args{condition};
    my $result = $self->process($param);
    return $result
}

method second_method() {
    my $multi = 2;
    my $transform = sub($x) { $x * $multi };
    my @items = map { $transform->($_) } @source;
    return $self->first_method(\@items)
}

my %hash = (
    some => 'thing',
    then => {
        another => 'here',
        and => 'there' } );
```

## IMPORTANT

Reference AGENT.md for your role and agent-specific information.

Don't be overly chatty or explain too much. Go one step at a time unless told otherwise. Don't execute DB queries unless allowed (in test settings you may).
