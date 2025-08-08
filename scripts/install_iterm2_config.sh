#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
ITERM2_CONFIG_DIR="$REPO_DIR/iterm2"

echo "🖥️  Installing iTerm2 configuration..."

if [ ! -d "$ITERM2_CONFIG_DIR" ]; then
    echo "⚠️  No iTerm2 config found at $ITERM2_CONFIG_DIR"
    exit 0
fi

# Restore iTerm2 main preferences
if [ -f "$ITERM2_CONFIG_DIR/com.googlecode.iterm2.plist" ]; then
    echo "📋 Restoring iTerm2 preferences..."
    # Close iTerm2 if running to avoid conflicts
    if pgrep -x "iTerm2" > /dev/null; then
        echo "⚠️  iTerm2 is currently running. Please close it and run this script again."
        echo "💡 This ensures preferences are restored correctly."
        exit 1
    fi

    cp "$ITERM2_CONFIG_DIR/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/"
fi

# Create Application Support directory if it doesn't exist
ITERM2_APP_SUPPORT="$HOME/Library/Application Support/iTerm2"
mkdir -p "$ITERM2_APP_SUPPORT"

# Restore Dynamic Profiles
if [ -d "$ITERM2_CONFIG_DIR/DynamicProfiles" ]; then
    echo "🎨 Restoring Dynamic Profiles..."
    cp -R "$ITERM2_CONFIG_DIR/DynamicProfiles" "$ITERM2_APP_SUPPORT/"
fi

# Restore Scripts
if [ -d "$ITERM2_CONFIG_DIR/Scripts" ]; then
    echo "📜 Restoring iTerm2 Scripts..."
    cp -R "$ITERM2_CONFIG_DIR/Scripts" "$ITERM2_APP_SUPPORT/"
fi

# Restore version info
if [ -f "$ITERM2_CONFIG_DIR/version.txt" ]; then
    cp "$ITERM2_CONFIG_DIR/version.txt" "$ITERM2_APP_SUPPORT/"
fi

echo "✅ iTerm2 configuration restored successfully!"
echo "💡 Your terminal profiles, colors, and settings should now be active."
echo "💡 Please restart iTerm2 for all changes to take effect."
exit 0