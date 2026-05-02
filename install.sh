#!/bin/sh
set -e

echo "POPFile installer"
echo "================="

# ── try Docker ──
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "→ Docker found."
    if docker ps -a --format '{{.Names}}' | grep -qx popfile; then
        echo "→ Existing container found, updating…"
        docker stop popfile 2>/dev/null
        docker rm popfile 2>/dev/null
    fi
    ARCH="$(uname -m)"
    PLATFORM_FLAG=""
    case "$ARCH" in
        aarch64|arm*)
            PLATFORM_FLAG="--platform linux/amd64"
            echo "→ ARM host ($ARCH), using amd64 emulation."
            ;;
    esac
    docker pull $PLATFORM_FLAG ghcr.io/janlimpens/popfile:latest
    docker run -d --name popfile --restart unless-stopped \
        -p 7070:7070 -v popfile-data:/data \
        $PLATFORM_FLAG ghcr.io/janlimpens/popfile:latest
    echo "→ POPFile is running at http://localhost:7070"
    echo "  On a headless server, replace 'localhost' with the server's IP."
    echo ""
    printf "Set a UI password? (leave empty to skip) " > /dev/tty
    read -r password < /dev/tty
    if [ -n "$password" ]; then
        printf 'api_password=%s\napi_local=0\n' "$password" | docker exec -i popfile popfile config --stdin 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "→ Password set, external access enabled."
        else
            echo "→ To set a password, run:"
            echo "  docker stop popfile && docker rm popfile && docker run -d --name popfile --restart unless-stopped -p 7070:7070 -v popfile-data:/data -e POPFILE_PASSWORD=$password ghcr.io/janlimpens/popfile:latest"
        fi
    fi
    echo "  Data:   stored in Docker volume 'popfile-data'"
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
POPFILE_ROOT=. POPFILE_USER=. carton exec perl script/popfile start &

echo "→ POPFile is running — check the console output for the port."
echo "  UI:     http://localhost:<port>/ (see output above)"
echo "  Data:   $DEST (your config, database, and messages are here)"
echo "  Stop:   ~/.popfile/bin/popfile stop"
echo "  Logs:   ~/.popfile/bin/popfile logs"

# ── offer systemd ──
if command -v systemctl >/dev/null 2>&1; then
    echo ""
    printf "Install POPFile as a background service (systemd)? [y/N] "
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        SERVICE_FILE="$DEST/popfile.service"
        cat > "$SERVICE_FILE" << SERVICEOF
[Unit]
Description=POPFile email classifier
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$DEST/bin/popfile start
ExecStop=$DEST/bin/popfile stop
Restart=on-failure
User=$USER
WorkingDirectory=$DEST

[Install]
WantedBy=default.target
SERVICEOF
        mkdir -p "$HOME/.config/systemd/user"
        ln -sf "$SERVICE_FILE" "$HOME/.config/systemd/user/popfile.service"
        systemctl --user daemon-reload
        systemctl --user enable --now popfile
        echo "→ POPFile service installed and started."
        echo "  Stop:   systemctl --user stop popfile"
        echo "  Logs:   journalctl --user -u popfile -f"
    fi
fi
