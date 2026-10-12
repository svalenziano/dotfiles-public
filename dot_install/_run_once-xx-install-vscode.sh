#!/bin/bash
set -euo pipefail

# https://code.visualstudio.com/docs/setup/linux
# Manual prerequisite: download the .deb from https://code.visualstudio.com/Download
# and place it at the path below before running.

TEMP_PATH="$HOME/Downloads/code_1.115.0-1775600353_amd64.deb"

sudo apt install "$TEMP_PATH"

echo "Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
" | sudo tee /etc/apt/sources.list.d/vscode.sources > /dev/null

sudo apt install apt-transport-https &&
  sudo apt update &&
  sudo apt install code
