#!/bin/bash

set -euo pipefail

VERSION="1.8.1"
BINARY="jq-linux-amd64"
URL="https://github.com/jqlang/jq/releases/download/jq-${VERSION}/${BINARY}"

sudo curl -fsSL "$URL" -o /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq

echo "jq installed: $(jq --version)"