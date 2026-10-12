#!/bin/bash

set -euo pipefail

sudo apt update

sudo apt install -y \
  python3-pip \
  tree \
  copyq \
  pipx \
  btop \
  xclip \
  rmlint \
  arp-scan \
  nmap \
  net-tools \
  inotify-tools \
  whois \
  build-essential \
  git \
  git-lfs \
  curl \
  wget \
  make \
  autoconf \
  patch \
  python3-dev \
  meld \
  postgresql \
  postgresql-contrib \
  libssl-dev \
  libffi-dev \
  libgdbm-dev \
  libncurses5-dev \
  zlib1g-dev \
  libpq-dev \
  uuid-dev \
  tk-dev \
  fonts-noto-color-emoji \
  fonts-freefont-ttf \
  fonts-liberation

pipx ensurepath

echo "APT packages installed successfully"

# These packages were on my list, but may be Claude halucinations?
#   lm-sensors \
#   python3-venv \
#   pipx \