#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
INTELLIJ_CONFIG_DIR="$REPO_DIR/intellij"

echo "🧠 Installing IntelliJ IDEA configuration..."

if [ ! -d "$INTELLIJ_CONFIG_DIR" ]; then
    echo "⚠️  No IntelliJ config found at $INTELLIJ_CONFIG_DIR"
    exit 0
fi

# Find or create the latest IntelliJ IDEA config directory
INTELLIJ_VERSIONS_DIR="$HOME/Library/Application Support/JetBrains"
mkdir -p "$INTELLIJ_VERSIONS_DIR"

# Check if we have a version file to know which version to restore to
if [ -f "$INTELLIJ_CONFIG_DIR/intellij_version.txt" ]; then
    INTELLIJ_VERSION=$(cat "$INTELLIJ_CONFIG_DIR/intellij_version.txt")
    INTELLIJ_DIR="$INTELLIJ_VERSIONS_DIR/$INTELLIJ_VERSION"
    echo "📋 Restoring to specific version: $INTELLIJ_VERSION"
else
    # Find the latest installed version or create a default one
    INTELLIJ_DIR=$(find "$INTELLIJ_VERSIONS_DIR" -name "IntelliJIdea*" -type d | sort -V | tail -1)
    if [ -z "$INTELLIJ_DIR" ]; then
        # Default to current version if no existing installation found
        INTELLIJ_DIR="$INTELLIJ_VERSIONS_DIR/IntelliJIdea2025.2"
        echo "📋 Creating new config directory: IntelliJIdea2025.2"
    else
        echo "📋 Using existing IntelliJ directory: $(basename "$INTELLIJ_DIR")"
    fi
fi

# Create the IntelliJ config directory if it doesn't exist
mkdir -p "$INTELLIJ_DIR"

# Restore configuration files
if [ -d "$INTELLIJ_CONFIG_DIR/codestyles" ]; then
    echo "🎨 Restoring code styles (including 2-space indentation)..."
    cp -R "$INTELLIJ_CONFIG_DIR/codestyles" "$INTELLIJ_DIR/"
fi

if [ -d "$INTELLIJ_CONFIG_DIR/options" ]; then
    echo "⚙️  Restoring IDE options..."
    cp -R "$INTELLIJ_CONFIG_DIR/options" "$INTELLIJ_DIR/"
fi

if [ -f "$INTELLIJ_CONFIG_DIR/idea.vmoptions" ]; then
    echo "🚀 Restoring JVM options..."
    cp "$INTELLIJ_CONFIG_DIR/idea.vmoptions" "$INTELLIJ_DIR/"
fi

if [ -f "$INTELLIJ_CONFIG_DIR/disabled_plugins.txt" ]; then
    echo "🔌 Restoring disabled plugins list..."
    cp "$INTELLIJ_CONFIG_DIR/disabled_plugins.txt" "$INTELLIJ_DIR/"
fi

# Restore plugins from plugins_list.txt (print instructions for user)
if [ -f "$INTELLIJ_CONFIG_DIR/plugins_list.txt" ]; then
    echo "🔌 The following plugins were previously installed (from plugins_list.txt):"
    cat "$INTELLIJ_CONFIG_DIR/plugins_list.txt"
    echo "💡 Please reinstall these plugins manually from the JetBrains Marketplace, or use the JetBrains Toolbox for automation."
fi

# Restore .ideavimrc to home directory
if [ -f "$INTELLIJ_CONFIG_DIR/.ideavimrc" ]; then
    echo "⌨️  Restoring .ideavimrc to home directory..."
    cp "$INTELLIJ_CONFIG_DIR/.ideavimrc" "$HOME/"
fi

echo "✅ IntelliJ IDEA configuration restored successfully!"
echo "💡 Your 2-space indentation settings and other preferences should now be active."
echo "💡 You may need to restart IntelliJ IDEA for all changes to take effect."
