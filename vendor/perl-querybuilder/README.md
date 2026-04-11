# Perl Query Builder

A flexible SQL query builder for Perl with dialect support for PostgreSQL, MySQL, and SQLite.

## Features

- Not an ORM, but an OO approach to SQL queries
- Stitch them together dynamically with a lot of flexibility
- Has building blocks in different dialects and you can easily make  your own

## Currently Supported Dialects

- **PostgreSQL**
- **MySQL**
- **SQLite**

## Quick Start

```perl
use Query::Builder;
my $qb = Query::Builder->new(dialect => 'sqlite');
my $clause = $qb->combine(AND => 
    $qb->compare(name => ['Fatima', 'Leandra']),
    $qb->is_true('can_sing'));   
say $clause;
say join ',' $clause->params();
```

```text output
```

or something less basic:

```perl
say $qb->select(qw(id first_name last_name gender birthday r.title t.name t.city))
    ->from('actors a')
    ->with(
        $qb->select($qb->relation('id')->as('theater_id'), 'name', 'city'))
            ->from('venues')
            ->where($qb->compare(type => 'theater')->as('theaters'))
    ->joins(
        $qb->join('roles')
            ->as('r')
            ->on($qb->compare('r.actor_id', a.id)),
        $qb->join('theaters')
            ->as('t')
            ->using('theater_id'))
    ->where($qb->combine(AND => $qb->is_true('a.active'), $qb->compare('a.age', 30, '>')))
    ->order_by($qb->order_by('a.birthday', 'DESC'), $qb->order_by('a.last_name'))
    ->limit(100)
    ->offset(100);
```

```text output
```

## API Reference

### Basic Comparisons

#### `compare($column, $value, %args)`

Compare a column to one or more values.

```perl
$qb->compare(name => 'Agnaldo')->negate();
# NOT ( name = ? )
$qb->compare(age => 18, comparator => '>=');
# age >= 16
$pg->compare(status => ['active', 'pending']); 
# output depending on dialect with IN (?, ?) or ANY(?)
# age IN (?, ?)
$pg->compare(score => [80, 90, 100], comparator => '&&'); # depending on db
# score && ?
```

### Pattern Matching

#### `like($column, $pattern, %args)`

Pattern matching with LIKE.

```perl
# PostgreSQL: Uses ILIKE for case-insensitive by default
my $pg = Query::Builder->new(dialect => 'pg');

$pg->like(name => '%Agnaldo%', case_sensitive => true);
# name ILIKE ?
$qb->like(email => '%@spam.com')->negate();
# NOT (email LIKE ?)
```

### Logical Operators

#### `combine_and(@expressions)`

Combine expressions with AND.

```perl
my $query = $qb->combine_and(
    $qb->compare(age => 18, comparator => '>='),
    $qb->compare(country => 'Cuba'));
# SQL: age >= ? AND country = ?
```

#### `combine_or(@expressions)`

Works the same, shorthand for

```perl
my $query = $qb->combine(OR =>
    $qb->compare(role => 'admin'),
    $qb->compare(role => 'moderator'));
# SQL: role = ? OR role = ?
```

### Boolean Values

#### `is_true($column = undef)`

Returns a TRUE expression or a column reference.

```perl
# Literal TRUE (no column parameter)
# PostgreSQL
$qb->is_true();  # SQL: TRUE

# With column parameter - returns the column as-is
$qb->is_true('is_active');  # SQL: is_active

# Use case: boolean column checks
```

#### `is_false($column = undef)`

Returns a FALSE expression or a negated column reference.

### Advanced Operations

#### `negate(@expressions)`

Negate one or more expressions.

```perl
my $expr = ;
my $negated = $qb->negate(
    $qb->compare(name => 'test'), 
    $qb->compare(name => 'foo'));
# SQL: NOT ( name = ? OR foo = ?)
```

#### `combine($link, @expressions)`

combine expressions with a custom operator.

```perl
my $query = $qb->combine('OR', @expressions);
```

## Complex Examples

### Nested Conditions

```perl
my $query = $qb->combine_and(
    $qb->combine_or(
        $qb->compare(role => 'admin'),
        $qb->compare(role => 'moderator')),
    $qb->is_true('active'),
    $qb->compare(age => 18, comparator => '>='));
# SQL: ( role = ? OR role = ? ) AND active = ? AND age >= ?
# Params: ('admin', 'moderator', 1, 18)
```
