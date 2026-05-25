#!/bin/bash
# Warm the guix-publish cache by requesting narinfos for all Cuirass-built packages.
# Run as root on the thinkpad after guix-publish is running.
#
# Usage: ./warm-cache.sh

PUBLISH_URL="http://localhost:3000"
CUIRASS_PROFILE="/var/guix/profiles/per-user/cuirass/cuirass"

if ! curl -sf "$PUBLISH_URL/nix-cache-info" > /dev/null 2>&1; then
    echo "guix-publish not responding at $PUBLISH_URL"
    exit 1
fi

for entry in "$CUIRASS_PROFILE"/*; do
    name=$(basename "$entry")
    hash=$(echo "$name" | cut -d- -f1)

    # skip .drv files and source checkouts
    if echo "$name" | grep -qE '\.(drv|tar\.(gz|zst|xz))$|(-checkout|-src|vendored)$'; then
        continue
    fi

    code=$(curl -s -o /dev/null -w "%{http_code}" "$PUBLISH_URL/${hash}.narinfo")
    echo "$code $name"
done
