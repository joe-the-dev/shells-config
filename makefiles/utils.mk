# Utilities and Maintenance Makefile
# Handles system maintenance, validation, and utility functions

.PHONY: update check-deps upgrade-deps clean status dry-run validate-config

# Update git repository
update:
	@echo "ℹ️  Updating git repository..."
	@if [ -d ".git" ]; then \
		echo "ℹ️  Pulling latest changes..."; \
		git pull || echo "⚠️  Git pull failed - continuing anyway"; \
		echo "✅ Repository updated"; \
	else \
		echo "ℹ️  Not a git repository - skipping update"; \
	fi

# Check for required dependencies
check-deps:
	@echo "🔍 Checking dependencies..."
	@echo -n "Homebrew: "; command -v brew >/dev/null && echo "✅" || echo "❌ Install from https://brew.sh"
	@echo -n "Fish shell: "; command -v fish >/dev/null && echo "✅" || echo "⚠️  Optional"
	@echo -n "asdf: "; command -v asdf >/dev/null && echo "✅" || echo "⚠️  Optional"
	@echo -n "Git: "; command -v git >/dev/null && echo "✅" || echo "❌ Required"

# Upgrade all package managers and dependencies
upgrade-deps:
	@echo "🔄 Upgrading all dependencies..."
	@if command -v brew >/dev/null 2>&1; then \
		echo "🍺 Upgrading Homebrew..."; \
		brew update && brew upgrade; \
	fi
	@if command -v asdf >/dev/null 2>&1; then \
		echo "🔧 Upgrading asdf..."; \
		asdf update; \
	fi
	@if command -v npm >/dev/null 2>&1; then \
		echo "📦 Upgrading npm global packages..."; \
		npm update -g; \
	fi
	@if command -v pnpm >/dev/null 2>&1; then \
		echo "📦 Upgrading pnpm..."; \
		pnpm add -g pnpm; \
	fi
	@if command -v pip >/dev/null 2>&1; then \
		echo "🐍 Upgrading pip..."; \
		pip install --upgrade pip; \
	fi
	@if command -v pipx >/dev/null 2>&1; then \
		echo "🐍 Upgrading pipx packages..."; \
		pipx upgrade-all; \
	fi
	@if command -v fish >/dev/null 2>&1 && fish -c "type omf" >/dev/null 2>&1; then \
		echo "🐟 Upgrading OMF..."; \
		fish -c "omf update"; \
	fi
	@echo "✅ All dependencies upgraded!"

