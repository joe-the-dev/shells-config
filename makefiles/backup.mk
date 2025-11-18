# Backup and Restore Makefile
# Handles all backup operations for applications and macOS system settings with feature flag support

.PHONY: backup backup-apps backup-macos backup-sync

# Main backup target - backs up everything based on feature flags
backup:
	@echo "💾 Running feature-based backup..."
	$(call conditional_exec,$(ENABLE_APPS_BACKUP),$(MAKE) -s backup-apps,Application backup)
	$(call conditional_exec,$(ENABLE_MACOS_BACKUP),$(MAKE) -s backup-macos,macOS system backup)
	@echo "✅ Complete backup finished!"

# Backup with git sync
backup-sync: backup
	@echo "🔄 Syncing changes to git..."
	@if ! git rev-parse --git-dir > /dev/null 2>&1; then \
		echo "❌ ERROR: Not in a git repository"; \
		exit 1; \
	fi; \
	CURRENT_BRANCH=$$(git branch --show-current); \
	if [ "$$CURRENT_BRANCH" != "main" ]; then \
		echo "🔀 Switching from $$CURRENT_BRANCH to main branch"; \
		git checkout main || (echo "❌ Failed to switch to main branch"; exit 1); \
	fi; \
	echo "⬇️  Pulling latest changes from origin/main..."; \
	if git pull origin main; then \
		echo "✅ Successfully updated main branch"; \
	else \
		echo "❌ Failed to pull from origin main"; \
		echo "💡 You may need to resolve conflicts manually"; \
		exit 1; \
	fi; \
	echo "📦 Staging all changes..."; \
	git add -A; \
	if git diff --staged --quiet; then \
		echo "ℹ️  No changes to commit"; \
	else \
		COMMIT_MSG="Backup: $$(date '+%Y-%m-%d %H:%M:%S')"; \
		if git commit -m "$$COMMIT_MSG"; then \
			echo "✅ Successfully committed changes"; \
			echo "⬆️  Pushing to origin/main..."; \
			if git push origin main; then \
				echo "✅ Successfully pushed to origin/main"; \
			else \
				echo "❌ Failed to push to origin main"; \
				echo "💡 You may need to push manually later"; \
			fi; \
		else \
			echo "❌ Failed to commit changes"; \
		fi; \
	fi

# Application backup with feature flags
backup-apps:
	@echo "📱 Backing up application configurations..."
	$(call conditional_exec,$(ENABLE_JETBRAINS_BACKUP),$(MAKE) -s _backup-jetbrains,JetBrains IDEs backup)
	$(call conditional_exec,$(ENABLE_ITERM2_BACKUP),$(MAKE) -s _backup-iterm2,iTerm2 backup)
	$(call conditional_exec,$(ENABLE_KARABINER_BACKUP),$(MAKE) -s _backup-karabiner,Karabiner backup)
	$(call conditional_exec,$(ENABLE_HAMMERSPOON_BACKUP),$(MAKE) -s _backup-hammerspoon,Hammerspoon backup)
	@echo "✅ Application backup completed!"

# macOS system settings backup
backup-macos:
	@echo "🍎 Backing up macOS system settings..."
	@if [ "$(SKIP_HEAVY_OPERATIONS)" = "true" ]; then \
		echo "$(YELLOW)⏭️  Skipping macOS backup (heavy operations disabled)$(RESET)"; \
		exit 0; \
	fi
	@$(MAKE) -s _backup-macos-settings
	@echo "✅ macOS system backup completed!"

