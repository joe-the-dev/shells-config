# Backup and Restore Makefile
# Handles all backup operations for applications and macOS system settings

.PHONY: backup backup-apps backup-macos backup-sync

# Main backup target - backs up everything
backup:
	@echo "💾 Running complete backup (apps + macOS)..."
	@$(MAKE) -s backup-apps
	@$(MAKE) -s backup-macos
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
	if git diff --quiet && git diff --cached --quiet; then \
		echo "ℹ️  No changes detected, nothing to commit"; \
		exit 0; \
	fi; \
	echo "📋 Changes to be committed:"; \
	git status --porcelain; \
	echo "➕ Adding all changes..."; \
	git add .; \
	TIMESTAMP=$$(date "+%Y-%m-%d %H:%M:%S"); \
	COMMIT_MESSAGE="Backup configs - $$TIMESTAMP"; \
	echo "💾 Committing changes: $$COMMIT_MESSAGE"; \
	git commit -m "$$COMMIT_MESSAGE"; \
	echo "🚀 Pushing to origin main..."; \
	if git push origin main; then \
		echo "✅ Successfully synced to git!"; \
	else \
		echo "❌ Failed to push to origin main"; \
		echo "💡 You may need to pull changes first: git pull origin main"; \
		exit 1; \
	fi

# Backup application configurations only
backup-apps:
	@echo "📱 Running application configurations backup..."
	@echo "📦 Backing up config files with parallel execution..."
	@rm -f .parallel_pids .parallel_log.tmp
	@echo "🚀 Starting: Fish shell config"; \
	$(MAKE) -s _backup-fish & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Neovim config"; \
	$(MAKE) -s _backup-nvim & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Oh My Fish config"; \
	$(MAKE) -s _backup-omf & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Karabiner config"; \
	$(MAKE) -s _backup-karabiner & \
	echo $$! >> .parallel_pids
	@if [ -f .parallel_pids ]; then \
		echo "⏳ Waiting for batch 1 to complete..."; \
		while read -r PID; do \
			if [ -n "$$PID" ]; then \
				wait $$PID 2>/dev/null || true; \
			fi; \
		done < .parallel_pids; \
		rm -f .parallel_pids; \
		echo "✅ Batch 1 completed!"; \
	fi
	@echo "🚀 Starting: Hammerspoon config"; \
	$(MAKE) -s _backup-hammerspoon & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: ASDF config"; \
	$(MAKE) -s _backup-asdf & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Bash config"; \
	$(MAKE) -s _backup-bash & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Zsh config"; \
	$(MAKE) -s _backup-zsh & \
	echo $$! >> .parallel_pids
	@if [ -f .parallel_pids ]; then \
		echo "⏳ Waiting for batch 2 to complete..."; \
		while read -r PID; do \
			if [ -n "$$PID" ]; then \
				wait $$PID 2>/dev/null || true; \
			fi; \
		done < .parallel_pids; \
		rm -f .parallel_pids; \
		echo "✅ Batch 2 completed!"; \
	fi
	@echo "🚀 Starting: Git config"; \
	$(MAKE) -s _backup-gitconfig & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Homebrew config"; \
	$(MAKE) -s _backup-brew & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: iTerm2 config"; \
	$(MAKE) -s _backup-iterm2 & \
	echo $$! >> .parallel_pids
	@echo "🚀 Starting: Environment config"; \
	$(MAKE) -s _backup-env & \
	echo $$! >> .parallel_pids
	@if [ -f .parallel_pids ]; then \
		echo "⏳ Waiting for batch 3 to complete..."; \
		while read -r PID; do \
			if [ -n "$$PID" ]; then \
				wait $$PID 2>/dev/null || true; \
			fi; \
		done < .parallel_pids; \
		rm -f .parallel_pids; \
		echo "✅ Batch 3 completed!"; \
	fi
	@$(MAKE) -s _backup-jetbrains
	@if [ -f .parallel_log.tmp ]; then \
		echo "📋 Parallel execution results:"; \
		sort .parallel_log.tmp; \
		rm -f .parallel_log.tmp; \
	fi
	@echo "✅ All application configs backed up successfully!"

# Enhanced backup targets with progress reporting
_backup-fish:
	@echo "[1/13] 🐟 Backing up fish config files → fish/" >> .parallel_log.tmp
	@src="$$HOME/.config/fish"; \
	dst="fish"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		rsync -a "$$src"/ "$$dst"/; \
		echo "✅ Fish config backed up successfully" >> .parallel_log.tmp; \
	else \
		echo "ℹ️  No fish config found" >> .parallel_log.tmp; \
	fi

