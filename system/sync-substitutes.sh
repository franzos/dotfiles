#!/bin/bash
# Build a static file layout from the guix-publish cache,
# then rsync to the remote substitute server.
#
# guix-publish cache:       /var/cache/publish/zstd/<hash>-<name>.{narinfo,nar}
# Clients expect:           /<hash>.narinfo  and  /nar/zstd/<hash>-<name>
#
# Usage: ./sync-substitutes.sh [--dry-run]

set -euo pipefail

CACHE="/var/cache/publish/zstd"
STATIC="/var/cache/publish/serve"
REMOTE="virt1"
DRY_RUN=""

if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN="--dry-run"
fi

if [ ! -d "$CACHE" ]; then
    echo "Cache not found at $CACHE"
    exit 1
fi

mkdir -p "$STATIC/nar/zstd"

# Copy signing key and nix-cache-info
if [ -f /etc/guix/signing-key.pub ]; then
    cp -u /etc/guix/signing-key.pub "$STATIC/signing-key.pub"
fi

if [ ! -f "$STATIC/nix-cache-info" ]; then
    cat > "$STATIC/nix-cache-info" << 'EOF'
StoreDir: /gnu/store
WantMassQuery: 1
Priority: 100
EOF
fi

# Convert cache layout to static-serving layout using hard links
for narinfo in "$CACHE"/*.narinfo; do
    [ -f "$narinfo" ] || continue
    name=$(basename "$narinfo" .narinfo)
    hash=$(echo "$name" | cut -d- -f1)

    # <hash>.narinfo at root
    ln -f "$narinfo" "$STATIC/${hash}.narinfo" 2>/dev/null || cp -u "$narinfo" "$STATIC/${hash}.narinfo"

    # nar/zstd/<hash>-<name> (no .nar extension)
    nar="$CACHE/${name}.nar"
    if [ -f "$nar" ]; then
        ln -f "$nar" "$STATIC/nar/zstd/${name}" 2>/dev/null || cp -u "$nar" "$STATIC/nar/zstd/${name}"
    fi
done

# Clean up stale entries (narinfos in static that no longer exist in cache)
for narinfo in "$STATIC"/*.narinfo; do
    [ -f "$narinfo" ] || continue
    hash=$(basename "$narinfo" .narinfo)
    if ! ls "$CACHE"/${hash}-*.narinfo &>/dev/null; then
        rm -f "$narinfo"
        # Find and remove corresponding nar
        for nar in "$STATIC/nar/zstd/${hash}-"*; do
            [ -f "$nar" ] && rm -f "$nar"
        done
    fi
done

echo "Static layout: $(ls "$STATIC"/*.narinfo 2>/dev/null | wc -l) narinfos"
echo "Nars: $(ls "$STATIC/nar/zstd/" 2>/dev/null | wc -l) files"
du -sh "$STATIC"

# Sync to remote
rsync -az --delete $DRY_RUN "$STATIC/" "$REMOTE:/srv/substitutes/"
