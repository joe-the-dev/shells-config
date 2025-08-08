#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
FISH_CONFIG_DIR="$REPO_DIR/fish"

echo "🐟 Installing OMF (Oh My Fish) configuration..."

# Check if Fish shell is installed
if ! command -v fish >/dev/null 2>&1; then
    echo "⚠️  Fish shell not found. Please install Fish first."
    exit 0
fi

# Check if OMF config exists in backup
if [ ! -d "$FISH_CONFIG_DIR/omf" ]; then
    echo "⚠️  No OMF config found at $FISH_CONFIG_DIR/omf"
    exit 0
fi

# Install OMF if not already installed
if ! fish -c "type omf" >/dev/null 2>&1; then
    echo "📦 Installing Oh My Fish..."
    fish -c "curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish"
    echo "✅ OMF installed"
else
    echo "✅ OMF already installed"
fi

# Restore OMF configuration files
OMF_CONFIG_DIR="$HOME/.config/omf"
mkdir -p "$OMF_CONFIG_DIR"

echo "🔄 Restoring OMF configuration..."

# Restore OMF config files
for omf_file in bundle channel theme; do
    if [ -f "$FISH_CONFIG_DIR/omf/$omf_file" ]; then
        echo "📋 Restoring $omf_file"
        cp "$FISH_CONFIG_DIR/omf/$omf_file" "$OMF_CONFIG_DIR/"
    fi
done

# Install packages from bundle if it exists
if [ -f "$FISH_CONFIG_DIR/omf/bundle" ]; then
    echo "📦 Installing OMF packages from bundle..."

    # Read each package from bundle and install
    while IFS= read -r package || [ -n "$package" ]; do
        # Skip empty lines and comments
        [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue

        echo "🔌 Installing OMF package: $package"
        fish -c "omf install $package" || echo "⚠️  Failed to install $package"
    done < "$FISH_CONFIG_DIR/omf/bundle"
fi

# Set theme if specified
if [ -f "$FISH_CONFIG_DIR/omf/theme" ]; then
    theme=$(cat "$FISH_CONFIG_DIR/omf/theme")
    if [ -n "$theme" ] && [ "$theme" != "default" ]; then
        echo "🎨 Setting OMF theme: $theme"
        fish -c "omf theme $theme" || echo "⚠️  Failed to set theme $theme"
    fi
fi

echo "✅ OMF configuration restored successfully!"
echo "💡 Your OMF packages and theme should now be active."
echo "💡 If you see any issues, try running: omf reload"
