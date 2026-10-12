#!/bin/bash
set -euo pipefail

# https://python-poetry.org/docs/#installation
# https://pipx.pypa.io/stable/
pipx install poetry
pipx install httpie
pipx install ruff

# PDM
# https://pdm-project.org/latest/#other-installation-methods
pipx install pdm
pdm completion bash > ~/.bash_completion

echo "Poetry installed: $(poetry --version)"