_backup-nvim:
	@echo "[2/13] 📝 Backing up nvim config files → nvim/" >> .parallel_log.tmp
	@src="$$HOME/.config/nvim"; \
	dst="nvim"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		rsync -a "$$src"/ "$$dst"/; \
		echo "✅ Neovim config backed up successfully" >> .parallel_log.tmp; \
	else \
		echo "ℹ️  No neovim config found" >> .parallel_log.tmp; \
	fi

_backup-omf:
	@echo "[3/13] 🐟 Backing up omf config files → omf/" >> .parallel_log.tmp
	@src="$$HOME/.config/omf"; \
	dst="omf"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		echo "  🐟 Backing up OMF with proper bundle format"; \
		rsync -a "$$src"/ "$$dst"/; \
		if [ -f "$$dst/bundle" ]; then \
			echo "  📦 Cleaning up bundle file format"; \
			sed -E 's/^package[[:space:]]+//; /^theme[[:space:]]/d' "$$dst/bundle" > "$$dst/bundle.tmp"; \
			mv "$$dst/bundle.tmp" "$$dst/bundle"; \
		fi; \
		if [ -f "$$dst/theme" ]; then \
			echo "  🎨 Cleaning up theme file format"; \
			sed -E 's/^theme[[:space:]]+//' "$$dst/theme" > "$$dst/theme.tmp"; \
			mv "$$dst/theme.tmp" "$$dst/theme"; \
		fi; \
		echo "✅ Oh My Fish config backed up successfully" >> .parallel_log.tmp; \
	else \
		echo "ℹ️  No Oh My Fish config found" >> .parallel_log.tmp; \
	fi

_backup-karabiner:
	@echo "[4/13] ⌨️  Backing up karabiner config files → karabiner/" >> .parallel_log.tmp
	@src="$$HOME/.config/karabiner"; \
	dst="karabiner"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		echo "  ⌨️  Excluding automatic backup files"; \
		rsync -a --exclude="automatic_backups/karabiner_*.json" "$$src"/ "$$dst"/; \
		if [ -d "$$src/automatic_backups" ] && [ -n "$$(ls "$$src/automatic_backups"/karabiner_*.json 2>/dev/null)" ]; then \
			echo "  📋 Keeping 2 most recent Karabiner backups"; \
			mkdir -p "$$dst/automatic_backups"; \
			ls -1t "$$src/automatic_backups"/karabiner_*.json 2>/dev/null | head -2 | xargs -I {} cp {} "$$dst/automatic_backups/"; \
		fi; \
		echo "✅ Karabiner config backed up successfully" >> .parallel_log.tmp; \
	else \
		echo "ℹ️  No Karabiner config found" >> .parallel_log.tmp; \
	fi

_backup-hammerspoon:
	@echo "[5/13] 🔄 Backing up hammerspoon config files → hammerspoon/" >> .parallel_log.tmp
	@src="$$HOME/.hammerspoon"; \
	dst="hammerspoon"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		rsync -a "$$src"/ "$$dst"/; \
		echo "✅ Hammerspoon config backed up successfully" >> .parallel_log.tmp; \
	else \
		echo "ℹ️  No Hammerspoon config found" >> .parallel_log.tmp; \
	fi

_backup-asdf:
	@echo "[6/13] 🔄 Backing up asdf config files → asdf/" >> .parallel_log.tmp
	@dst="asdf"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -f "$$HOME/.asdfrc" ]; then \
		cp "$$HOME/.asdfrc" "$$dst/"; \
	fi; \
	if [ -f "$$HOME/.tool-versions" ]; then \
		cp "$$HOME/.tool-versions" "$$dst/"; \
	fi; \
	echo "📋 Backing up asdf plugin list"; \
	asdf plugin list > "$$dst/plugins.txt" 2>/dev/null || echo "# No plugins installed yet" > "$$dst/plugins.txt"; \
	echo "✅ ASDF config backed up successfully" >> .parallel_log.tmp

_backup-bash:
	@echo "[7/13] 🔄 Backing up bash config files → bash/" >> .parallel_log.tmp
	@dst="bash"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -f "$$HOME/.bashrc" ]; then \
		cp "$$HOME/.bashrc" "$$dst/"; \
	fi; \
	if [ -f "$$HOME/.bash_profile" ]; then \
		cp "$$HOME/.bash_profile" "$$dst/"; \
	fi; \
	if [ -f "$$HOME/.profile" ]; then \
		cp "$$HOME/.profile" "$$dst/"; \
	fi; \
	echo "✅ Bash config backed up successfully" >> .parallel_log.tmp

