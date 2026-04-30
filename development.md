# Development

## Run all tests

```sh
make test
```

Starts a Dockerised Dovecot instance, runs the full test suite (including IMAP/POP3
integration tests), and tears down Dovecot afterwards.

To run tests without Dovecot (integration tests will skip):

```sh
make test-no-dovecot
```

## Test mail server (manual)

POPFile integration tests use Dovecot via Docker Compose.

| Service   | Protocol | Host port |
|-----------|----------|-----------|
| Dovecot   | IMAP     | 10143     |
| Dovecot   | POP3     | 10110     |

Test account: `test` / `test`.

### Manual lifecycle

```sh
docker compose -f docker-compose.test.yml up -d    # start
docker compose -f docker-compose.test.yml down -v  # stop (clean)
```

### Seed test mail

```sh
carton exec perl t/fixtures/seed_imap.pl           # seed INBOX
carton exec perl t/fixtures/seed_imap.pl --teardown # remove
```

## POP3 tests (manual)

Direct connection:

```sh
POP3_TEST_HOST=localhost carton exec prove -l t/pop3-proxy.t
```

## License

GNU General Public License v3.0 or later. See [LICENSE](LICENSE).
