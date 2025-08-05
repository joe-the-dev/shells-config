#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${DOTFILES_DIR}"
git submodule update --init --recursive

"${DOTFILES_DIR}/dotbot/bin/dotbot" -d "${DOTFILES_DIR}" -c install.conf.yaml
