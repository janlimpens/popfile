# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is POPFile

POPFile is a Bayesian email classifier written in Perl. It acts as a IMAP client moving messages to folders and/or as proxy between mail clients and mail servers (POP3, and some), intercepting messages and inserting an `X-Text-Classification:` header with the predicted category ("bucket"). Users correct misclassifications through the web UI, which trains the classifier over time.

## Environment and Dependencies

**Perl version:** `perl-5.40.0` via perlbrew. Never use system Perl or system Perl libraries.

**Dependency management:** Carton. All dependencies are declared in `cpanfile` and installed locally into `local/`. Every Perl invocation must go through `carton exec`.

**`lib/` directory:** Everything except git submodules comes from carton.

**CI:** GitHub Actions runs `carton install` then `carton exec prove -l t/` on Perl 5.40.

```sh
carton install          # install/update dependencies
carton exec perl script/popfile start
carton exec prove -l t/
```

Prefer well-established CPAN modules over maintaining custom code:
- `Log::Any`, `DBI`, `Mojolicious`, `Path::Tiny`, `Cpanel::JSON::XS`, etc.

## Commands

### Run POPFile

```sh
carton exec perl script/popfile start
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

`POPFile::Loader` discovers, loads, links, and drives all modules through this lifecycle. The main entry point (`script/popfile`) delegates entirely to `POPFile::Loader`.

### Module groups

| Namespace | Role |
|-----------|------|
| `POPFile::` | Core infrastructure: `Loader`, `Module` (base), `Configuration`, `History`, `MQ` (message queue), `Mutex`, `Logger`, `API` |
| `Classifier::` | `Bayes` (Naive Bayes engine), `MailParse` (MIME/email parsing), `WordMangle` (word normalization) |
| `Proxy::` | `Proxy` (base), `POP3`, `SMTP`, `NNTP` — sit between mail client and server |
| `UI::` | `Mocolicious Web API` |
| `Services`| `mainly IMAP Implementation` |

### Update this!
Update CLAUSE.md to reflect architectonical changes

### Database

SQLite 3.x (via `DBD::SQLite >= 1.00`) is the default backend; MySQL and PostgreSQL are also supported. The schema is in `Classifier/popfile.sql`. Key tables: `users`, `buckets`, `words`, `matrix` (word×bucket corpus), `history`, `magnets`, `magnet_types`.

### Bundled libraries

`vendor/perl-querybuilder` is a git submodule pointing to [janlimpens/perl-querybuilder](https://github.com/janlimpens/perl-querybuilder). After cloning, initialise it with:

```sh
git submodule update --init
```

All other dependencies come from carton (`local/`).

### Internationalization

UI strings live in `languages/*.msg` files, one per locale.


## Contributing to dependencies

`vendor/perl-querybuilder` is a full git clone. You can develop fixes inside it and submit them upstream.

### Identify the issue

Run tests to reproduce. Note whether the missing feature or bug is in the builder API (`Query::Builder`, `Query::Dialect::*`) or in an `Expression` subclass.

If the feature does not exist upstream yet, open an issue at [janlimpens/perl-querybuilder](https://github.com/janlimpens/perl-querybuilder) before starting work.

### Fix inside the submodule

```sh
cd vendor/perl-querybuilder
git checkout -b fix/my-feature
# edit, test locally
cd ../..
carton exec prove -l t/    # run POPFile tests against your change
```

### Open a PR upstream

```sh
cd vendor/perl-querybuilder
git push origin fix/my-feature
# open PR at https://github.com/janlimpens/perl-querybuilder
```

### Update the submodule pointer after merge

Once the upstream PR is merged:

```sh
cd vendor/perl-querybuilder
git checkout main && git pull
cd ../..
git add vendor/perl-querybuilder
git commit -m "chore: update perl-querybuilder submodule to <description>"
```

You are an expert programmer using these guidelines:

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
- Declare with assign; `my $good = $value;`
- Prefer early returns over nested if statements
- Extract smaller methods with meaningful names, if a method goes more than 1 thing. A method has max 50 lines.

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
- Postfix if/unless/for must have line break and indentation
- prefer positive booleans `unless ( $stuff eq '' )`
```
  do() if $so
  # or
  do() unless $so
```

### if elsif else
- prefer trinary if feasible and possible to keep it 3 or even 1 line(s) if it fits within 74 chars
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
- Use `for` instead of `foreach`
- Prefer `map`, `grep`, `builtin::any` with one-line blocks over `for` loops
- If multi-line block required, prefer a support sub or coderef instead of inlining too much

### Module Structure (Perl)
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
- prefer working with @lists and %hashes to $references, use them directly as booleans
- make use of fat comma, where it makes sense 
  ```perl
  $self->apply(username => $email);
  ```
- user reader/writer abstractions
- use roles rather than inheritance, where possible, but keep it simple, not roles pulling in stuff, pulling other stuff. roles should be self contained.
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
# not padded:
field $foo :param=123 :reader;
field $barbaz :param=true :reader :writer;

method first_method($param, %args) { # greedy %args
    return $self->second_method()
        if $args{condition}; # break and ident
    my $result = $self->process($arg);
    return $result # no semicolon on tailing returns
}

method second_method() {
    my $multi = 2;
    my $transform = sub($x) { 
        my $first step = 1 / $x * $multi;
        my $second_step = $first_step > 0 ? $first_step * -1 : 0;
        return $second_step };
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
- always return from a function, usually don't return explicit `undef`
- use `try {} catch($e) {} finally {}` instead of eval
- DO NOT ALIGN/pad VERTICALLY and fix it whereever you find it! One space is enough!
- if a procedure repeats too often, refactor it into a method/role
- don't execute destructive db queries except in safe test settings.
- keep your edits and commands within the code directory
- run tests, add tests, create tests before implementations
- fix documentation, PODs
- convert good information from comments to PODs

## IMPORTANT:
Reference AGENT.md for your role and information that pertain to you.
