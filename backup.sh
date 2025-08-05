#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
FISH_SRC="$HOME/.config/fish"
NVIM_SRC="$HOME/.config/nvim"

FISH_DST="$REPO_DIR/fish"
NVIM_DST="$REPO_DIR/nvim"

echo "🔄 Backing up Fish config..."
rm -rf "$FISH_DST"
mkdir -p "$FISH_DST"
cp -R "$FISH_SRC/" "$FISH_DST/"

echo "🔄 Backing up Neovim config..."
rm -rf "$NVIM_DST"
mkdir -p "$NVIM_DST"
cp -R "$NVIM_SRC/" "$NVIM_DST/"

echo "✅ Backup complete!"
OMF_SRC="$HOME/.config/omf"
OMF_DST="$REPO_DIR/omf"
rm -rf "$OMF_DST"
mkdir -p "$OMF_DST"
cp -R "$OMF_SRC/" "$OMF_DST/"
