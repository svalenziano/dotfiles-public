#!/bin/bash

set -euo pipefail

sudo apt update

sudo apt install -y \
    pdfgrep \
  qpdf \
  poppler-utils \
  libmbedtls-dev \
  ffmpeg \
  imagemagick \
  ghostscript \


echo "APT packages installed successfully"