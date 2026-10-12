#!/usr/bin/env bash
set -euo pipefail

# Override with: OBSIDIAN_SOURCE_VAULT=/path/to/vault obsidian-setup.sh
SOURCE="${OBSIDIAN_SOURCE_VAULT:-$HOME/Documents/obsidian/vault}/.obsidian"
DEST="$PWD/.obsidian"

if [ ! -d "$SOURCE" ]; then
    echo "Error: source not found: $SOURCE" >&2
    exit 1
fi

if [ -d "$DEST" ]; then
    echo "Warning: .obsidian already exists in $PWD"
    read -rp "Overwrite? [y/N] " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
fi

echo "$SOURCE -> $DEST"
rsync -a --delete \
    --exclude="workspace.json" \
    --exclude="workspaces.json" \
    --exclude="bookmarks.json" \
    --exclude="templates.json" \
    --exclude="daily-notes.json" \
    --exclude="periodic-notes.json" \
    --exclude="*.sync-conflict-*.json" \
    --exclude="plugins/calendar/" \
    --exclude="plugins/code-styler/" \
    --exclude="plugins/copy-document-as-html/" \
    --exclude="plugins/dataview/" \
    --exclude="plugins/maps/" \
    --exclude="plugins/obsidian-bulk-rename-plugin/" \
    --exclude="plugins/obsidian-copy-block-link/" \
    --exclude="plugins/obsidian-file-cooker/" \
    --exclude="plugins/obsidian-git/" \
    --exclude="plugins/obsidian-map-view/" \
    --exclude="plugins/obsidian-minimal-settings/" \
    --exclude="plugins/obsidian-pandoc/" \
    --exclude="plugins/omnisearch/" \
    --exclude="plugins/periodic-notes/" \
    --exclude="plugins/solve/" \
    --exclude="plugins/templater-obsidian/" \
    "$SOURCE/" "$DEST/"
echo "Done."
