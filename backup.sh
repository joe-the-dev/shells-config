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
TOOLS=("fish" "nvim" "omf" "karabiner" "hammerspoon" "asdf" "bash" "zsh" "gitconfig" "brew" "intellij" "iterm2" "env")

for tool in "${TOOLS[@]}"; do
  case "$tool" in
    hammerspoon)
      src="$HOME/.hammerspoon"
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      mkdir -p "$dst"
      if [ -d "$src" ]; then
        rsync -a "$src"/ "$dst"/
      fi
      continue
      ;;
    fish|nvim|omf|karabiner)
      src="$HOME/.config/$tool"
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      mkdir -p "$dst"
      if [ -d "$src" ]; then
        rsync -a "$src"/ "$dst"/
      fi
      continue
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
    bash)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"
      # Copy bash config files from home directory
      if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$dst/"
      fi
      if [ -f "$HOME/.bash_profile" ]; then
        cp "$HOME/.bash_profile" "$dst/"
      fi
      if [ -f "$HOME/.profile" ]; then
        cp "$HOME/.profile" "$dst/"
      fi
      continue
      ;;
    zsh)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"
      # Copy zsh config files from home directory
      if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$dst/"
      fi
      if [ -f "$HOME/.zprofile" ]; then
        cp "$HOME/.zprofile" "$dst/"
      fi
      if [ -f "$HOME/.zshenv" ]; then
        cp "$HOME/.zshenv" "$dst/"
      fi
      continue
      ;;
    gitconfig)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"
      # Copy gitconfig file from home directory
      if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$dst/"
      fi
      # Copy global gitignore file from home directory
      if [ -f "$HOME/.gitignore_global" ]; then
        cp "$HOME/.gitignore_global" "$dst/"
      fi
      continue
      ;;
    brew)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"
      # Generate Brewfile with all installed packages, casks, and taps
      if command -v brew >/dev/null 2>&1; then
        echo "📋 Generating Brewfile with all installed packages"
        brew bundle dump --file="$dst/Brewfile" --force
        echo "✅ Brewfile generated with $(grep -c '^brew\|^cask\|^tap\|^mas' "$dst/Brewfile") entries"
      else
        echo "⚠️  Homebrew not found, skipping brew backup"
        echo "# Homebrew not installed" > "$dst/Brewfile"
      fi
      continue
      ;;
    intellij)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      mkdir -p "$dst"
      # Find the latest IntelliJ IDEA version directory
      INTELLIJ_DIR=$(find "$HOME/Library/Application Support/JetBrains" -name "IntelliJIdea*" -type d | sort -V | tail -1)

      if [ -n "$INTELLIJ_DIR" ] && [ -d "$INTELLIJ_DIR" ]; then
        echo "📋 Found IntelliJ config at: $INTELLIJ_DIR"

        # Backup essential configuration files
        if [ -d "$INTELLIJ_DIR/codestyles" ]; then
          rsync -a "$INTELLIJ_DIR/codestyles/" "$dst/codestyles/"
        fi
        if [ -d "$INTELLIJ_DIR/options" ]; then
          rsync -a "$INTELLIJ_DIR/options/" "$dst/options/"
        fi
        # Backup plugin list (lightweight, just names)
        if [ -d "$INTELLIJ_DIR/plugins" ]; then
          ls "$INTELLIJ_DIR/plugins" > "$dst/plugins_list.txt"
        fi
        if [ -f "$INTELLIJ_DIR/idea.vmoptions" ]; then
          cp "$INTELLIJ_DIR/idea.vmoptions" "$dst/"
        fi
        if [ -f "$INTELLIJ_DIR/disabled_plugins.txt" ]; then
          cp "$INTELLIJ_DIR/disabled_plugins.txt" "$dst/"
        fi
        # Create a version file to track which IntelliJ version this came from
        basename "$INTELLIJ_DIR" > "$dst/intellij_version.txt"
      else
        echo "⚠️  IntelliJ IDEA config directory not found"
      fi

      # Backup .ideavimrc from home directory
      if [ -f "$HOME/.ideavimrc" ]; then
        echo "⌨️  Backing up .ideavimrc"
        cp "$HOME/.ideavimrc" "$dst/"
      fi
      continue
      ;;
    iterm2)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"

      # Backup iTerm2 main preferences (profiles, colors, key bindings, etc.)
      if [ -f "$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]; then
        echo "📋 Backing up iTerm2 preferences"
        cp "$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$dst/"
      fi

      # Backup iTerm2 Application Support files
      ITERM2_APP_SUPPORT="$HOME/Library/Application Support/iTerm2"
      if [ -d "$ITERM2_APP_SUPPORT" ]; then
        # Backup Dynamic Profiles (if any)
        if [ -d "$ITERM2_APP_SUPPORT/DynamicProfiles" ]; then
          cp -R "$ITERM2_APP_SUPPORT/DynamicProfiles" "$dst/"
        fi

        # Backup Scripts (if any)
        if [ -d "$ITERM2_APP_SUPPORT/Scripts" ]; then
          cp -R "$ITERM2_APP_SUPPORT/Scripts" "$dst/"
        fi

        # Backup version info
        if [ -f "$ITERM2_APP_SUPPORT/version.txt" ]; then
          cp "$ITERM2_APP_SUPPORT/version.txt" "$dst/"
        fi
      fi

      # Export current iTerm2 profile as JSON for easier version control
      echo "📋 Exporting iTerm2 profiles as JSON"
      /usr/libexec/PlistBuddy -x -c "Print" "$HOME/Library/Preferences/com.googlecode.iterm2.plist" > "$dst/iterm2_preferences.xml" 2>/dev/null || echo "# Could not export preferences" > "$dst/iterm2_preferences.xml"

      continue
      ;;
    env)
      dst="$REPO_DIR/$tool"
      echo "🔄 Backing up $tool config files → $dst"
      rm -rf "$dst"
      mkdir -p "$dst"

      # Backup .env files from multiple locations
      if [ -f "$HOME/.env" ]; then
        echo "📋 Backing up .env from home directory"
        cp "$HOME/.env" "$dst/home.env"
      fi

      # Create a template .env file for documentation
      cat > "$dst/template.env" << 'EOF'
