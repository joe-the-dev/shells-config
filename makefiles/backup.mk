# Backup and Restore Makefile
# Handles all backup operations for applications

.PHONY: backup backup-apps backup-sync

# Main backup target - backs up everything
backup:
	@echo "💾 Running complete backup..."
	@$(MAKE) -s backup-apps
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
		echo "❌ ERROR: backup-sync must be run from the main branch (currently on: $$CURRENT_BRANCH)"; \
		echo "💡 Run: git checkout main && make backup-sync"; \
		exit 1; \
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
	@rm -f .parallel_log.tmp
	@echo "🚀 Batch 1: fish, nvim, omf, karabiner"; \
	$(MAKE) -s _backup-fish & PID1=$$!; \
	$(MAKE) -s _backup-nvim & PID2=$$!; \
	$(MAKE) -s _backup-omf & PID3=$$!; \
	$(MAKE) -s _backup-karabiner & PID4=$$!; \
	echo "⏳ Waiting for batch 1 to complete..."; \
	wait $$PID1 $$PID2 $$PID3 $$PID4; \
	echo "✅ Batch 1 completed!"
	@echo "🚀 Batch 2: hammerspoon, asdf, bash, zsh"; \
	$(MAKE) -s _backup-hammerspoon & PID1=$$!; \
	$(MAKE) -s _backup-asdf & PID2=$$!; \
	$(MAKE) -s _backup-bash & PID3=$$!; \
	$(MAKE) -s _backup-zsh & PID4=$$!; \
	echo "⏳ Waiting for batch 2 to complete..."; \
	wait $$PID1 $$PID2 $$PID3 $$PID4; \
	echo "✅ Batch 2 completed!"
	@echo "🚀 Batch 3: git, brew, iterm2, env"; \
	$(MAKE) -s _backup-gitconfig & PID1=$$!; \
	$(MAKE) -s _backup-brew & PID2=$$!; \
	$(MAKE) -s _backup-iterm2 & PID3=$$!; \
	$(MAKE) -s _backup-env & PID4=$$!; \
	echo "⏳ Waiting for batch 3 to complete..."; \
	wait $$PID1 $$PID2 $$PID3 $$PID4; \
	echo "✅ Batch 3 completed!"
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
	for identity_file in "$$HOME"/.gitconfig-*; do \
		if [ -f "$$identity_file" ]; then \
			cp "$$identity_file" "$$dst/"; \
		fi; \
	done; \
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
