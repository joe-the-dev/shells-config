#!/usr/bin/env bash
set -e

# List of destination and source pairs
FILES=(
  ".config/omf" "omf"
  ".config/karabiner" "karabiner"
  ".hammerspoon" "hammerspoon"
  ".Brewfile" "brew/Brewfile"
  ".asdfrc" "asdf/.asdfrc"
  ".tool-versions" "asdf/.tool-versions"
  ".bashrc" "bash/.bashrc"
  ".zshrc" "zsh/.zshrc"
  ".gitconfig" "gitconfig/.gitconfig"
  ".gitignore_global" "gitconfig/.gitignore_global"
)

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

for ((i=0; i<${#FILES[@]}; i+=2)); do
  DEST_REL="${FILES[i]}"
  SRC_REL="${FILES[i+1]}"
  SRC="$REPO_DIR/$SRC_REL"
  DEST="$HOME/$DEST_REL"
  if [ -e "$SRC" ]; then
    echo "Copying $SRC to $DEST"
    rm -rf "$DEST"
    mkdir -p "$(dirname "$DEST")"
    cp -a "$SRC" "$DEST"
  else
    echo "Warning: $SRC does not exist, skipping."
  fi
done

echo "All files copied."
