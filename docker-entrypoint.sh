#!/bin/sh
# Docker entrypoint — set default port if no config exists
if [ ! -f /data/popfile.cfg ]; then
    echo "api_port 7070" > /data/popfile.cfg
fi
export POPFILE_USER=/data
exec carton exec perl popfile.pl
