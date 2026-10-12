#!/bin/bash

set -euo pipefail

VERSION="3.9.0.1"
ARCH="amd64"
DEB_NAME="pandoc-${VERSION}-1-${ARCH}.deb"
URL="https://github.com/jgm/pandoc/releases/download/${VERSION}/${DEB_NAME}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" -o "${TMP}/${DEB_NAME}"
sudo dpkg -i "${TMP}/${DEB_NAME}"

echo "pandoc installed: $(pandoc --version | head -1)"