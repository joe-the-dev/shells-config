#!/bin/bash
set -euo pipefail

# macOS Settings Restore Script
# IMPORTANT: Review settings before applying and restart affected applications

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🍎 Restoring macOS system settings from $SCRIPT_DIR"
echo "⚠️  WARNING: This will overwrite current system preferences"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Restore cancelled"
    exit 1
fi

# Function to restore defaults
restore_defaults() {
    local domain="$1"
    local filename="$2"
    local backup_dir="$3"

    if [ -f "$backup_dir/$filename" ]; then
        echo "  📊 Restoring $domain settings"
        defaults import "$domain" "$backup_dir/$filename" 2>/dev/null || {
            echo "  ⚠️  Failed to restore $domain settings"
        }
    else
        echo "  ⚠️  Backup file $filename not found"
    fi
}

echo "🖥️  Restoring Display Settings..."
restore_defaults "com.apple.windowserver" "display_preferences.plist" "$SCRIPT_DIR/display"
restore_defaults "com.apple.display.DisplayServices" "display_services.plist" "$SCRIPT_DIR/display"

echo "🖱️  Restoring Dock Settings..."
restore_defaults "com.apple.dock" "dock.plist" "$SCRIPT_DIR/dock"

echo "📁 Restoring Finder Settings..."
restore_defaults "com.apple.finder" "finder.plist" "$SCRIPT_DIR/finder"
restore_defaults "com.apple.sidebarlists" "finder_sidebar.plist" "$SCRIPT_DIR/finder"

echo "⌨️  Restoring Keyboard Settings..."
restore_defaults "com.apple.HIToolbox" "keyboard_layouts.plist" "$SCRIPT_DIR/keyboard"
restore_defaults "com.apple.symbolichotkeys" "symbolic_hotkeys.plist" "$SCRIPT_DIR/keyboard"

echo "🖲️  Restoring Trackpad Settings..."
restore_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "trackpad.plist" "$SCRIPT_DIR/trackpad"
restore_defaults "com.apple.AppleMultitouchTrackpad" "multitouch_trackpad.plist" "$SCRIPT_DIR/trackpad"

echo "🚀 Restoring Mission Control Settings..."
restore_defaults "com.apple.spaces" "mission_control.plist" "$SCRIPT_DIR/mission_control"
restore_defaults "com.apple.exposé" "expose.plist" "$SCRIPT_DIR/mission_control"

echo "🔊 Restoring Audio Settings..."
restore_defaults "com.apple.audio.AudioMIDISetup" "audio_midi.plist" "$SCRIPT_DIR/audio"
restore_defaults "com.apple.audio.SystemSoundServer-macOS" "system_sounds.plist" "$SCRIPT_DIR/audio"

echo "♿ Restoring Accessibility Settings..."
restore_defaults "com.apple.universalaccess" "accessibility.plist" "$SCRIPT_DIR/accessibility"

echo "⚙️  Restoring General System Settings..."
restore_defaults "NSGlobalDomain" "global_domain.plist" "$SCRIPT_DIR/system"
restore_defaults "com.apple.systempreferences" "system_preferences.plist" "$SCRIPT_DIR/system"
restore_defaults "com.apple.menuextra.clock" "menu_clock.plist" "$SCRIPT_DIR/system"
restore_defaults "com.apple.controlcenter" "control_center.plist" "$SCRIPT_DIR/system"

echo "🔄 Restarting affected services..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall ControlCenter 2>/dev/null || true

echo "✅ macOS settings restore complete!"
echo "💡 Some changes may require a restart to take full effect"
echo "🔧 For DisplayLink settings, restart the DisplayLink service or reboot"
