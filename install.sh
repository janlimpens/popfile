#!/bin/sh
set -e

echo "POPFile installer"
echo "================="

# ── try Docker ──
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "→ Docker found, launching container…"
    docker run -d --name popfile --restart unless-stopped \
        -p 8080:8080 -e POPFILE_USER=/data -v popfile-data:/data \
        ghcr.io/janlimpens/popfile:latest
    echo "→ POPFile is running at http://localhost:8080"
    echo "  Stop:   docker stop popfile"
    echo "  Logs:   docker logs popfile"
    exit 0
fi

# ── try perl+carton ──
if command -v perl >/dev/null 2>&1; then
    PERL_VER=$(perl -e 'print $]')
    if [ "$PERL_VER" = "5.040000" ] || [ "$PERL_VER" = "5.040000" ]; then
        echo "→ Perl 5.40 found, checking Carton…"
    else
        echo "→ Perl found (v$PERL_VER), but POPFile needs 5.40."
    fi
fi

if command -v carton >/dev/null 2>&1; then
    echo "→ Carton found."
else
    echo "→ Installing Carton…"
    cpanm --notest Carton 2>/dev/null || {
        echo "✗ Could not install Carton. Please install Docker instead:"
        echo "  https://docs.docker.com/get-docker/"
        exit 1
    }
fi

# ── clone & install ──
REPO="https://github.com/janlimpens/popfile.git"
DEST="${POPFILE_HOME:-$HOME/.popfile}"

if [ -d "$DEST" ]; then
    echo "→ $DEST exists, updating…"
    git -C "$DEST" pull --ff-only
else
    echo "→ Cloning POPFile into $DEST…"
    git clone "$REPO" "$DEST"
fi

cd "$DEST"
carton install --deployment
echo "→ Starting POPFile…"
carton exec perl popfile.pl &

echo "→ POPFile is running at http://localhost:8080"
echo "  Stop:   kill \$(cat $DEST/popfile.pid)"
