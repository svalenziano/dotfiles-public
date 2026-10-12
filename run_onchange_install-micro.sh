#!/bin/bash

# Worked for SV in March 2026
set -euo pipefail

VERSION="2.0.15"
TARBALL="micro-${VERSION}-linux64.tar.gz"
URL="https://github.com/zyedidia/micro/releases/download/v${VERSION}/${TARBALL}"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "$URL" -o "${TMP}/${TARBALL}"
tar -xz -f "${TMP}/${TARBALL}" -C "${TMP}"
sudo mv "${TMP}/micro-${VERSION}/micro" /usr/local/bin/micro

echo "micro installed: $(micro --version)"
