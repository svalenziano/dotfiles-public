#!/usr/bin/env bash
#
# disable-middle-click-paste.sh
#
# Disables X11 "primary selection" paste on middle-click (the paste that fires
# when you middle-drag to pan in Figma/Excalidraw/etc. and then release).
# This is separate from the normal Ctrl+C / Ctrl+V clipboard, which is untouched.
# Middle-click panning/scrolling keeps working — only the auto-paste is disabled.
#
# What it changes:
#   1. GTK apps (incl. Google Chrome, Electron apps, native GTK apps):
#        ~/.config/gtk-3.0/settings.ini  ->  gtk-enable-primary-paste=false
#        ~/.config/gtk-4.0/settings.ini  ->  gtk-enable-primary-paste=false
#   2. Firefox:
#        <profile>/user.js  ->  user_pref("middlemouse.paste", false);
#
# Usage:
#   ./setup/disable-middle-click-paste.sh
#
# Notes:
#   - Idempotent: safe to re-run; it won't duplicate settings.
#   - Restart Chrome and Firefox afterwards for changes to take effect.
#   - Targets the snap Firefox path by default. For a non-snap install,
#     set FF_BASE="$HOME/.mozilla/firefox" (or export it before running).
#   - Tested on Ubuntu GNOME / X11. The GTK lever also applies under Wayland.
#   - Verify Firefox afterwards at about:config -> middlemouse.paste == false.
#
set -euo pipefail

# 1. Disable middle-click primary-selection paste for GTK apps (incl. Chrome)
mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0
for d in gtk-3.0 gtk-4.0; do
  f="$HOME/.config/$d/settings.ini"
  if ! grep -q '^gtk-enable-primary-paste=' "$f" 2>/dev/null; then
    # ensure a [Settings] section exists, then add the key
    grep -q '^\[Settings\]' "$f" 2>/dev/null || printf '[Settings]\n' >> "$f"
    printf 'gtk-enable-primary-paste=false\n' >> "$f"
    echo "GTK: updated $f"
  else
    echo "GTK: already set in $f"
  fi
done

# 2. Disable middle-click paste in Firefox via user.js
#    Auto-detect the default profile from profiles.ini.
FF_BASE="${FF_BASE:-$HOME/snap/firefox/common/.mozilla/firefox}"  # non-snap: ~/.mozilla/firefox
if [ -f "$FF_BASE/profiles.ini" ]; then
  PROFILE_DIR=$(awk -F= '/^Path=/{p=$2} /^Default=1/{print p}' "$FF_BASE/profiles.ini" | head -1)
  PROFILE="$FF_BASE/$PROFILE_DIR"
  if [ -d "$PROFILE" ]; then
    if ! grep -q 'middlemouse.paste' "$PROFILE/user.js" 2>/dev/null; then
      printf '// Disable middle-click primary-selection paste\nuser_pref("middlemouse.paste", false);\n' >> "$PROFILE/user.js"
      echo "Firefox: updated $PROFILE/user.js"
    else
      echo "Firefox: already set in $PROFILE/user.js"
    fi
  else
    echo "Firefox: default profile dir not found ($PROFILE) — skipping"
  fi
else
  echo "Firefox: $FF_BASE/profiles.ini not found — skipping (set FF_BASE if installed elsewhere)"
fi

echo "Done. Restart Chrome and Firefox to apply."
