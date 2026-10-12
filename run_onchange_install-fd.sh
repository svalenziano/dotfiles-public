#!/bin/bash

set -euo pipefail

VERSION="10.4.2"
ARCH="amd64"
DEB_NAME="fd_${VERSION}_${ARCH}.deb"
URL="https://github.com/sharkdp/fd/releases/download/v${VERSION}/${DEB_NAME}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" -o "${TMP}/${DEB_NAME}"
sudo dpkg -i "${TMP}/${DEB_NAME}"