# Environment Variables Template
# Copy this to ~/.env or $SHELL_BACKUP_DIR/.env and customize

# Example variables:
# OPENAI_API_KEY=your_api_key_here
# AWS_PROFILE=your_default_profile
# GITHUB_TOKEN=your_github_token
# NODE_ENV=development
EOF

      # Create a README for the env directory
      cat > "$dst/README.md" << 'EOF'
# Environment Variables

This directory contains environment variable configurations.

## Files:
- `template.env`: Template with example variables
- `home.env`: Backup of ~/.env (if exists)

## Usage:
1. Copy `template.env` to `~/.env` or `$SHELL_BACKUP_DIR/.env`
2. Customize with your actual values
3. The Fish shell will automatically load these variables on startup

## Security Note:
- Never commit actual API keys or secrets
- Use placeholder values in templates
- Consider using a password manager for sensitive values
EOF

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

  # Update main branch first
  echo "📥 Updating main branch from remote..."

  # Check current branch
  CURRENT_BRANCH=$(git branch --show-current)

  # If not on main, switch to main
  if [[ "$CURRENT_BRANCH" != "main" ]]; then
    echo "🔀 Switching from $CURRENT_BRANCH to main branch"
    git checkout main || {
      echo "❌ Failed to switch to main branch"
      exit 1
    }
  fi

  # Pull latest changes
  echo "⬇️  Pulling latest changes from origin/main..."
  if git pull origin main; then
    echo "✅ Successfully updated main branch"
  else
    echo "❌ Failed to pull from origin main"
    echo "💡 You may need to resolve conflicts manually"
    exit 1
  fi

  # Check for changes after pull
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
