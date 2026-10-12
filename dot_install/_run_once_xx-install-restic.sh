#!/bin/bash
# Official releases: https://github.com/restic/restic/releases
# Install instructions: https://restic.readthedocs.io/en/stable/020_installation.html#official-binaries

set -euo pipefail

VER=0.18.1

# bzip2 is needed to decompress the release artifact
sudo apt-get install -y bzip2

mkdir -p "$HOME/bin"

cd "$(mktemp -d)" || exit 1

wget -q "https://github.com/restic/restic/releases/download/v${VER}/restic_${VER}_linux_amd64.bz2" \
  -O restic.bz2

bunzip2 restic.bz2
chmod a+rx restic
./restic version   # verify it runs before installing

mv restic "$HOME/bin/restic"

echo "restic installed: $(restic version)"
echo "Update in the future with: restic self-update"
