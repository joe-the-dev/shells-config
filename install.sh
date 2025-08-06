#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${DOTFILES_DIR}"

# Update repository if it's already a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "📥 Updating repository from remote..."

  # Check current branch
  CURRENT_BRANCH=$(git branch --show-current)

  # If not on main, switch to main
  if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "🔀 Switching from $CURRENT_BRANCH to main branch"
    git checkout main || {
      echo "❌ Failed to switch to main branch"
      echo "💡 Continuing with current branch: $CURRENT_BRANCH"
    }
  fi

  # Pull latest changes
  echo "⬇️  Pulling latest changes from origin/main..."
  if git pull origin main; then
    echo "✅ Repository updated successfully"
  else
    echo "⚠️  Failed to pull from origin main, continuing with local version"
    echo "💡 You may want to resolve this manually later"
  fi
else
  echo "ℹ️  Not a git repository, skipping update"
fi

git submodule update --init --recursive

"${DOTFILES_DIR}/dotbot/bin/dotbot" -d "${DOTFILES_DIR}" -c install.conf.yaml
