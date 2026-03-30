# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is POPFile

POPFile is a Bayesian email classifier written in Perl. It acts as a proxy between mail clients and mail servers (POP3, SMTP, NNTP), intercepting messages and inserting an `X-Text-Classification:` header with the predicted category ("bucket"). Users correct misclassifications through the web UI, which trains the classifier over time.

## Environment and Dependencies

**Perl version:** `perl-5.40.0` via perlbrew. Never use system Perl or system Perl libraries.

**Dependency management:** Carton. All dependencies are declared in `cpanfile` and installed locally into `local/`. Every Perl invocation must go through `carton exec`.

**`lib/` directory:** Only `lib/Query/` is vendored (local Query::Builder). Everything else comes from carton. Do not add XS modules, Windows DLLs, or autosplit artifacts to `lib/` — these cause version mismatches across platforms.

**CI:** GitHub Actions runs `carton install` then `carton exec prove -l t/` on Perl 5.40.

```sh
carton install          # install/update dependencies
carton exec perl popfile.pl
carton exec prove -l t/
```

Prefer well-established CPAN modules over maintaining custom code:
- `Log::Any`, `DBI`, `Mojolicious`, `Path::Tiny`, `Cpanel::JSON::XS`, etc.

## Commands

### Run POPFile

```sh
carton exec perl popfile.pl
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

### Update this!
For architecture changes, update CLAUSE.md to reflect changes, so that future sessions don't start with the wrong impression

### Database

SQLite 3.x (via `DBD::SQLite >= 1.00`) is the default backend; MySQL and PostgreSQL are also supported. The schema is in `Classifier/popfile.sql`. Key tables: `users`, `buckets`, `words`, `matrix` (word×bucket corpus), `history`, `magnets`, `magnet_types`.

### Bundled libraries

`lib/Query/` contains a local vendored copy of Query::Builder (not on CPAN). All other dependencies come from carton (`local/`).

### Internationalization

UI strings live in `languages/*.msg` files, one per locale.


You are an expert programmer using these guidelines (you can break these rules if editing existing source code, and adapt to the present style, if it isn't too crazy):

When you reply be friendly, precise and to the point. Don't gratulate youself to your successes. Better test your assumptions and communicate the results.

# Coding Style Guidelines

## Perl:

### General Principles
- Avoid comments in code - use aptly named variables or log entries instead
- No empty lines within methods/functions
- One empty line between methods/functions
- One empty line between blocks of use/class/package/(group of) field statements
- {} for scopes has a closing `}` at a newline, for hashes with a space in front at the last line with values.

### Method Calls
- Always use parentheses on method calls, even if empty
- Example: `$obj->method()` not `$obj->method` and not `$onj->method->something_else()`
- optional arguments usually as an %args hash
- use fields :reader :writer shortcuts where possible

### use statements
- first core dependencies, then alphabetically, unless for a good reason

### Control Flow
- Avoid declaring without assigning; `my $bad;`
- Prefer early returns over nested if statements
- Avoid deep nesting

### Postfix Conditionals, for, while
- Prefer this notation
```perl
return $result
    if $condition;
$count += $_->@*
    for @items;
die 'error message'
    unless $required;
```
- Postfix if/unless must have line break and indentation
- This makes it clearer what is being returned
- prefer positive conditions (no `if !`, but `unless`)
```
  do() if $so
  # or
  do() unless $so
```

### if elsif else
- prefer trinary if feasible and possible to keep it 3 or even 1 line(s)
```perl
my $x = $cond
    ? $this
    : $that;
```

### Return Statements
- No semicolon on return statements at the end of methods
```perl
return $value    # no semicolon
```

### Loops and Iteration
- Prefer `for` to `foreach`
- Prefer `map`, `grep`, `biltin::any` with one-line blocks over `for` loops
- If multi-line block required, prefer a support sub or coderef instead of inlining too much

### Module Structure (Perl)
- No `1;` at end of file unless required by perl version
- Separate statement groups with one empty line:
  - `use` statements
  - `class`/`package` declaration
  - `field` declarations
  - methods

### General
- use qw()
- NEVER align vertically.
- Avoid multiple commands on a line. as a general rule, use on ; per line only.
- fix `@{$bla}` (and similar) to `$bla->@*` (and so on)
- prefer working with @lists and %hashes to $references, use them as booleans
- make use of fat comma, where it makes sense 
  ```perl
  $self->apply(username => $email);
  ```
- user reader/writer abstractions
- use roles rather than inheritance, where this is possible
- keep the code clean and readable

### Example for good code
```perl
use Init qw(:class :signatures :bool); # put feature selection in a module

class MyClass; # no {brackets} unless required

use Another::Module; # sorted alphabetically
use Other::Module;

ADJUST {
    # use for initialization ....
}

field $foo :param=123 :reader;
field $bar :param=true :reader :writer;

method first_method($param, %args) { # I like greedy %args
    return $self->second_method()
        if $args{condition}; # break and ident
    my $result = $self->process($arg);
    return $result # no semicolon on tailing returns
}

method second_method() {
    my $multi = 2;
    my $transform = sub($x) { $x * $multi };
    my @items = map { $transform->($_) } @source;
    return $self->first_method(\@items) # always return, even nothing, avoid returning undef
}

my %hash = (
    some => 'thing',
    then => {
        another => 'here',
        and => 'there' } );
        
my $x = do {
    if ($c1) {
        1
    } elsif($c2) {
        2
    } else {
        3
    } };
```
- always return from a function, usually don't retun explicit `undef`
- use `try {} catch($e) {} finally {}` instead of eval
- DO NOT ALIGN VERTICALLY and fix it whereever you find it!
- see sometng repeats too often, refactor it into a method
- don't be overly chatty or explain too much, don't jump ahead, but go one step at a time, unless told otherwise. 
- don't execute db queries unless allowed. in test setting, you may.
- keep your edits and commands within the code directory
- if you want to use the gh executable for github, use `/usr/bin/gh`
- run tests, add tests
- fix documentation
- convert good information from comments to PODs

** Konkrete Muster die VERBOTEN sind:
- Extra Spaces vor `=>` damit alle Werte in einer Hash-Liste auf gleicher Spalte stehen
- einfache Hash-Keys NIEMALS quoten (explizit verboten) — `hostname => $val` NICHT `'hostname' => $val`
- Extra Spaces vor `=` damit alle Zuweisungen in einer Variablengruppe auf gleicher Spalte stehen
- Extra Spaces vor `//` in Default-Zuweisungen

## IMPORTANT:
Reference AGENT.md for your role and information that pertain to you.
