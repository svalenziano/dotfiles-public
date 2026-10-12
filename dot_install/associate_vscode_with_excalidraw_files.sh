#!/usr/bin/env bash

# PURPOSE: associate vscode with .excalidraw.png and .excalidraw.svg files
# without breaking default .svg and .png associations

# ASSUMUMPTIONS: you installed the .deb VSCode not the `snap`


# NOTES:
# - may need to increase glob weight to 60?  Test first before resorting to this.

set -euo pipefail

MIME_PKG_DIR="$HOME/.local/share/mime/packages"
MIME_FILE="$MIME_PKG_DIR/excalidraw.xml"
DESKTOP_FILE="code.desktop"

mkdir -p "$MIME_PKG_DIR"

cat > "$MIME_FILE" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
  <mime-type type="image/x-excalidraw-png">
    <comment>Excalidraw PNG</comment>
    <sub-class-of type="image/png"/>
    <glob pattern="*.excalidraw.png" weight="60"/>
  </mime-type>
  <mime-type type="image/x-excalidraw-svg">
    <comment>Excalidraw SVG</comment>
    <sub-class-of type="image/svg+xml"/>
    <glob pattern="*.excalidraw.svg" weight="60"/>
  </mime-type>
</mime-info>
EOF

update-mime-database "$HOME/.local/share/mime"

xdg-mime default "$DESKTOP_FILE" image/x-excalidraw-png
xdg-mime default "$DESKTOP_FILE" image/x-excalidraw-svg

echo "Done. VSCode is now the default opener for *.excalidraw.png and *.excalidraw.svg"
