#!/bin/bash
# Official install docs: https://github.com/nvm-sh/nvm


set -euo pipefail

VERSION="v0.40.4"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$VERSION/install.sh | bash

# Source nvm so it's available in this script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install latest LTS Node
nvm install --lts

echo "nvm installed: $(nvm --version)"
echo "Node.js installed: $(node --version)"
