#!/bin/bash
set -euo pipefail

# Enhanced JetBrains IDE restore script for multiple IDEs
# Supports: IntelliJ IDEA, PyCharm, WebStorm, PhpStorm, CLion, etc.

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
JETBRAINS_DIR="$HOME/Library/Application Support/JetBrains"
JETBRAINS_BACKUP_DIR="$REPO_DIR/jetbrains-ides"

echo "🧠 Enhanced JetBrains IDEs restore starting..."

if [[ ! -d "$JETBRAINS_BACKUP_DIR" ]]; then
    echo "⚠️  No JetBrains backup found at $JETBRAINS_BACKUP_DIR"
    echo "💡 Run ./backup_all_jetbrains.sh first to create a backup"
    exit 0
fi

mkdir -p "$JETBRAINS_DIR"

# Restore each backed up IDE
for backup_dir in "$JETBRAINS_BACKUP_DIR"/*/; do
    if [[ -d "$backup_dir" ]]; then
        IDE_NAME=$(basename "$backup_dir")

        # Skip if it's a file (like .ideavimrc)
        if [[ "$IDE_NAME" == .* ]]; then
            continue
        fi

        TARGET_DIR="$JETBRAINS_DIR/$IDE_NAME"

        echo "🔄 Restoring $IDE_NAME → $TARGET_DIR"
        mkdir -p "$TARGET_DIR"

        # Restore each configuration type
        if [[ -d "$backup_dir/codestyles" ]]; then
            echo "  🎨 Restoring code styles"
            cp -R "$backup_dir/codestyles" "$TARGET_DIR/"
        fi

        if [[ -d "$backup_dir/options" ]]; then
            echo "  ⚙️  Restoring IDE options"
            cp -R "$backup_dir/options" "$TARGET_DIR/"
        fi

        if [[ -d "$backup_dir/keymaps" ]]; then
            echo "  ⌨️  Restoring custom keymaps"
            cp -R "$backup_dir/keymaps" "$TARGET_DIR/"
        fi

        if [[ -d "$backup_dir/colors" ]]; then
            echo "  🌈 Restoring color schemes"
            cp -R "$backup_dir/colors" "$TARGET_DIR/"
        fi

        if [[ -d "$backup_dir/templates" ]]; then
            echo "  📝 Restoring file templates"
            cp -R "$backup_dir/templates" "$TARGET_DIR/"
        fi

        if [[ -f "$backup_dir/disabled_plugins.txt" ]]; then
            echo "  🚫 Restoring disabled plugins list"
            cp "$backup_dir/disabled_plugins.txt" "$TARGET_DIR/"
        fi

        # Restore VM options files
        for vm_file in "$backup_dir"/*.vmoptions; do
            if [[ -f "$vm_file" ]]; then
                echo "  🚀 Restoring VM options: $(basename "$vm_file")"
                cp "$vm_file" "$TARGET_DIR/"
            fi
        done

        if [[ -f "$backup_dir/plugins_list.txt" ]]; then
            echo "  🔌 Plugin list available for $IDE_NAME"
            echo "    💡 Manually reinstall plugins from: $backup_dir/plugins_list.txt"
        fi

        echo "  ✅ $IDE_NAME restoration complete"
    fi
done

# Restore shared configurations
if [[ -f "$JETBRAINS_BACKUP_DIR/.ideavimrc" ]]; then
    echo "⌨️  Restoring shared .ideavimrc"
    cp "$JETBRAINS_BACKUP_DIR/.ideavimrc" "$HOME/"
fi

if [[ -f "$JETBRAINS_BACKUP_DIR/idea.vmoptions" ]]; then
    echo "🚀 Restoring global VM options"
    cp "$JETBRAINS_BACKUP_DIR/idea.vmoptions" "$JETBRAINS_DIR/"
fi

echo "✅ Enhanced JetBrains IDEs restore complete!"
echo ""
echo "📋 Manual steps required:"
echo "1. Launch each IDE and reinstall plugins from the plugins_list.txt files"
echo "2. Restart IDEs to ensure all configurations are loaded"
echo "3. Verify your settings in each IDE's preferences"