# Clean up temporary files and old configurations
clean:
	@echo "🧹 Cleaning up temporary files and old configurations..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@CLEANED_COUNT=0; \
	if [ -d "jetbrains-ides" ]; then \
		echo "🧠 Cleaning up old JetBrains IDE versions..."; \
		cd jetbrains-ides; \
		for ide_base in DataGrip IntelliJIdea PyCharm WebStorm PhpStorm CLion GoLand RubyMine Rider; do \
			IDE_DIRS=$$(find . -maxdepth 1 -type d -name "$$ide_base*" | sort -V); \
			if [ -n "$$IDE_DIRS" ]; then \
				IDE_COUNT=$$(echo "$$IDE_DIRS" | wc -l | tr -d ' '); \
				if [ "$$IDE_COUNT" -gt 1 ]; then \
					LATEST_DIR=$$(echo "$$IDE_DIRS" | tail -1); \
					echo "  📂 Found $$IDE_COUNT versions of $$ide_base, keeping latest: $$(basename "$$LATEST_DIR")"; \
					echo "$$IDE_DIRS" | while read -r dir; do \
						if [ "$$dir" != "$$LATEST_DIR" ] && [ -d "$$dir" ]; then \
							OLD_FILES_COUNT=$$(find "$$dir" -type f | wc -l | tr -d ' '); \
							echo "    🗑️  Removing old version: $$(basename "$$dir") ($$OLD_FILES_COUNT files)"; \
							rm -rf "$$dir"; \
							CLEANED_COUNT=$$((CLEANED_COUNT + OLD_FILES_COUNT)); \
						fi; \
					done; \
				else \
					echo "  ℹ️  Only 1 version of $$ide_base found, keeping it"; \
				fi; \
			fi; \
		done; \
		cd ..; \
		echo "🧠 Cleaning cache and unnecessary files from JetBrains IDEs configurations..."; \
		REMOVED_FILE_COUNT=0; \
		for file_pattern in \
			"vim_settings_local.xml" \
			"recentProjects.xml" \
			"window.*.xml" \
			"actionSummary.xml" \
			"contributorSummary.xml" \
			"features.usage.statistics.xml" \
			"dailyLocalStatistics.xml" \
			"log-categories.xml" \
			"EventLog*.xml" \
			"DontShowAgain*.xml" \
			"CommonFeedback*.xml" \
			"AIOnboarding*.xml" \
			"McpToolsStore*.xml" \
			"usage.statistics.xml" \
			"statistics.xml" \
			"event-log-whitelist.xml" \
			"inline.factors.completion.xml" \
			"ConversationToolStoreService.xml" \
			"vcs-inputs.xml" \
			"github.xml" \
			"trusted-paths.xml" \
			"*_backup_*.xml" \
			"*.backup" \
		; do \
			FOUND_FILES=$$(find jetbrains-ides -name "$$file_pattern" 2>/dev/null || true); \
			if [ -n "$$FOUND_FILES" ]; then \
				FILE_COUNT=$$(echo "$$FOUND_FILES" | wc -l | tr -d ' '); \
				echo "$$FOUND_FILES" | xargs rm -f; \
				REMOVED_FILE_COUNT=$$((REMOVED_FILE_COUNT + FILE_COUNT)); \
			fi; \
		done; \
		if [ "$$REMOVED_FILE_COUNT" -gt 0 ]; then \
			echo "  ✅ Removed $$REMOVED_FILE_COUNT unnecessary files from jetbrains-ides/"; \
			CLEANED_COUNT=$$((CLEANED_COUNT + REMOVED_FILE_COUNT)); \
		else \
			echo "  ℹ️  No unnecessary files found in jetbrains-ides/"; \
		fi; \
		echo "🧠 Cleaning empty directories in JetBrains IDEs configurations..."; \
		EMPTY_DIRS=$$(find jetbrains-ides -type d -empty 2>/dev/null || true); \
		if [ -n "$$EMPTY_DIRS" ]; then \
			EMPTY_DIR_COUNT=$$(echo "$$EMPTY_DIRS" | wc -l | tr -d ' '); \
			echo "$$EMPTY_DIRS" | xargs rmdir 2>/dev/null || true; \
			echo "  ✅ Removed $$EMPTY_DIR_COUNT empty directories"; \
		fi; \
	fi; \
	if [ -d "karabiner/automatic_backups" ]; then \
		echo "⌨️  Cleaning old Karabiner automatic backups..."; \
		BACKUP_COUNT=$$(ls -1 karabiner/automatic_backups/karabiner_*.json 2>/dev/null | wc -l | tr -d ' '); \
		if [ "$$BACKUP_COUNT" -gt 2 ]; then \
			KEEP_COUNT=2; \
			DELETE_COUNT=$$((BACKUP_COUNT - KEEP_COUNT)); \
			echo "  📊 Found $$BACKUP_COUNT backups, keeping $$KEEP_COUNT most recent, removing $$DELETE_COUNT old ones"; \
			ls -1t karabiner/automatic_backups/karabiner_*.json 2>/dev/null | tail -n +$$((KEEP_COUNT + 1)) | xargs rm -f; \
			CLEANED_COUNT=$$((CLEANED_COUNT + DELETE_COUNT)); \
			echo "  ✅ Removed $$DELETE_COUNT old Karabiner backups"; \
		else \
			echo "  ℹ️  Only $$BACKUP_COUNT Karabiner backups found, keeping all"; \
		fi; \
	fi; \
	if [ "$$CLEANED_COUNT" -gt 0 ]; then \
		echo "✅ Cleanup complete! Removed $$CLEANED_COUNT files/directories"; \
	else \
		echo "✅ Cleanup complete! No files needed to be removed"; \
	fi

