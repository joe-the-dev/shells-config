#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# 🛡️ Sanity check
if [[ -z "$REPO_DIR" || "$REPO_DIR" == "/" ]]; then
  echo "❌ ERROR: Invalid REPO_DIR: $REPO_DIR"
  exit 1
fi

# Check for --sync flag
SYNC_TO_GIT=false
if [[ "${1:-}" == "--sync" ]]; then
  SYNC_TO_GIT=true
  echo "🔄 Sync mode enabled - will commit and push changes to git"
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

# Git sync functionality
if [[ "$SYNC_TO_GIT" == true ]]; then
  echo ""
  echo "🔄 Syncing changes to git..."

  cd "$REPO_DIR"

  # Check if we're in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
  fi

  # Check for changes
  if git diff --quiet && git diff --cached --quiet; then
    echo "ℹ️  No changes detected, nothing to commit"
    exit 0
  fi

  # Show what will be committed
  echo "📋 Changes to be committed:"
  git status --porcelain

  # Add all changes
  echo "➕ Adding all changes..."
  git add .

  # Create commit with timestamp
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  COMMIT_MESSAGE="Backup configs - $TIMESTAMP"

  echo "💾 Committing changes: $COMMIT_MESSAGE"
  git commit -m "$COMMIT_MESSAGE"

  # Push to origin main
  echo "🚀 Pushing to origin main..."
  if git push origin main; then
    echo "✅ Successfully synced to git!"
  else
    echo "❌ Failed to push to origin main"
    echo "💡 You may need to pull changes first: git pull origin main"
    exit 1
  fi
fi
