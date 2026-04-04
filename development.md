# Development: Test Mail Server Environment

POPFile's integration tests use a Dockerised Dovecot instance that exposes both IMAP and POP3.

## Prerequisites

- Docker with Compose v2 (`docker compose`)
- Carton / perlbrew configured (see README)

## Start the test servers

```sh
docker compose -f docker-compose.test.yml up -d
```

This starts:

| Service | Protocol | Host port |
|---------|----------|-----------|
| Dovecot | IMAP     | 10143     |
| Dovecot | POP3     | 10110     |
| SnappyMail (optional webmail) | HTTP | 8888 |

The single test account is `test` / `test`.

## Seed test mail (IMAP)

```sh
carton exec perl t/fixtures/seed_imap.pl
```

Appends 100 messages (mix of ham and spam fixtures) to INBOX.
Accepts environment overrides: `IMAP_HOST`, `IMAP_PORT`, `IMAP_USER`, `IMAP_PASS`, `SEED_COUNT`.

To remove all seeded mail:

```sh
carton exec perl t/fixtures/seed_imap.pl --teardown
```

## Run IMAP tests

Write the IMAP config into `popfile.cfg`:

```sh
carton exec perl t/fixtures/setup_test_config.pl
```

Then run the IMAP-related tests (requires a running server and seeded mail):

```sh
carton exec prove -l t/mojo-history.t
```

## Run POP3 tests

### Direct (no proxy)

```sh
POP3_TEST_HOST=localhost carton exec prove -l t/pop3-proxy.t
```

The test connects directly to Dovecot on port 10110 using the default credentials (`testuser` / `testpass`; override with `POP3_TEST_USER` / `POP3_TEST_PASS`).

### Via the POPFile POP3 proxy

Write the proxy config, then start POPFile:

```sh
carton exec perl t/fixtures/setup_test_pop3_config.pl
carton exec perl popfile.pl &
```

Run with proxy mode enabled:

```sh
POP3_TEST_HOST=localhost POP3_TEST_PORT=1110 POP3_VIA_PROXY=1 \
  carton exec prove -l t/pop3-proxy.t
```

In proxy mode the test verifies that the `X-Text-Classification:` header is present on retrieved messages.

## Tear down

```sh
docker compose -f docker-compose.test.yml down -v
```

The `-v` flag removes the `imap-mail` volume so the next run starts clean.
