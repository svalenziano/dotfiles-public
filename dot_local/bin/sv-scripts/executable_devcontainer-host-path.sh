#!/usr/bin/env bash
# Find the host filesystem path backing a running devcontainer's workspace mount,
# and (optionally) use `fd` to locate a file within it.
#
# Usage:
#   ./find-devcontainer-host-path.sh                  # list devcontainers + their host paths
#   ./find-devcontainer-host-path.sh <container-name>  # show host path for one container
#   ./find-devcontainer-host-path.sh <container-name> <fd-pattern>  # also search for a file

set -euo pipefail

CONTAINER="${1:-}"
PATTERN="${2:-}"

# devcontainers are tagged with image names starting "vsc-" by default
list_devcontainers() {
    docker ps --filter "label=devcontainer.local_folder" \
        --format '{{.Names}}\t{{.Image}}' 2>/dev/null \
    || docker ps --format '{{.Names}}\t{{.Image}}' | grep -E '^\S+\tvsc-'
}

get_host_path() {
    local name="$1"
    # Prefer the devcontainer.local_folder label if present (most reliable)
    local labeled
    labeled=$(docker inspect "$name" --format '{{ index .Config.Labels "devcontainer.local_folder" }}' 2>/dev/null || true)
    if [[ -n "$labeled" ]]; then
        echo "$labeled"
        return
    fi

    # Fall back to inspecting mounts for the /workspaces destination
    docker inspect "$name" --format '{{ json .Mounts }}' \
        | python3 -c "
import json, sys
mounts = json.load(sys.stdin)
for m in mounts:
    if m.get('Destination', '').startswith('/workspaces'):
        print(m.get('Source', ''))
        break
"
}

if [[ -z "$CONTAINER" ]]; then
    echo "Running devcontainers:"
    echo "-----------------------"
    list_devcontainers | while IFS=$'\t' read -r name image; do
        host_path=$(get_host_path "$name" || echo "(unknown)")
        printf '%-30s %s\n' "$name" "$host_path"
    done
    exit 0
fi

HOST_PATH=$(get_host_path "$CONTAINER")

if [[ -z "$HOST_PATH" ]]; then
    echo "Could not determine host path for container '$CONTAINER'" >&2
    exit 1
fi

echo "Host path: $HOST_PATH"

if [[ -n "$PATTERN" ]]; then
    echo "Searching for '$PATTERN' under $HOST_PATH ..."
    fd "$PATTERN" "$HOST_PATH"
fi
