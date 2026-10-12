#!/bin/bash
# Official releases: https://github.com/AlDanial/cloc/releases
# Install instructions: https://github.com/AlDanial/cloc#install-via-github-releases

set -euo pipefail

# Ensure perl is available (required to run the cloc .pl script)
sudo apt-get install -y perl

# Ensure ~/bin exists
mkdir -p "$HOME/bin"

cd "$(mktemp -d)" || exit 1

# Download the latest cloc Perl script
wget -q "https://github.com/AlDanial/cloc/releases/download/v2.08/cloc-2.08.pl" \
  -O cloc

chmod a+rx cloc
./cloc --version   # verify it runs before installing

mv cloc "$HOME/bin/cloc"

echo "cloc installed: $(cloc --version)"
