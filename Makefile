.PHONY: test test-ci test-no-dovecot dovecot-start dovecot-wait dovecot-stop

test: dovecot-start dovecot-wait
	carton exec prove -l t/ 2>&1
	@$(MAKE) dovecot-stop

test-ci:
	carton exec prove -l t/ 2>&1

test-no-dovecot:
	carton exec prove -l t/ 2>&1

dovecot-start:
	@echo "=== Dovecot start ==="
	docker compose -f docker-compose.test.yml up -d --wait 2>/dev/null \
		|| docker compose -f docker-compose.test.yml up -d

dovecot-wait:
	@echo "=== Dovecot wait ==="
	@for i in 1 2 3 4 5 6 7 8 9 10; do \
		docker compose -f docker-compose.test.yml exec -T imap sh -c 'echo OK' 2>/dev/null && break; \
		echo "  ...waiting ($$i/10)"; \
		sleep 1; \
	done

dovecot-stop:
	@echo "=== Dovecot stop ==="
	docker compose -f docker-compose.test.yml down -v