# Individual backup targets
_backup-jetbrains:
	@echo "🧠 Backing up JetBrains IDEs..."
	@JETBRAINS_DIR="$$HOME/Library/Application Support/JetBrains"; \
	JETBRAINS_BACKUP_DIR="jetbrains-ides"; \
	if [ ! -d "$$JETBRAINS_DIR" ]; then \
		echo "ℹ️  JetBrains directory not found, skipping backup"; \
		exit 0; \
	fi; \
	mkdir -p "$$JETBRAINS_BACKUP_DIR"; \
	for ide_dir in "$$JETBRAINS_DIR"/*/; do \
		if [ -d "$$ide_dir" ]; then \
			IDE_NAME=$$(basename "$$ide_dir"); \
			if [[ "$$IDE_NAME" == .* ]]; then \
				continue; \
			fi; \
			BACKUP_DIR="$$JETBRAINS_BACKUP_DIR/$$IDE_NAME"; \
			echo "📦 Backing up $$IDE_NAME..."; \
			mkdir -p "$$BACKUP_DIR"; \
			for dir in codestyles options keymaps colors templates; do \
				if [ -d "$$ide_dir/$$dir" ]; then \
					cp -R "$$ide_dir/$$dir" "$$BACKUP_DIR/"; \
				fi; \
			done; \
			for file in *.vmoptions disabled_plugins.txt; do \
				if [ -f "$$ide_dir/$$file" ]; then \
					cp "$$ide_dir/$$file" "$$BACKUP_DIR/"; \
				fi; \
			done; \
		fi; \
	done; \
	echo "✅ JetBrains backup completed"

_backup-iterm2:
	@echo "🖥️  Backing up iTerm2..."
	@ITERM2_BACKUP_DIR="iterm2"; \
	mkdir -p "$$ITERM2_BACKUP_DIR"; \
	if [ -f "$$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]; then \
		cp "$$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$$ITERM2_BACKUP_DIR/"; \
	fi; \
	if [ -d "$$HOME/Library/Application Support/iTerm2/DynamicProfiles" ]; then \
		cp -R "$$HOME/Library/Application Support/iTerm2/DynamicProfiles" "$$ITERM2_BACKUP_DIR/"; \
	fi; \
	if [ -d "$$HOME/Library/Application Support/iTerm2/Scripts" ]; then \
		cp -R "$$HOME/Library/Application Support/iTerm2/Scripts" "$$ITERM2_BACKUP_DIR/"; \
	fi; \
	echo "✅ iTerm2 backup completed"

_backup-karabiner:
	@echo "⌨️  Backing up Karabiner..."
	@if [ -d "$$HOME/.config/karabiner" ]; then \
		mkdir -p "karabiner"; \
		cp -R "$$HOME/.config/karabiner"/* "karabiner/" 2>/dev/null || true; \
		echo "✅ Karabiner backup completed"; \
	else \
		echo "ℹ️  No Karabiner config found to backup"; \
	fi

_backup-hammerspoon:
	@echo "🔨 Backing up Hammerspoon..."
	@if [ -d "$$HOME/.hammerspoon" ]; then \
		mkdir -p "hammerspoon"; \
		cp -R "$$HOME/.hammerspoon"/* "hammerspoon/" 2>/dev/null || true; \
		echo "✅ Hammerspoon backup completed"; \
	else \
		echo "ℹ️  No Hammerspoon config found to backup"; \
	fi

_backup-macos-settings:
	@echo "🍎 Backing up macOS system settings..."
	@mkdir -p macos/{display,dock,finder,keyboard,trackpad,mission_control,audio,accessibility,system,network,third_party}
	@echo "📊 Backing up Display settings..."
	@defaults export com.apple.windowserver macos/display/display_preferences.plist 2>/dev/null || echo "  ⚠️  Could not backup display preferences"
	@defaults export com.apple.display.DisplayServices macos/display/display_services.plist 2>/dev/null || echo "  ⚠️  Could not backup display services"
	@echo "🖱️  Backing up Dock settings..."
	@defaults export com.apple.dock macos/dock/dock.plist 2>/dev/null || echo "  ⚠️  Could not backup dock settings"
	@echo "📁 Backing up Finder settings..."
	@defaults export com.apple.finder macos/finder/finder.plist 2>/dev/null || echo "  ⚠️  Could not backup finder settings"
	@defaults export com.apple.sidebarlists macos/finder/finder_sidebar.plist 2>/dev/null || echo "  ⚠️  Could not backup finder sidebar"
	@echo "⌨️  Backing up Keyboard settings..."
	@defaults export com.apple.HIToolbox macos/keyboard/keyboard_layouts.plist 2>/dev/null || echo "  ⚠️  Could not backup keyboard layouts"
	@defaults export com.apple.symbolichotkeys macos/keyboard/symbolic_hotkeys.plist 2>/dev/null || echo "  ⚠️  Could not backup symbolic hotkeys"
	@echo "🖲️  Backing up Trackpad settings..."
	@defaults export com.apple.driver.AppleBluetoothMultitouch.trackpad macos/trackpad/trackpad.plist 2>/dev/null || echo "  ⚠️  Could not backup trackpad settings"
	@defaults export com.apple.AppleMultitouchTrackpad macos/trackpad/multitouch_trackpad.plist 2>/dev/null || echo "  ⚠️  Could not backup multitouch trackpad"
	@echo "🚀 Backing up Mission Control settings..."
	@defaults export com.apple.spaces macos/mission_control/mission_control.plist 2>/dev/null || echo "  ⚠️  Could not backup mission control"
	@defaults export com.apple.exposé macos/mission_control/expose.plist 2>/dev/null || echo "  ⚠️  Could not backup exposé"
	@echo "🔊 Backing up Audio settings..."
	@defaults export com.apple.audio.AudioMIDISetup macos/audio/audio_midi.plist 2>/dev/null || echo "  ⚠️  Could not backup audio MIDI"
	@defaults export com.apple.audio.SystemSoundServer-macOS macos/audio/system_sounds.plist 2>/dev/null || echo "  ⚠️  Could not backup system sounds"
	@echo "♿ Backing up Accessibility settings..."
	@defaults export com.apple.universalaccess macos/accessibility/accessibility.plist 2>/dev/null || echo "  ⚠️  Could not backup accessibility"
	@echo "⚙️  Backing up General System settings..."
	@defaults export NSGlobalDomain macos/system/global_domain.plist 2>/dev/null || echo "  ⚠️  Could not backup global domain"
	@defaults export com.apple.systempreferences macos/system/system_preferences.plist 2>/dev/null || echo "  ⚠️  Could not backup system preferences"
	@defaults export com.apple.menuextra.clock macos/system/menu_clock.plist 2>/dev/null || echo "  ⚠️  Could not backup menu clock"
	@defaults export com.apple.controlcenter macos/system/control_center.plist 2>/dev/null || echo "  ⚠️  Could not backup control center"
	@echo "📝 Creating system info snapshot..."
	@system_profiler SPHardwareDataType SPSoftwareDataType > macos/system_info.txt 2>/dev/null || echo "  ⚠️  Could not create system info"
	@echo "✅ macOS system settings backup completed"
