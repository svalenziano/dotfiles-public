#!/bin/bash

set -euo pipefail

VERSION="15.1.0"
ARCH="amd64"
DEB_NAME="ripgrep_${VERSION}-1_${ARCH}.deb"
URL="https://github.com/BurntSushi/ripgrep/releases/download/${VERSION}/${DEB_NAME}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" -o "${TMP}/${DEB_NAME}"
sudo dpkg -i "${TMP}/${DEB_NAME}"
