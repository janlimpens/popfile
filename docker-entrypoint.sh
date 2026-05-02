#!/bin/sh
# Docker entrypoint — set defaults if no config exists
POPFILE_USER="${POPFILE_USER:-/data}"
POPFILE_ROOT="${POPFILE_ROOT:-/app}"
mkdir -p "$POPFILE_USER/messages"
if [ ! -f "$POPFILE_USER/popfile.cfg" ]; then
    {
        echo "api_port 7070"
        echo "api_local ${POPFILE_LOCAL:-0}"
        [ -n "${POPFILE_PASSWORD:-}" ] && echo "api_password $POPFILE_PASSWORD"
        echo "bayes_database popfile.db"
        echo "GLOBAL_msgdir $POPFILE_USER/messages/"
        echo "config_piddir $POPFILE_USER/"
    } > "$POPFILE_USER/popfile.cfg"
fi
export POPFILE_USER POPFILE_ROOT
echo "POPFile data directory: $POPFILE_USER (mount a volume here to persist)"
echo "POPFile UI: http://<host>:7070/"
cd "$POPFILE_ROOT"
exec carton exec perl script/popfile start
