#!/bin/bash
set -euo pipefail

# Enhanced JetBrains IDE backup script for multiple IDEs
# Supports: IntelliJ IDEA, PyCharm, WebStorm, PhpStorm, CLion, etc.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"

echo "🧠 Enhanced JetBrains IDEs backup starting..."

if [[ ! -d "$JETBRAINS_DIR" ]]; then
    echo "⚠️  No JetBrains directory found at $JETBRAINS_DIR"
    exit 0
fi

# Find all JetBrains IDE directories
IDE_DIRS=$(find "$JETBRAINS_DIR" -maxdepth 1 -type d -name "*Idea*" -o -name "*PyCharm*" -o -name "*WebStorm*" -o -name "*PhpStorm*" -o -name "*CLion*" -o -name "*GoLand*" -o -name "*RubyMine*" -o -name "*DataGrip*" -o -name "*Rider*" | sort)

if [[ -z "$IDE_DIRS" ]]; then
    echo "⚠️  No JetBrains IDE configurations found"
    exit 0
fi

# Create jetbrains-ides directory in your config repo
JETBRAINS_BACKUP_DIR="$REPO_DIR/jetbrains-ides"
mkdir -p "$JETBRAINS_BACKUP_DIR"

echo "📋 Found JetBrains IDEs to backup:"
echo "$IDE_DIRS" | while read -r ide_dir; do
    echo "  - $(basename "$ide_dir")"
done

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
            echo "  ⚙️  Backing up IDE options"
            rsync -a "$ide_dir/options/" "$BACKUP_DIR/options/"
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
