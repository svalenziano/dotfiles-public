#!/bin/bash
# Official install docs: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

set -euo pipefail

# Ensure wget is available
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y))

# Set up the GitHub CLI apt repository
sudo mkdir -p -m 755 /etc/apt/keyrings
out=$(mktemp)
trap 'rm -f "$out"' EXIT   # cleanup, even if script fails
wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg
sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg < "$out" > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install gh
sudo apt update
sudo apt install gh -y


echo "GitHub CLI installed: $(gh --version | head -1)"
