#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# 🛡️ Sanity check
if [[ -z "$REPO_DIR" || "$REPO_DIR" == "/" ]]; then
  echo "❌ ERROR: Invalid REPO_DIR: $REPO_DIR"
  exit 1
fi

echo "📦 Backing up config files into $REPO_DIR"

# Define each config you want to back up
TOOLS=("fish" "nvim" "omf" "karabiner" "hammerspoon" "asdf")

for tool in "${TOOLS[@]}"; do
  case "$tool" in
    hammerspoon)
      src="$HOME/.hammerspoon"
      ;;
    asdf)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"
      # Copy asdf config files individually since they're in home directory
      if [ -f "$HOME/.asdfrc" ]; then
        cp "$HOME/.asdfrc" "$dst/"
      fi
      if [ -f "$HOME/.tool-versions" ]; then
        cp "$HOME/.tool-versions" "$dst/"
      fi
      # Backup plugin list
      echo "📋 Backing up asdf plugin list"
      asdf plugin list > "$dst/plugins.txt" 2>/dev/null || echo "# No plugins installed yet" > "$dst/plugins.txt"
      continue
      ;;
    *)
      src="$HOME/.config/$tool"
      ;;
  esac

  dst="$REPO_DIR/$tool"

  if [ ! -d "$src" ]; then
    echo "⚠️  Skipping $tool (not found at $src)"
    continue
  fi

  echo "🔄 Backing up $tool from $src → $dst"
  rm -rf "$dst"
  mkdir -p "$dst"
  cp -R "$src/" "$dst/"
done

echo "✅ All configs backed up successfully."
