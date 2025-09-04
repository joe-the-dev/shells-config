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
TOOLS=(
  "fish"
  "nvim"
  "omf"
  "karabiner"
  "hammerspoon"
  "asdf"
  "bash"
  "zsh"
  "gitconfig"
  "brew"
  "jetbrains"
  "iterm2"
  "env"
)

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
        if [ "$tool" = "karabiner" ]; then
          # For Karabiner, exclude automatic backup files to keep only the current config
          echo "  ⌨️  Excluding automatic backup files"
          rsync -a --exclude="automatic_backups/karabiner_*.json" "$src"/ "$dst"/
          # Keep only the 2 most recent backup files if any exist
          if [ -d "$src/automatic_backups" ] && [ -n "$(ls "$src/automatic_backups"/karabiner_*.json 2>/dev/null)" ]; then
            echo "  📋 Keeping 2 most recent Karabiner backups"
            mkdir -p "$dst/automatic_backups"
            ls -1t "$src/automatic_backups"/karabiner_*.json 2>/dev/null | head -2 | xargs -I {} cp {} "$dst/automatic_backups/"
          fi
        else
          rsync -a "$src"/ "$dst"/
        fi
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
    jetbrains)
      JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"

      echo "🧠 Enhanced JetBrains IDEs backup starting..."

      if [[ ! -d "$JETBRAINS_DIR" ]]; then
          echo "⚠️  No JetBrains directory found at $JETBRAINS_DIR"
          continue
      fi

      # Find all JetBrains IDE directories
      IDE_DIRS=$(find "$JETBRAINS_DIR" -maxdepth 1 -type d -name "*Idea*" -o -name "*PyCharm*" -o -name "*WebStorm*" -o -name "*PhpStorm*" -o -name "*CLion*" -o -name "*GoLand*" -o -name "*RubyMine*" -o -name "*DataGrip*" -o -name "*Rider*" | sort)

      if [[ -z "$IDE_DIRS" ]]; then
          echo "⚠️  No JetBrains IDE configurations found"
          continue
      fi

      # Create jetbrains-ides directory in your config repo
      JETBRAINS_BACKUP_DIR="$REPO_DIR/jetbrains-ides"
      mkdir -p "$JETBRAINS_BACKUP_DIR"

      echo "📋 Found JetBrains IDEs to backup:"
      echo "$IDE_DIRS" | while read -r ide_dir; do
          echo "  - $(basename "$ide_dir")"
      done

      # Define patterns for files to exclude from backup
      EXCLUDE_PATTERNS=(
          "--exclude=recentProjects.xml"
          "--exclude=window.*.xml"
          "--exclude=actionSummary.xml"
          "--exclude=contributorSummary.xml"
          "--exclude=features.usage.statistics.xml"
          "--exclude=dailyLocalStatistics.xml"
          "--exclude=log-categories.xml"
          "--exclude=EventLog*.xml"
          "--exclude=DontShowAgain*.xml"
          "--exclude=CommonFeedback*.xml"
          "--exclude=AIOnboarding*.xml"
          "--exclude=McpToolsStore*.xml"
          "--exclude=usage.statistics.xml"
          "--exclude=statistics.xml"
          "--exclude=event-log-whitelist.xml"
      )

      # Backup each IDE
      echo "$IDE_DIRS" | while read -r ide_dir; do
          if [[ -d "$ide_dir" ]]; then
              IDE_NAME=$(basename "$ide_dir")
              BACKUP_DIR="$JETBRAINS_BACKUP_DIR/$IDE_NAME"

              echo "🔄 Backing up $IDE_NAME → $BACKUP_DIR"
              mkdir -p "$BACKUP_DIR"

              # Backup essential configuration files
              if [[ -d "$ide_dir/codestyles" ]]; then
                  echo "  🎨 Backing up code styles"
                  rsync -a "$ide_dir/codestyles/" "$BACKUP_DIR/codestyles/"
              fi

              if [[ -d "$ide_dir/options" ]]; then
                  echo "  ⚙️  Backing up IDE options (excluding cache files)"
                  rsync -a "${EXCLUDE_PATTERNS[@]}" "$ide_dir/options/" "$BACKUP_DIR/options/"
              fi

              if [[ -d "$ide_dir/keymaps" ]]; then
                  echo "  ⌨️  Backing up custom keymaps"
                  rsync -a "$ide_dir/keymaps/" "$BACKUP_DIR/keymaps/"
              fi

              if [[ -d "$ide_dir/colors" ]]; then
                  echo "  🌈 Backing up color schemes"
                  rsync -a "$ide_dir/colors/" "$BACKUP_DIR/colors/"
              fi

              if [[ -d "$ide_dir/templates" ]]; then
                  echo "  📝 Backing up file templates"
                  rsync -a "$ide_dir/templates/" "$BACKUP_DIR/templates/"
              fi

              if [[ -d "$ide_dir/plugins" ]]; then
                  echo "  🔌 Backing up plugin list"
                  ls "$ide_dir/plugins" > "$BACKUP_DIR/plugins_list.txt"
              fi

              if [[ -f "$ide_dir/disabled_plugins.txt" ]]; then
                  echo "  🚫 Backing up disabled plugins"
                  cp "$ide_dir/disabled_plugins.txt" "$BACKUP_DIR/"
              fi

              # Look for VM options files
              for vm_file in "$ide_dir"/*.vmoptions; do
                  if [[ -f "$vm_file" ]]; then
                      echo "  🚀 Backing up VM options: $(basename "$vm_file")"
                      cp "$vm_file" "$BACKUP_DIR/"
                  fi
              done

              # Create metadata file
              echo "$(date '+%Y-%m-%d %H:%M:%S')" > "$BACKUP_DIR/backup_date.txt"
              echo "$IDE_NAME" > "$BACKUP_DIR/ide_version.txt"

              echo "  ✅ $IDE_NAME backup complete"
          fi
      done

      # Backup shared configurations
      echo "🔄 Backing up shared JetBrains configurations..."

      # IdeaVim configuration (shared across all JetBrains IDEs)
      if [[ -f "$HOME/.ideavimrc" ]]; then
          echo "  ⌨️  Backing up .ideavimrc"
          cp "$HOME/.ideavimrc" "$JETBRAINS_BACKUP_DIR/"
      fi

      # Global VM options (if exists)
      if [[ -f "$HOME/Library/Application Support/JetBrains/idea.vmoptions" ]]; then
          echo "  🚀 Backing up global VM options"
          cp "$HOME/Library/Application Support/JetBrains/idea.vmoptions" "$JETBRAINS_BACKUP_DIR/"
      fi

      echo "✅ Enhanced JetBrains IDEs backup complete!"
      echo "📁 Backup location: $JETBRAINS_BACKUP_DIR"
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
