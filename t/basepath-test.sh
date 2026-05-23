#!/bin/sh
# Integration test for base_path reverse proxy support
# Verifies: dependencies (carton check), <base> tag, relative assets, API, CSS, health
# Run from repo root:  carton exec t/basepath-test.sh
set -eu

echo "=== Checking dependencies ==="
carton check 2>&1 | grep -q "satisfied" || {
	echo "FAIL: carton check failed — missing dependencies. Run: carton install"
	exit 1
}

# Verify carton bundle is self-contained (no system module fallback)
SELF=$(PERL5LIB="local/lib/perl5" perl -MObject::Pad -MPath::Tiny -MMojo::JSON -MCpanel::JSON::XS -MEncode -MDBI -MDBD::SQLite -MMojolicious -MIO::Socket::SSL -E 'say "ok"' 2>&1)
if [ "$SELF" = "ok" ]; then
	echo "PASS: carton bundle self-contained"
else
	echo "FAIL: some modules leak from system — check Docker build"
	exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf $TMPDIR; kill $SERVER_PID 2>/dev/null; wait $SERVER_PID 2>/dev/null' EXIT

export POPFILE_USER="$TMPDIR/user"
export POPFILE_PATH="$POPFILE_USER/config.json"
mkdir -p "$POPFILE_USER/messages"

cat >"$POPFILE_PATH" <<'EOF'
{"version":2,"api":{"port":0,"base_path":"/popfile","local":false,"open_browser":false,"static_dir":"public"}}
EOF

echo "=== Starting POPFile ==="
carton exec perl script/popfile start &
SERVER_PID=$!

echo "→ Waiting for server..."
PORT=""
for _ in $(seq 1 30); do
	PORT=$(ss -tlnp 2>/dev/null | grep "$SERVER_PID" | grep -oP ':\K\d+' | head -1 || echo "")
	if [ -n "$PORT" ] && curl -skf "http://localhost:$PORT/api/v1/health" >/dev/null 2>&1; then
		break
	fi
	sleep 1
	PORT=""
done
if [ -z "$PORT" ]; then
	echo "FAIL: Server did not start"
	exit 1
fi
echo "→ Server on port $PORT"

BASE="http://localhost:$PORT/popfile"
fail() {
	echo "FAIL: $1"
	exit 1
}
pass() { echo "PASS: $1"; }

echo ""
echo "--- 1. HTML has <base href> ---"
curl -sk "$BASE/" | grep -q '<base href="/popfile/">' &&
	pass "base tag present" || fail "base tag missing"

echo ""
echo "--- 2. Relative asset paths ---"
curl -sk "$BASE/" | grep -q 'src="./assets/' &&
	pass "relative assets" || fail "assets not relative"

echo ""
echo "--- 3. API via base_path ---"
curl -sk "$BASE/api/v1/health" | grep -q '"status"' &&
	pass "API reachable" || fail "API not reachable"

echo ""
echo "--- 4. Assets load (CSS) ---"
CSS_PATH=$(curl -sk "$BASE/" | grep -oP 'href="(\./assets/[^"]+\.css)"' | head -1 | cut -d'"' -f2 | sed 's|^\.|/popfile|')
HTTP=$(curl -sk -o /dev/null -w '%{http_code}' "http://localhost:$PORT$CSS_PATH")
[ "$HTTP" = "200" ] &&
	pass "CSS loaded ($CSS_PATH)" || fail "CSS returned $HTTP"

echo ""
echo "--- 5. Direct / (no prefix) still works ---"
HTTP=$(curl -sk -o /dev/null -w '%{http_code}' "http://localhost:$PORT/")
[ "$HTTP" = "200" ] &&
	pass "direct access (200)" || fail "direct access returned $HTTP"

echo ""
echo "--- 6. Health check ---"
curl -sk "$BASE/api/v1/health" | grep -q '"ok"' &&
	pass "health ok" || fail "health not ok"

echo ""
echo "=== ALL TESTS PASSED ==="