# Show current configuration status
status:
	@echo "📊 Configuration Status Report"
	@echo "=============================="
	@echo ""
	@echo "🏠 Home Directory: $(HOME_DIR)"
	@echo "📁 Config Directory: $(CONFIG_DIR)"
	@echo ""
	@echo "🔍 Dependencies:"
	@printf "  %-15s " "Homebrew:"; command -v brew >/dev/null && echo "✅ $(shell brew --version | head -1)" || echo "❌ Not installed"
	@printf "  %-15s " "Git:"; command -v git >/dev/null && echo "✅ $(shell git --version)" || echo "❌ Not installed"
	@printf "  %-15s " "Fish:"; command -v fish >/dev/null && echo "✅ $(shell fish --version)" || echo "⚠️  Not installed"
	@printf "  %-15s " "asdf:"; command -v asdf >/dev/null && echo "✅ $(shell asdf version)" || echo "⚠️  Not installed"
	@echo ""
	@echo "📄 Configuration Files:"
	@printf "  %-20s " ".gitconfig:"; [ -f "$(TARGET_GITCONFIG)" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " ".gitignore_global:"; [ -f "$(TARGET_GITIGNORE)" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " "Fish config:"; [ -d "$(CONFIG_DIR)/fish" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " "Neovim config:"; [ -d "$(CONFIG_DIR)/nvim" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " "Karabiner config:"; [ -d "$(CONFIG_DIR)/karabiner" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " "Hammerspoon config:"; [ -d "$(HOME_DIR)/.hammerspoon" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " "Brewfile:"; [ -f "$(TARGET_BREWFILE)" ] && echo "✅ Exists" || echo "❌ Missing"
	@printf "  %-20s " "asdf config:"; [ -f "$(TARGET_ASDF_RC)" ] && echo "✅ Exists" || echo "❌ Missing"
	@echo ""
	@echo "🧠 JetBrains IDEs:"
	@if [ -d "$(JETBRAINS_DIR)" ]; then \
		IDE_COUNT=$$(find "$(JETBRAINS_DIR)" -maxdepth 1 -type d -name "*20*" | wc -l | tr -d ' '); \
		if [ "$$IDE_COUNT" -gt 0 ]; then \
			echo "  📦 Found $$IDE_COUNT IDE configurations:"; \
			find "$(JETBRAINS_DIR)" -maxdepth 1 -type d -name "*20*" | while read -r ide_dir; do \
				IDE_NAME=$$(basename "$$ide_dir"); \
				echo "    ✅ $$IDE_NAME"; \
			done; \
		else \
			echo "  ⚠️  No IDE configurations found"; \
		fi; \
	else \
		echo "  ❌ JetBrains directory not found"; \
	fi
	@echo ""
	@echo "🐚 Current Shell:"
	@CURRENT_SHELL=$$(dscl . -read /Users/$$(whoami) UserShell 2>/dev/null | awk '{print $$2}' || echo "unknown"); \
	echo "  Current: $$CURRENT_SHELL"; \
	if command -v fish >/dev/null && [ "$$CURRENT_SHELL" = "$$(which fish)" ]; then \
		echo "  ✅ Fish is set as default shell"; \
	elif command -v fish >/dev/null; then \
		echo "  ⚠️  Fish available but not default shell"; \
	else \
		echo "  ❌ Fish not installed"; \
	fi

# Dry run - show what would be installed
dry-run:
	@echo "🔍 Dry Run - What would be installed:"
	@echo "=================================="
	@echo ""
	@echo "📂 Configuration files that would be copied:"
	@for dir in omf karabiner hammerspoon fish nvim; do \
		if [ -d "$$dir" ]; then \
			echo "  ✅ $$dir/ → ~/.config/$$dir/ (or appropriate location)"; \
		else \
			echo "  ⚠️  $$dir/ not found - would skip"; \
		fi; \
	done
	@for file in "brew/Brewfile" "asdf/.asdfrc" "asdf/.tool-versions" "gitconfig/.gitconfig" "gitconfig/.gitignore_global"; do \
		if [ -f "$$file" ]; then \
			echo "  ✅ $$file → ~/.$$(basename "$$file")"; \
		else \
			echo "  ⚠️  $$file not found - would skip"; \
		fi; \
	done
	@echo ""
	@echo "🍺 Homebrew packages:"
	@if [ -f "brew/Brewfile" ]; then \
		echo "  📦 Would install packages from brew/Brewfile:"; \
		grep -E "^(brew|cask|mas)" brew/Brewfile 2>/dev/null | head -10 | sed 's/^/    /' || echo "    (No packages found)"; \
		TOTAL_PACKAGES=$$(grep -E "^(brew|cask|mas)" brew/Brewfile 2>/dev/null | wc -l | tr -d ' '); \
		if [ "$$TOTAL_PACKAGES" -gt 10 ]; then \
			echo "    ... and $$((TOTAL_PACKAGES - 10)) more packages"; \
		fi; \
	else \
		echo "  ⚠️  No Brewfile found"; \
	fi
	@echo ""
	@echo "🔧 asdf plugins:"
	@if [ -f "asdf/plugins.txt" ]; then \
		echo "  📦 Would install plugins:"; \
		cat asdf/plugins.txt | grep -v "^#" | grep -v "^$$" | sed 's/^/    /' || echo "    (No plugins found)"; \
	else \
		echo "  ⚠️  No plugins.txt found"; \
	fi
	@echo ""
	@echo "💡 To actually install, run: make install"

# Validate configuration files
validate-config:
	@echo "🔍 Validating configuration files..."
	@ERROR_COUNT=0; \
	echo "📄 Checking configuration file syntax..."; \
	if [ -f "gitconfig/.gitconfig" ]; then \
		if git config --file="gitconfig/.gitconfig" --list >/dev/null 2>&1; then \
			echo "  ✅ .gitconfig syntax is valid"; \
		else \
			echo "  ❌ .gitconfig has syntax errors"; \
			ERROR_COUNT=$$((ERROR_COUNT + 1)); \
		fi; \
	else \
		echo "  ⚠️  .gitconfig not found"; \
	fi; \
	if [ -f "fish/config.fish" ]; then \
		if command -v fish >/dev/null && fish -n fish/config.fish >/dev/null 2>&1; then \
			echo "  ✅ Fish config syntax is valid"; \
		else \
			echo "  ⚠️  Fish config syntax check skipped (fish not available or syntax errors)"; \
		fi; \
	else \
		echo "  ⚠️  Fish config not found"; \
	fi; \
	if [ -f "karabiner/karabiner.json" ]; then \
		if python3 -m json.tool karabiner/karabiner.json >/dev/null 2>&1; then \
			echo "  ✅ Karabiner config JSON is valid"; \
		else \
			echo "  ❌ Karabiner config has JSON syntax errors"; \
			ERROR_COUNT=$$((ERROR_COUNT + 1)); \
		fi; \
	else \
		echo "  ⚠️  Karabiner config not found"; \
	fi; \
	if [ -f "hammerspoon/init.lua" ]; then \
		if lua -l hammerspoon/init.lua -e "" >/dev/null 2>&1; then \
			echo "  ✅ Hammerspoon config Lua syntax is valid"; \
		else \
			echo "  ⚠️  Hammerspoon config syntax check skipped (lua not available or syntax errors)"; \
		fi; \
	else \
		echo "  ⚠️  Hammerspoon config not found"; \
	fi; \
	echo ""; \
	echo "📦 Checking file permissions..."; \
	for sensitive_file in ".env.template" "env/home.env" "env/template.env"; do \
		if [ -f "$$sensitive_file" ]; then \
			PERMS=$$(stat -f "%A" "$$sensitive_file" 2>/dev/null || stat -c "%a" "$$sensitive_file" 2>/dev/null); \
			if [ "$$PERMS" = "600" ] || [ "$$PERMS" = "644" ]; then \
				echo "  ✅ $$sensitive_file has appropriate permissions ($$PERMS)"; \
			else \
				echo "  ⚠️  $$sensitive_file permissions may be too open ($$PERMS)"; \
			fi; \
		fi; \
	done; \
	echo ""; \
	if [ "$$ERROR_COUNT" -eq 0 ]; then \
		echo "✅ All configuration files passed validation!"; \
	else \
		echo "❌ Found $$ERROR_COUNT configuration errors that need attention"; \
		exit 1; \
	fi
