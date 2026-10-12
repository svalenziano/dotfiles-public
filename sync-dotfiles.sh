#!/usr/bin/env bash
set -euo pipefail

DOTFILES_SOURCE=~/.local/share/chezmoi
DEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# abort if there an uncommitted files in the git repo
if [[ -n "$(git -C "$DOTFILES_SOURCE" status --porcelain)" ]]; then
  echo "Error: $DOTFILES_SOURCE has uncommitted changes. Commit or stash them first." >&2
  git -C "$DOTFILES_SOURCE" status --short >&2
  exit 1
fi

# use rsync to clone the dir to `.`, excluding the .git dir
rsync -av --delete --exclude='.git/' "$DOTFILES_SOURCE/" "$DEST_DIR/"
