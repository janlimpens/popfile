#!/bin/sh
# Docker entrypoint — set defaults if no config exists
POPFILE_USER="${POPFILE_USER:-/data}"
POPFILE_ROOT="${POPFILE_ROOT:-/app}"
mkdir -p "$POPFILE_USER/messages"
if [ ! -f "$POPFILE_USER/config.json" ] && [ ! -f "$POPFILE_USER/popfile.cfg" ]; then
    cat > "$POPFILE_USER/config.json" <<EOF
{
  "version": 2,
  "api": {
    "port": 7070,
    "local": ${POPFILE_LOCAL:-0}
  },
  "bayes": {
    "database": "popfile.db"
  },
  "GLOBAL": {
    "msgdir": "$POPFILE_USER/messages/"
  },
  "config": {
    "piddir": "$POPFILE_USER/"
  }
}
EOF
    if [ -n "${POPFILE_PASSWORD:-}" ]; then
        # Inject password into the JSON
        tmp="$(mktemp)"
        perl -MCpanel::JSON::XS -e '
            use Cpanel::JSON::XS;
            my $json = Cpanel::JSON::XS->new->utf8->pretty->canonical;
            open my $fh, "<", "$ARGV[0]" or die;
            local $/;
            my $data = $json->decode(<$fh>);
            close $fh;
            $data->{api}{password} = $ARGV[1];
            open $fh, ">", "$ARGV[0]" or die;
            print $fh $json->encode($data);
            close $fh;
        ' "$tmp" "$POPFILE_PASSWORD"
        mv "$tmp" "$POPFILE_USER/config.json"
        unlink "$tmp" 2>/dev/null || true
    fi
fi
export POPFILE_USER POPFILE_ROOT
echo "POPFile data directory: $POPFILE_USER (mount a volume here to persist)"
echo "POPFile UI: http://<host>:7070/"
cd "$POPFILE_ROOT"
exec carton exec perl script/popfile start