_backup-zsh:
	@echo "[8/13] 🔄 Backing up zsh config files → zsh/" >> .parallel_log.tmp
	@dst="zsh"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -f "$$HOME/.zshrc" ]; then \
		cp "$$HOME/.zshrc" "$$dst/"; \
	fi; \
	if [ -f "$$HOME/.zprofile" ]; then \
		cp "$$HOME/.zprofile" "$$dst/"; \
	fi; \
	if [ -f "$$HOME/.zshenv" ]; then \
		cp "$$HOME/.zshenv" "$$dst/"; \
	fi; \
	echo "✅ Zsh config backed up successfully" >> .parallel_log.tmp

_backup-gitconfig:
	@echo "[9/13] 🔄 Backing up gitconfig config files → gitconfig/" >> .parallel_log.tmp
	@dst="gitconfig"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -f "$$HOME/.gitconfig" ]; then \
		cp "$$HOME/.gitconfig" "$$dst/"; \
	fi; \
	if [ -f "$$HOME/.gitignore_global" ]; then \
		cp "$$HOME/.gitignore_global" "$$dst/"; \
	fi; \
	echo "✅ Git config backed up successfully" >> .parallel_log.tmp

_backup-brew:
	@echo "[10/13] 🔄 Backing up brew config files → brew/" >> .parallel_log.tmp
	@dst="brew"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if command -v brew >/dev/null 2>&1; then \
		echo "📋 Generating Brewfile with all installed packages"; \
		brew bundle dump --file="$$dst/Brewfile" --force; \
		echo "✅ Brewfile generated with $$(grep -c '^brew\|^cask\|^tap\|^mas' "$$dst/Brewfile") entries"; \
	else \
		echo "⚠️  Homebrew not found, skipping brew backup"; \
		echo "# Homebrew not installed" > "$$dst/Brewfile"; \
	fi

_backup-iterm2:
	@echo "[11/13] 🖥️  Backing up iterm2 config files → iterm2/" >> .parallel_log.tmp
	@dst="iterm2"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -f "$$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]; then \
		echo "📋 Backing up iTerm2 preferences"; \
		cp "$$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$$dst/"; \
	fi; \
	ITERM2_APP_SUPPORT="$$HOME/Library/Application Support/iTerm2"; \
	if [ -d "$$ITERM2_APP_SUPPORT" ]; then \
		if [ -d "$$ITERM2_APP_SUPPORT/DynamicProfiles" ]; then \
			cp -R "$$ITERM2_APP_SUPPORT/DynamicProfiles" "$$dst/"; \
		fi; \
		if [ -d "$$ITERM2_APP_SUPPORT/Scripts" ]; then \
			cp -R "$$ITERM2_APP_SUPPORT/Scripts" "$$dst/"; \
		fi; \
		if [ -f "$$ITERM2_APP_SUPPORT/version.txt" ]; then \
			cp "$$ITERM2_APP_SUPPORT/version.txt" "$$dst/"; \
		fi; \
	fi; \
	echo "📋 Exporting iTerm2 profiles as JSON"; \
	/usr/libexec/PlistBuddy -x -c "Print" "$$HOME/Library/Preferences/com.googlecode.iterm2.plist" > "$$dst/iterm2_preferences.xml" 2>/dev/null || echo "# Could not export preferences" > "$$dst/iterm2_preferences.xml"; \
	echo "✅ iTerm2 config backed up successfully" >> .parallel_log.tmp

_backup-env:
	@echo "[12/13] 🌍 Backing up env config files → env/" >> .parallel_log.tmp
	@dst="env"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -f "$$HOME/.env" ]; then \
		echo "📋 Backing up .env from home directory"; \
		cp "$$HOME/.env" "$$dst/home.env"; \
	fi; \
	echo "# Environment Variables Template" > "$$dst/template.env"; \
	echo "# Copy this to ~/.env and customize" >> "$$dst/template.env"; \
	echo "" >> "$$dst/template.env"; \
	echo "# Example variables:" >> "$$dst/template.env"; \
	echo "# OPENAI_API_KEY=your_api_key_here" >> "$$dst/template.env"; \
	echo "# AWS_PROFILE=your_default_profile" >> "$$dst/template.env"; \
	echo "# GITHUB_TOKEN=your_github_token" >> "$$dst/template.env"; \
	echo "# NODE_ENV=development" >> "$$dst/template.env"; \
	echo "✅ Environment config backed up successfully" >> .parallel_log.tmp

_backup-jetbrains:
	@echo "[13/13] 🧠 Enhanced JetBrains IDEs backup starting..."
	@JETBRAINS_DIR="$$HOME/Library/Application Support/JetBrains"; \
	if [ ! -d "$$JETBRAINS_DIR" ]; then \
		echo "⚠️  No JetBrains directory found at $$JETBRAINS_DIR"; \
		exit 0; \
	fi; \
	echo "🔍 Finding JetBrains IDE directories and selecting latest versions..."; \
	JETBRAINS_BACKUP_DIR="jetbrains-ides"; \
	mkdir -p "$$JETBRAINS_BACKUP_DIR"; \
	LATEST_IDES=""; \
	for ide_base in DataGrip IntelliJIdea PyCharm WebStorm PhpStorm CLion GoLand RubyMine Rider; do \
		IDE_DIRS_FOR_BASE=$$(find "$$JETBRAINS_DIR" -maxdepth 1 -type d -name "$${ide_base}*" | sort -V); \
		if [ -n "$$IDE_DIRS_FOR_BASE" ]; then \
			LATEST_IDE=$$(echo "$$IDE_DIRS_FOR_BASE" | tail -1); \
			LATEST_IDES="$$LATEST_IDES$$LATEST_IDE"$$'\n'; \
			echo "  📂 Found $$(echo "$$IDE_DIRS_FOR_BASE" | wc -l | tr -d ' ') versions of $$ide_base, selecting latest: $$(basename "$$LATEST_IDE")"; \
		fi; \
	done; \
	if [ -z "$$LATEST_IDES" ]; then \
		echo "⚠️  No JetBrains IDE configurations found"; \
		exit 0; \
	fi; \
	echo "📋 Selected JetBrains IDEs to backup (latest versions only):"; \
	echo "$$LATEST_IDES" | while read -r ide_dir; do \
		if [ -n "$$ide_dir" ]; then \
			echo "  - $$(basename "$$ide_dir")"; \
		fi; \
	done; \
	echo "$$LATEST_IDES" | while read -r ide_dir; do \
		if [ -d "$$ide_dir" ]; then \
			IDE_NAME=$$(basename "$$ide_dir"); \
			BACKUP_DIR="$$JETBRAINS_BACKUP_DIR/$$IDE_NAME"; \
			echo "🔄 Backing up $$IDE_NAME → $$BACKUP_DIR"; \
			mkdir -p "$$BACKUP_DIR"; \
			if [ -d "$$ide_dir/codestyles" ]; then \
				echo "  🎨 Backing up code styles"; \
				rsync -a "$$ide_dir/codestyles/" "$$BACKUP_DIR/codestyles/"; \
			fi; \
			if [ -d "$$ide_dir/options" ]; then \
				echo "  ⚙️  Backing up IDE options (excluding cache files)"; \
				rsync -a \
					--exclude="recentProjects.xml" \
					--exclude="window.*.xml" \
					--exclude="actionSummary.xml" \
					--exclude="contributorSummary.xml" \
					--exclude="features.usage.statistics.xml" \
					--exclude="dailyLocalStatistics.xml" \
					--exclude="log-categories.xml" \
					--exclude="EventLog*.xml" \
					--exclude="DontShowAgain*.xml" \
					--exclude="CommonFeedback*.xml" \
					--exclude="AIOnboarding*.xml" \
					--exclude="McpToolsStore*.xml" \
					--exclude="usage.statistics.xml" \
					--exclude="statistics.xml" \
					--exclude="event-log-whitelist.xml" \
					--exclude="vim_settings_local.xml" \
					--exclude="ConversationToolStoreService.xml" \
					--exclude="trusted-paths.xml" \
					--exclude="github.xml" \
					--exclude="vcs-inputs.xml" \
					--exclude="*_backup_*.xml" \
					--exclude="*.backup" \
					--exclude="consoles/" \
					--exclude="scratches/" \
					--exclude="*.tmp" \
					--exclude=".DS_Store" \
					--exclude="inline.factors.completion.xml" \
					"$$ide_dir/options/" "$$BACKUP_DIR/options/"; \
			fi; \
			if [ -d "$$ide_dir/keymaps" ]; then \
				echo "  ⌨️  Backing up custom keymaps"; \
				rsync -a "$$ide_dir/keymaps/" "$$BACKUP_DIR/keymaps/"; \
			fi; \
			if [ -d "$$ide_dir/colors" ]; then \
				echo "  🌈 Backing up color schemes"; \
				rsync -a "$$ide_dir/colors/" "$$BACKUP_DIR/colors/"; \
			fi; \
			if [ -d "$$ide_dir/templates" ]; then \
				echo "  📝 Backing up file templates"; \
				rsync -a "$$ide_dir/templates/" "$$BACKUP_DIR/templates/"; \
			fi; \
			if [ -d "$$ide_dir/plugins" ]; then \
				echo "  🔌 Backing up plugin list with IDs"; \
				ls "$$ide_dir/plugins" > "$$BACKUP_DIR/plugins_list.txt"; \
				echo "# JetBrains Plugin Manifest" > "$$BACKUP_DIR/plugins_manifest.txt"; \
				echo "# Generated on $$(date)" >> "$$BACKUP_DIR/plugins_manifest.txt"; \
				echo "# Format: PluginID (for CLI installation)" >> "$$BACKUP_DIR/plugins_manifest.txt"; \
				echo "" >> "$$BACKUP_DIR/plugins_manifest.txt"; \
				for plugin_dir in "$$ide_dir/plugins"/*; do \
					if [ -d "$$plugin_dir" ]; then \
						plugin_name=$$(basename "$$plugin_dir"); \
						plugin_xml="$$plugin_dir/META-INF/plugin.xml"; \
						if [ -f "$$plugin_xml" ]; then \
							plugin_id=$$(grep -o '<id>[^<]*</id>' "$$plugin_xml" 2>/dev/null | sed 's/<id>\(.*\)<\/id>/\1/' || echo "$$plugin_name"); \
							echo "$$plugin_id" >> "$$BACKUP_DIR/plugins_manifest.txt"; \
						else \
							echo "$$plugin_name" >> "$$BACKUP_DIR/plugins_manifest.txt"; \
						fi; \
					fi; \
				done; \
			fi; \
			if [ -f "$$ide_dir/disabled_plugins.txt" ]; then \
				echo "  🚫 Backing up disabled plugins"; \
				cp "$$ide_dir/disabled_plugins.txt" "$$BACKUP_DIR/"; \
			fi; \
			for vm_file in "$$ide_dir"/*.vmoptions; do \
				if [ -f "$$vm_file" ]; then \
					echo "  🚀 Backing up VM options: $$(basename "$$vm_file")"; \
					cp "$$vm_file" "$$BACKUP_DIR/"; \
				fi; \
			done; \
			echo "$$IDE_NAME" > "$$BACKUP_DIR/ide_version.txt"; \
			echo "  ✅ $$IDE_NAME backup complete"; \
		fi; \
	done; \
	echo "🔄 Backing up shared JetBrains configurations..."; \
	if [ -f "$$HOME/.ideavimrc" ]; then \
		echo "  ⌨️  Backing up .ideavimrc"; \
		cp "$$HOME/.ideavimrc" "$$JETBRAINS_BACKUP_DIR/"; \
	fi; \
	if [ -f "$$HOME/Library/Application Support/JetBrains/idea.vmoptions" ]; then \
		echo "  🚀 Backing up global VM options"; \
		cp "$$HOME/Library/Application Support/JetBrains/idea.vmoptions" "$$JETBRAINS_BACKUP_DIR/"; \
	fi; \
	echo "✅ Enhanced JetBrains IDEs backup complete!"; \
	echo "📁 Backup location: $$JETBRAINS_BACKUP_DIR"


# Backup macOS system settings only
backup-macos:
	@echo "🍎 Backing up macOS system settings..."
	@MACOS_BACKUP_DIR="macos"; \
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	echo "🍎 Backing up macOS system settings to $$MACOS_BACKUP_DIR"; \
	mkdir -p "$$MACOS_BACKUP_DIR"; \
	mkdir -p "$$MACOS_BACKUP_DIR"/{system,display,dock,finder,keyboard,trackpad,mission_control,network,audio,accessibility,third_party}; \
	echo "🖥️  Backing up Display and Monitor Settings..."; \
	defaults export "com.apple.windowserver" "$$MACOS_BACKUP_DIR/display/display_preferences.plist" 2>/dev/null || echo "# Failed to export com.apple.windowserver on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/display/display_preferences.plist"; \
	defaults export "com.apple.display.DisplayServices" "$$MACOS_BACKUP_DIR/display/display_services.plist" 2>/dev/null || echo "# Failed to export com.apple.display.DisplayServices on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/display/display_services.plist"; \
	if [ -d "/Library/Application Support/DisplayLink" ]; then \
		echo "  🔗 Backing up DisplayLink settings"; \
		mkdir -p "$$MACOS_BACKUP_DIR/display/displaylink"; \
		sudo cp -R "/Library/Application Support/DisplayLink" "$$MACOS_BACKUP_DIR/display/displaylink/" 2>/dev/null || true; \
	fi; \
	defaults export "com.BetterZip.5" "$$MACOS_BACKUP_DIR/third_party/betterzip.plist" 2>/dev/null || true; \
	defaults export "com.objective-see.LuLu" "$$MACOS_BACKUP_DIR/third_party/lulu.plist" 2>/dev/null || true; \
	echo "🖱️  Backing up Dock Settings..."; \
	defaults export "com.apple.dock" "$$MACOS_BACKUP_DIR/dock/dock.plist" 2>/dev/null || echo "# Failed to export com.apple.dock on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/dock/dock.plist"; \
	echo "📁 Backing up Finder Settings..."; \
	defaults export "com.apple.finder" "$$MACOS_BACKUP_DIR/finder/finder.plist" 2>/dev/null || echo "# Failed to export com.apple.finder on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/finder/finder.plist"; \
	defaults export "com.apple.sidebarlists" "$$MACOS_BACKUP_DIR/finder/finder_sidebar.plist" 2>/dev/null || echo "# Failed to export com.apple.sidebarlists on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/finder/finder_sidebar.plist"; \
	echo "⌨️  Backing up Keyboard and Input Settings..."; \
	defaults export "com.apple.HIToolbox" "$$MACOS_BACKUP_DIR/keyboard/keyboard_layouts.plist" 2>/dev/null || echo "# Failed to export com.apple.HIToolbox on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/keyboard/keyboard_layouts.plist"; \
	defaults export "com.apple.inputmethod.EmojiFunctionRowItem" "$$MACOS_BACKUP_DIR/keyboard/emoji_settings.plist" 2>/dev/null || echo "# Failed to export com.apple.inputmethod.EmojiFunctionRowItem on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/keyboard/emoji_settings.plist"; \
	defaults export "com.apple.symbolichotkeys" "$$MACOS_BACKUP_DIR/keyboard/symbolic_hotkeys.plist" 2>/dev/null || echo "# Failed to export com.apple.symbolichotkeys on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/keyboard/symbolic_hotkeys.plist"; \
	echo "🖲️  Backing up Trackpad Settings..."; \
	defaults export "com.apple.driver.AppleBluetoothMultitouch.trackpad" "$$MACOS_BACKUP_DIR/trackpad/trackpad.plist" 2>/dev/null || echo "# Failed to export com.apple.driver.AppleBluetoothMultitouch.trackpad on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/trackpad/trackpad.plist"; \
	defaults export "com.apple.AppleMultitouchTrackpad" "$$MACOS_BACKUP_DIR/trackpad/multitouch_trackpad.plist" 2>/dev/null || echo "# Failed to export com.apple.AppleMultitouchTrackpad on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/trackpad/multitouch_trackpad.plist"; \
	echo "🚀 Backing up Mission Control Settings..."; \
	defaults export "com.apple.spaces" "$$MACOS_BACKUP_DIR/mission_control/mission_control.plist" 2>/dev/null || echo "# Failed to export com.apple.spaces on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/mission_control/mission_control.plist"; \
	defaults export "com.apple.exposé" "$$MACOS_BACKUP_DIR/mission_control/expose.plist" 2>/dev/null || echo "# Failed to export com.apple.exposé on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/mission_control/expose.plist"; \
	echo "🌐 Backing up Network Settings..."; \
	if [ -d "/Library/Preferences/SystemConfiguration" ]; then \
		echo "  📡 Backing up network configuration (sanitized)"; \
		mkdir -p "$$MACOS_BACKUP_DIR/network"; \
		sudo cp "/Library/Preferences/SystemConfiguration/preferences.plist" "$$MACOS_BACKUP_DIR/network/" 2>/dev/null || true; \
	fi; \
	echo "🔊 Backing up Audio Settings..."; \
	defaults export "com.apple.audio.AudioMIDISetup" "$$MACOS_BACKUP_DIR/audio/audio_midi.plist" 2>/dev/null || echo "# Failed to export com.apple.audio.AudioMIDISetup on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/audio/audio_midi.plist"; \
	defaults export "com.apple.audio.SystemSoundServer-macOS" "$$MACOS_BACKUP_DIR/audio/system_sounds.plist" 2>/dev/null || echo "# Failed to export com.apple.audio.SystemSoundServer-macOS on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/audio/system_sounds.plist"; \
	echo "♿ Backing up Accessibility Settings..."; \
	defaults export "com.apple.universalaccess" "$$MACOS_BACKUP_DIR/accessibility/accessibility.plist" 2>/dev/null || echo "# Failed to export com.apple.universalaccess on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/accessibility/accessibility.plist"; \
	echo "⚙️  Backing up General System Settings..."; \
	defaults export "NSGlobalDomain" "$$MACOS_BACKUP_DIR/system/global_domain.plist" 2>/dev/null || echo "# Failed to export NSGlobalDomain on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/system/global_domain.plist"; \
	defaults export "com.apple.systempreferences" "$$MACOS_BACKUP_DIR/system/system_preferences.plist" 2>/dev/null || echo "# Failed to export com.apple.systempreferences on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/system/system_preferences.plist"; \
	defaults export "com.apple.menuextra.clock" "$$MACOS_BACKUP_DIR/system/menu_clock.plist" 2>/dev/null || echo "# Failed to export com.apple.menuextra.clock on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/system/menu_clock.plist"; \
	defaults export "com.apple.controlcenter" "$$MACOS_BACKUP_DIR/system/control_center.plist" 2>/dev/null || echo "# Failed to export com.apple.controlcenter on $$TIMESTAMP" > "$$MACOS_BACKUP_DIR/system/control_center.plist"; \
	echo "📋 Saving system information..."; \
	{ \
		echo "# macOS System Information - Generated on $$TIMESTAMP"; \
		echo "macOS Version: $$(sw_vers -productVersion)"; \
		echo "Build: $$(sw_vers -buildVersion)"; \
		echo "Hardware: $$(system_profiler SPHardwareDataType | grep "Model Name\|Chip\|Memory")"; \
		echo ""; \
		echo "# Display Information"; \
		system_profiler SPDisplaysDataType 2>/dev/null || echo "Could not retrieve display information"; \
		echo ""; \
		echo "# Audio Information"; \
		system_profiler SPAudioDataType 2>/dev/null || echo "Could not retrieve audio information"; \
	} > "$$MACOS_BACKUP_DIR/system_info.txt"; \
	echo "📝 Creating restore script..."; \
	{ \
		echo "#!/bin/bash"; \
		echo "set -euo pipefail"; \
		echo ""; \
		echo "# macOS Settings Restore Script"; \
		echo "# IMPORTANT: Review settings before applying and restart affected applications"; \
		echo ""; \
		echo 'SCRIPT_DIR="$$(cd "$$(dirname "$$0")" && pwd)"'; \
		echo ""; \
		echo 'echo "🍎 Restoring macOS system settings from $$SCRIPT_DIR"'; \
		echo 'echo "⚠️  WARNING: This will overwrite current system preferences"'; \
		echo 'read -p "Continue? (y/N): " -n 1 -r'; \
		echo "echo"; \
		echo 'if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then'; \
		echo '    echo "❌ Restore cancelled"'; \
		echo "    exit 1"; \
		echo "fi"; \
		echo ""; \
		echo "# Function to restore defaults"; \
		echo "restore_defaults() {"; \
		echo '    local domain="$$1"'; \
		echo '    local filename="$$2"'; \
		echo '    local backup_dir="$$3"'; \
		echo ""; \
		echo '    if [ -f "$$backup_dir/$$filename" ]; then'; \
		echo '        echo "  📊 Restoring $$domain settings"'; \
		echo '        defaults import "$$domain" "$$backup_dir/$$filename" 2>/dev/null || {'; \
		echo '            echo "  ⚠️  Failed to restore $$domain settings"'; \
		echo "        }"; \
		echo "    else"; \
		echo '        echo "  ⚠️  Backup file $$filename not found"'; \
		echo "    fi"; \
		echo "}"; \
		echo ""; \
		echo 'echo "🖥️  Restoring Display Settings..."'; \
		echo 'restore_defaults "com.apple.windowserver" "display_preferences.plist" "$$SCRIPT_DIR/display"'; \
		echo 'restore_defaults "com.apple.display.DisplayServices" "display_services.plist" "$$SCRIPT_DIR/display"'; \
		echo ""; \
		echo 'echo "🖱️  Restoring Dock Settings..."'; \
		echo 'restore_defaults "com.apple.dock" "dock.plist" "$$SCRIPT_DIR/dock"'; \
		echo ""; \
		echo 'echo "📁 Restoring Finder Settings..."'; \
		echo 'restore_defaults "com.apple.finder" "finder.plist" "$$SCRIPT_DIR/finder"'; \
		echo 'restore_defaults "com.apple.sidebarlists" "finder_sidebar.plist" "$$SCRIPT_DIR/finder"'; \
		echo ""; \
		echo 'echo "⌨️  Restoring Keyboard Settings..."'; \
		echo 'restore_defaults "com.apple.HIToolbox" "keyboard_layouts.plist" "$$SCRIPT_DIR/keyboard"'; \
		echo 'restore_defaults "com.apple.symbolichotkeys" "symbolic_hotkeys.plist" "$$SCRIPT_DIR/keyboard"'; \
		echo ""; \
		echo 'echo "🖲️  Restoring Trackpad Settings..."'; \
		echo 'restore_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "trackpad.plist" "$$SCRIPT_DIR/trackpad"'; \
		echo 'restore_defaults "com.apple.AppleMultitouchTrackpad" "multitouch_trackpad.plist" "$$SCRIPT_DIR/trackpad"'; \
		echo ""; \
		echo 'echo "🚀 Restoring Mission Control Settings..."'; \
		echo 'restore_defaults "com.apple.spaces" "mission_control.plist" "$$SCRIPT_DIR/mission_control"'; \
		echo 'restore_defaults "com.apple.exposé" "expose.plist" "$$SCRIPT_DIR/mission_control"'; \
		echo ""; \
		echo 'echo "🔊 Restoring Audio Settings..."'; \
		echo 'restore_defaults "com.apple.audio.AudioMIDISetup" "audio_midi.plist" "$$SCRIPT_DIR/audio"'; \
		echo 'restore_defaults "com.apple.audio.SystemSoundServer-macOS" "system_sounds.plist" "$$SCRIPT_DIR/audio"'; \
		echo ""; \
		echo 'echo "♿ Restoring Accessibility Settings..."'; \
		echo 'restore_defaults "com.apple.universalaccess" "accessibility.plist" "$$SCRIPT_DIR/accessibility"'; \
		echo ""; \
		echo 'echo "⚙️  Restoring General System Settings..."'; \
		echo 'restore_defaults "NSGlobalDomain" "global_domain.plist" "$$SCRIPT_DIR/system"'; \
		echo 'restore_defaults "com.apple.systempreferences" "system_preferences.plist" "$$SCRIPT_DIR/system"'; \
		echo 'restore_defaults "com.apple.menuextra.clock" "menu_clock.plist" "$$SCRIPT_DIR/system"'; \
		echo 'restore_defaults "com.apple.controlcenter" "control_center.plist" "$$SCRIPT_DIR/system"'; \
		echo ""; \
		echo 'echo "🔄 Restarting affected services..."'; \
		echo "killall Dock 2>/dev/null || true"; \
		echo "killall Finder 2>/dev/null || true"; \
		echo "killall SystemUIServer 2>/dev/null || true"; \
		echo "killall ControlCenter 2>/dev/null || true"; \
		echo ""; \
		echo 'echo "✅ macOS settings restore complete!"'; \
		echo 'echo "💡 Some changes may require a restart to take full effect"'; \
		echo 'echo "🔧 For DisplayLink settings, restart the DisplayLink service or reboot"'; \
	} > "$$MACOS_BACKUP_DIR/restore_macos_settings.sh"; \
	chmod +x "$$MACOS_BACKUP_DIR/restore_macos_settings.sh"; \
	echo "✅ macOS system settings backup complete!"; \
	echo "📂 Backup location: $$MACOS_BACKUP_DIR"; \
	echo "🔄 To restore: run $$MACOS_BACKUP_DIR/restore_macos_settings.sh"; \
	echo ""; \
	echo "💡 Manual steps for complete display setup:"; \
	echo "   1. System Settings > Displays > Arrangement"; \
	echo "   2. DisplayLink Manager settings (if using DisplayLink)"; \
	echo "   3. Third-party display utilities configurations"
