# Installation and Restoration Makefile
# Handles all installation targets and configuration restoration

.PHONY: install install-minimal install-dev install-tools copy-configs restore restore-jetbrains restore-macos macos
.PHONY: brew asdf jetbrains iterm2 omf env set-fish-default
.PHONY: _copy-omf _copy-karabiner _copy-hammerspoon _copy-brew _copy-asdf _copy-bash _copy-zsh _copy-git _copy-fish _copy-nvim

# Main installation target
install: update copy-configs brew asdf jetbrains iterm2 omf env set-fish-default
	@echo "✅ All configurations installed successfully!"

# Minimal installation (essential configs only)
install-minimal: update
	@echo "🚀 Installing minimal configuration..."
	@$(MAKE) -s _copy-git _copy-fish _copy-nvim
	@echo "✅ Minimal configuration installed (git, fish, nvim)!"

# Development tools installation
install-dev: update
	@echo "🛠️  Installing development tools..."
	@$(MAKE) -s brew asdf jetbrains
	@echo "✅ Development tools installed (brew, asdf, jetbrains)!"

# Productivity tools installation
install-tools: update
	@echo "⚡ Installing productivity tools..."
	@$(MAKE) -s _copy-karabiner _copy-hammerspoon iterm2
	@echo "✅ Productivity tools installed (karabiner, hammerspoon, iterm2)!"

# Copy configuration files
copy-configs:
	@echo "📁 Copying configuration files..."
	@$(MAKE) -s _copy-omf
	@$(MAKE) -s _copy-karabiner
	@$(MAKE) -s _copy-hammerspoon
	@$(MAKE) -s _copy-brew
	@$(MAKE) -s _copy-asdf
	@$(MAKE) -s _copy-bash
	@$(MAKE) -s _copy-zsh
	@$(MAKE) -s _copy-git
	@$(MAKE) -s _copy-fish
	@$(MAKE) -s _copy-nvim
	@echo "✅ All configuration files copied!"

# Internal copy targets
_copy-omf:
	@if [ -d "omf" ]; then \
		echo "🐟 Copying OMF config..."; \
		rm -rf "$$HOME/.config/omf"; \
		mkdir -p "$$HOME/.config"; \
		cp -a "omf" "$$HOME/.config/omf"; \
	fi

_copy-karabiner:
	@if [ -d "karabiner" ]; then \
		echo "⌨️  Copying Karabiner config..."; \
		rm -rf "$$HOME/.config/karabiner"; \
		mkdir -p "$$HOME/.config"; \
		cp -a "karabiner" "$$HOME/.config/karabiner"; \
	fi

_copy-hammerspoon:
	@if [ -d "hammerspoon" ]; then \
		echo "🔨 Copying Hammerspoon config..."; \
		rm -rf "$$HOME/.hammerspoon"; \
		cp -a "hammerspoon" "$$HOME/.hammerspoon"; \
	fi

_copy-brew:
	@if [ -f "brew/Brewfile" ]; then \
		echo "🍺 Copying Brewfile..."; \
		rm -f "$$HOME/.Brewfile"; \
		cp "brew/Brewfile" "$$HOME/.Brewfile"; \
	fi

_copy-asdf:
	@if [ -f "asdf/.asdfrc" ]; then \
		echo "🔧 Copying asdf config..."; \
		rm -f "$$HOME/.asdfrc"; \
		cp "asdf/.asdfrc" "$$HOME/.asdfrc"; \
	fi
	@if [ -f "asdf/.tool-versions" ]; then \
	    rm -f "$$HOME/.tool-versions"; \
		cp "asdf/.tool-versions" "$$HOME/.tool-versions"; \
	fi

_copy-bash:
	@if [ -f "bash/.bashrc" ]; then \
		echo "🐚 Copying bash config..."; \
		cp "bash/.bashrc" "$$HOME/.bashrc"; \
	fi

_copy-zsh:
	@if [ -f "zsh/.zshrc" ]; then \
		echo "🦓 Copying zsh config..."; \
		cp "zsh/.zshrc" "$$HOME/.zshrc"; \
	fi

_copy-git:
	@if [ -f "gitconfig/.gitconfig" ]; then \
		echo "📝 Copying git config..."; \
		cp "gitconfig/.gitconfig" "$$HOME/.gitconfig"; \
	fi
	@if [ -f "gitconfig/.gitignore_global" ]; then \
		cp "gitconfig/.gitignore_global" "$$HOME/.gitignore_global"; \
	fi

_copy-fish:
	@if [ -d "fish" ]; then \
		echo "🐟 Copying Fish shell config..."; \
		rm -rf "$$HOME/.config/fish"; \
		mkdir -p "$$HOME/.config"; \
		cp -a "fish" "$$HOME/.config/fish"; \
	fi

_copy-nvim:
	@if [ -d "nvim" ]; then \
		echo "⚡ Copying Neovim config..."; \
		rm -rf "$$HOME/.config/nvim"; \
		mkdir -p "$$HOME/.config"; \
		cp -a "nvim" "$$HOME/.config/nvim"; \
	fi

# Install Homebrew packages
brew:
	@echo "🍺 Installing Homebrew packages..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "⚠️  Homebrew not found - please install Homebrew first"; \
		echo "💡 Install from: https://brew.sh"; \
		exit 1; \
	fi
	@if [ -f "brew/Brewfile" ]; then \
		echo "📦 Installing packages..."; \
		brew bundle install --file=brew/Brewfile --verbose || \
		(echo "⚠️  Some packages may have failed - this might be normal for packages requiring sudo"; \
		 echo "💡 You can manually run: brew bundle install --file=brew/Brewfile"); \
	else \
		echo "⚠️  brew/Brewfile not found"; \
	fi

# Install asdf plugins and tools
asdf:
	@echo "🔧 Installing asdf plugins and tools..."
	@if ! command -v asdf >/dev/null 2>&1; then \
		echo "ℹ️  asdf not found - skipping plugin installation"; \
		echo "💡 Install asdf first: https://asdf-vm.com/guide/getting-started.html"; \
		exit 0; \
	fi
	@if [ -f "asdf/plugins.txt" ]; then \
		echo "📦 Installing plugins from plugins.txt..."; \
		while IFS= read -r plugin || [ -n "$$plugin" ]; do \
			if [[ -z "$$plugin" || "$$plugin" =~ ^[[:space:]]*# ]]; then \
				continue; \
			fi; \
			plugin_name=$$(echo "$$plugin" | awk '{print $$1}'); \
			echo "📦 Checking plugin: $$plugin_name"; \
			if asdf plugin list | grep -q "^$$plugin_name$$"; then \
				echo "⚠️  Plugin $$plugin_name is already installed, skipping"; \
			else \
				echo "Installing plugin: $$plugin_name"; \
				asdf plugin add $$plugin || (echo "❌ Failed to install plugin: $$plugin_name"; exit 1); \
				echo "✅ Successfully installed plugin: $$plugin_name"; \
			fi; \
		done < "asdf/plugins.txt"; \
		echo "🔧 Installing tool versions..."; \
		asdf install || (echo "❌ Some tools failed to install"; exit 1); \
		echo "✅ asdf setup complete!"; \
	else \
		echo "ℹ️  asdf/plugins.txt not found - skipping plugin installation"; \
	fi

# Install JetBrains IDEs configuration
jetbrains:
	@echo "🧠 Installing JetBrains IDEs configuration..."
	@if [ ! -d "jetbrains-ides" ]; then \
		echo "⚠️  No JetBrains backup found at jetbrains-ides/"; \
		echo "💡 Run 'make backup' first to create a backup"; \
		exit 0; \
	fi
	@$(MAKE) -s restore-jetbrains
	@$(MAKE) -s install-jetbrains-plugins
	@echo "✅ JetBrains IDEs configuration and plugins installed!"

# Install JetBrains plugins automatically using CLI
install-jetbrains-plugins:
	@echo "🔌 Installing JetBrains plugins from backup..."
	@JETBRAINS_DIR="$$HOME/Library/Application Support/JetBrains"; \
	JETBRAINS_BACKUP_DIR="jetbrains-ides"; \
	if [ ! -d "$$JETBRAINS_BACKUP_DIR" ]; then \
		echo "⚠️  No JetBrains backup found"; \
		exit 0; \
	fi; \
	for backup_dir in "$$JETBRAINS_BACKUP_DIR"/*/; do \
		if [ -d "$$backup_dir" ]; then \
			IDE_NAME=$$(basename "$$backup_dir"); \
			if [[ "$$IDE_NAME" == .* ]]; then \
				continue; \
			fi; \
			echo "🔌 Installing plugins for $$IDE_NAME..."; \
			if [ -f "$$backup_dir/plugins_manifest.txt" ]; then \
				PLUGIN_COUNT=0; \
				while IFS= read -r plugin_id || [ -n "$$plugin_id" ]; do \
					if [[ -z "$$plugin_id" || "$$plugin_id" =~ ^[[:space:]]*# ]]; then \
						continue; \
					fi; \
					echo "  📦 Installing plugin: $$plugin_id"; \
					if [[ "$$IDE_NAME" == *"IntelliJ"* ]]; then \
						IDE_EXECUTABLE="/Applications/IntelliJ IDEA.app/Contents/MacOS/idea"; \
					elif [[ "$$IDE_NAME" == *"WebStorm"* ]]; then \
						IDE_EXECUTABLE="/Applications/WebStorm.app/Contents/MacOS/webstorm"; \
					elif [[ "$$IDE_NAME" == *"PyCharm"* ]]; then \
						IDE_EXECUTABLE="/Applications/PyCharm.app/Contents/MacOS/pycharm"; \
					elif [[ "$$IDE_NAME" == *"DataGrip"* ]]; then \
						IDE_EXECUTABLE="/Applications/DataGrip.app/Contents/MacOS/datagrip"; \
					else \
						echo "    ⚠️  Unknown IDE type for $$IDE_NAME, skipping plugin installation"; \
						continue; \
					fi; \
					if [ -f "$$IDE_EXECUTABLE" ]; then \
						"$$IDE_EXECUTABLE" installPlugins "$$plugin_id" 2>/dev/null || \
						echo "    ⚠️  Failed to install $$plugin_id (may already be installed)"; \
						PLUGIN_COUNT=$$((PLUGIN_COUNT + 1)); \
					else \
						echo "    ⚠️  $$IDE_NAME executable not found, skipping plugin installation"; \
					fi; \
				done < "$$backup_dir/plugins_manifest.txt"; \
				echo "  ✅ Processed $$PLUGIN_COUNT plugins for $$IDE_NAME"; \
			elif [ -f "$$backup_dir/plugins_list.txt" ]; then \
				echo "  💡 Found plugins_list.txt but no plugins_manifest.txt"; \
				echo "     Run 'make backup' to generate plugin manifest for CLI installation"; \
			else \
				echo "  ℹ️  No plugin manifest found for $$IDE_NAME"; \
			fi; \
		fi; \
	done

# Install iTerm2 configuration
iterm2:
	@echo "🖥️  Installing iTerm2 configuration..."
	@if [ ! -d "iterm2" ]; then \
		echo "⚠️  No iTerm2 config found"; \
		exit 0; \
	fi
	@if pgrep -x "iTerm2" > /dev/null; then \
		echo "⚠️  iTerm2 is currently running. Please close it first."; \
		exit 0; \
	fi
	@if [ -f "iterm2/com.googlecode.iterm2.plist" ]; then \
		echo "📋 Restoring iTerm2 preferences..."; \
		cp "iterm2/com.googlecode.iterm2.plist" "$$HOME/Library/Preferences/"; \
	fi
	@mkdir -p "$$HOME/Library/Application Support/iTerm2"; \
	if [ -d "iterm2/DynamicProfiles" ]; then \
		echo "🎨 Restoring Dynamic Profiles..."; \
		cp -R "iterm2/DynamicProfiles" "$$HOME/Library/Application Support/iTerm2/"; \
	fi; \
	if [ -d "iterm2/Scripts" ]; then \
		echo "📜 Restoring iTerm2 Scripts..."; \
		cp -R "iterm2/Scripts" "$$HOME/Library/Application Support/iTerm2/"; \
	fi; \
	if [ -f "iterm2/version.txt" ]; then \
		cp "iterm2/version.txt" "$$HOME/Library/Application Support/iTerm2/"; \
	fi
	@echo "✅ iTerm2 configuration restored!"

# Install Oh My Fish configuration
omf:
	@echo "🐟 Installing OMF (Oh My Fish) configuration..."
	@if ! command -v fish >/dev/null 2>&1; then \
		echo "⚠️  Fish shell not found. Please install Fish first."; \
		exit 0; \
	fi
	@if [ ! -d "omf" ]; then \
		echo "⚠️  No OMF config found"; \
		exit 0; \
	fi
	@if ! fish -c "type omf" >/dev/null 2>&1; then \
		echo "📦 Installing Oh My Fish..."; \
		fish -c "curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish"; \
		echo "✅ OMF installed"; \
	else \
		echo "✅ OMF already installed"; \
	fi
	@OMF_CONFIG_DIR="$$HOME/.config/omf"; \
	mkdir -p "$$OMF_CONFIG_DIR"; \
	echo "🔄 Restoring OMF configuration..."; \
	for omf_file in bundle channel theme; do \
		if [ -f "omf/$$omf_file" ]; then \
			echo "📋 Restoring $$omf_file"; \
			cp "omf/$$omf_file" "$$OMF_CONFIG_DIR/"; \
		fi; \
	done
	@if [ -f "omf/bundle" ]; then \
		echo "📦 Installing OMF packages from bundle..."; \
		while IFS= read -r package || [ -n "$$package" ]; do \
			[[ -z "$$package" || "$$package" =~ ^[[:space:]]*# ]] && continue; \
			echo "🔌 Installing OMF package: $$package"; \
			fish -c "omf install $$package" || echo "⚠️  Failed to install $$package"; \
		done < "omf/bundle"; \
	fi
	@if [ -f "omf/theme" ]; then \
		theme=$$(cat "omf/theme"); \
		if [ -n "$$theme" ] && [ "$$theme" != "default" ]; then \
			echo "🎨 Setting OMF theme: $$theme"; \
			fish -c "omf theme $$theme" || echo "⚠️  Failed to set theme $$theme"; \
		fi; \
	fi
	@echo "✅ OMF configuration restored!"

# Setup environment variables
env:
	@echo "🔐 Setting up environment variables..."
	@if [ ! -f ".env.template" ]; then \
		echo "❌ .env.template not found!"; \
		exit 1; \
	fi
	@echo "🔄 Using merge approach to preserve existing .env..."
	@TEMPLATE_FILE=".env.template"; \
	TARGET_ENV_FILE="$$HOME/.env"; \
	MARKER_LINE="# export ANOTHER_VAR=\"value with spaces\""; \
	echo "📄 Template file: $$TEMPLATE_FILE"; \
	echo "🎯 Target file: $$TARGET_ENV_FILE"; \
	if [ ! -f "$$TARGET_ENV_FILE" ]; then \
		echo "📝 Creating new .env file from template..."; \
		cp "$$TEMPLATE_FILE" "$$TARGET_ENV_FILE"; \
		chmod 600 "$$TARGET_ENV_FILE"; \
		echo "✅ New .env file created!"; \
		exit 0; \
	fi; \
	BACKUP_FILE="$${TARGET_ENV_FILE}.backup.$$(date +%Y%m%d_%H%M%S)"; \
	cp "$$TARGET_ENV_FILE" "$$BACKUP_FILE"; \
	echo "💾 Backup created: $$BACKUP_FILE"; \
	echo "🔍 Analyzing existing environment variables..."; \
	EXISTING_VARS=$$(grep -E '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=' "$$TARGET_ENV_FILE" | sed 's/^[[:space:]]*export[[:space:]]*//' | sed 's/=.*//' | sort -u); \
	EXISTING_EXPORT_VARS=$$(grep -E '^[[:space:]]*export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=' "$$TARGET_ENV_FILE" | sed 's/^[[:space:]]*export[[:space:]]*//' | sed 's/=.*//' | sort -u); \
	echo "🔍 Finding new variables in template..."; \
	TEMPLATE_VARS=$$(grep -E '^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=' "$$TEMPLATE_FILE" | sed 's/^[[:space:]]*export[[:space:]]*//' | sed 's/=.*//' | sort -u); \
	TEMPLATE_EXPORT_VARS=$$(grep -E '^[[:space:]]*export[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=' "$$TEMPLATE_FILE" | sed 's/^[[:space:]]*export[[:space:]]*//' | sed 's/=.*//' | sort -u); \
	NEW_VARS=""; \
	NEW_EXPORT_VARS=""; \
	for var in $$TEMPLATE_VARS; do \
		if ! echo "$$EXISTING_VARS" | grep -q "^$$var$$" && ! echo "$$EXISTING_EXPORT_VARS" | grep -q "^$$var$$"; then \
			NEW_VARS="$$NEW_VARS $$var"; \
		fi; \
	done; \
	for var in $$TEMPLATE_EXPORT_VARS; do \
		if ! echo "$$EXISTING_VARS" | grep -q "^$$var$$" && ! echo "$$EXISTING_EXPORT_VARS" | grep -q "^$$var$$"; then \
			NEW_EXPORT_VARS="$$NEW_EXPORT_VARS $$var"; \
		fi; \
	done; \
	TOTAL_NEW_VARS=$$(echo "$$NEW_VARS $$NEW_EXPORT_VARS" | wc -w | tr -d ' '); \
	if [ "$$TOTAL_NEW_VARS" -eq 0 ]; then \
		echo "✅ No new variables found in template. Your .env is up to date!"; \
		rm "$$BACKUP_FILE"; \
		exit 0; \
	fi; \
	echo "📦 Found $$TOTAL_NEW_VARS new variables to add:"; \
	for var in $$NEW_VARS $$NEW_EXPORT_VARS; do \
		echo "  • $$var"; \
	done; \
	if grep -q "$$MARKER_LINE" "$$TARGET_ENV_FILE"; then \
		INSERTION_LINE=$$(grep -n "$$MARKER_LINE" "$$TARGET_ENV_FILE" | cut -d: -f1); \
		echo "📍 Found marker line at line $$INSERTION_LINE"; \
	else \
		INSERTION_LINE=$$(wc -l < "$$TARGET_ENV_FILE"); \
		echo "📍 Marker line not found, appending to end of file (line $$INSERTION_LINE)"; \
	fi; \
	TEMP_FILE=$$(mktemp); \
	if grep -q "$$MARKER_LINE" "$$TARGET_ENV_FILE"; then \
		sed -n "1,$${INSERTION_LINE}p" "$$TARGET_ENV_FILE" > "$$TEMP_FILE"; \
	else \
		cp "$$TARGET_ENV_FILE" "$$TEMP_FILE"; \
		echo "" >> "$$TEMP_FILE"; \
	fi; \
	echo "" >> "$$TEMP_FILE"; \
	echo "# New variables added from template on $$(date)" >> "$$TEMP_FILE"; \
	for var in $$NEW_VARS; do \
		LINE=$$(grep -E "^[[:space:]]*$$var=" "$$TEMPLATE_FILE" | head -1); \
		if [ -n "$$LINE" ]; then \
			echo "$$LINE" >> "$$TEMP_FILE"; \
			echo "  ✅ Added: $$var"; \
		fi; \
	done; \
	for var in $$NEW_EXPORT_VARS; do \
		LINE=$$(grep -E "^[[:space:]]*export[[:space:]]+$$var=" "$$TEMPLATE_FILE" | head -1); \
		if [ -n "$$LINE" ]; then \
			echo "$$LINE" >> "$$TEMP_FILE"; \
			echo "  ✅ Added: $$var (export)"; \
		fi; \
	done; \
	if grep -q "$$MARKER_LINE" "$$TARGET_ENV_FILE"; then \
		NEXT_LINE=$$((INSERTION_LINE + 1)); \
		sed -n "$${NEXT_LINE},\$$p" "$$TARGET_ENV_FILE" >> "$$TEMP_FILE"; \
	fi; \
	mv "$$TEMP_FILE" "$$TARGET_ENV_FILE"; \
	chmod 600 "$$TARGET_ENV_FILE"; \
	echo ""; \
	echo "✅ Environment merge complete!"; \
	echo "📊 Added $$TOTAL_NEW_VARS new variables to $$TARGET_ENV_FILE"; \
	echo "💾 Backup available at: $$BACKUP_FILE"; \
	echo "🔒 File permissions set to 600 for security"; \
	echo ""; \
	echo "💡 Review the changes and update the new variables with your actual values."

# Set Fish as the default shell
set-fish-default:
	@echo "🐟 Setting Fish as the default shell..."
	@if ! command -v fish >/dev/null 2>&1; then \
		echo "❌ Fish shell not found!"; \
		echo "💡 Install Fish first: brew install fish"; \
		exit 1; \
	fi
	@FISH_PATH=$$(which fish); \
	echo "📍 Fish shell found at: $$FISH_PATH"; \
	if ! grep -q "$$FISH_PATH" /etc/shells; then \
		echo "📝 Adding Fish to /etc/shells..."; \
		echo "$$FISH_PATH" | sudo tee -a /etc/shells >/dev/null; \
		echo "✅ Fish added to /etc/shells"; \
	else \
		echo "✅ Fish already exists in /etc/shells"; \
	fi
	@CURRENT_SHELL=$$(dscl . -read /Users/$$(whoami) UserShell 2>/dev/null | awk '{print $$2}' || echo "unknown"); \
	FISH_PATH=$$(which fish); \
	if [ "$$CURRENT_SHELL" = "$$FISH_PATH" ]; then \
		echo "✅ Fish is already set as the default shell for $$(whoami)"; \
	else \
		echo "🔄 Current default shell: $$CURRENT_SHELL"; \
		echo "🔄 Setting Fish as default shell for $$(whoami)..."; \
		sudo chsh -s "$$FISH_PATH" "$$(whoami)"; \
		echo "✅ Default shell changed to Fish!"; \
		echo "💡 Open a new terminal window to use Fish as your default shell"; \
	fi

# Restore all configurations
restore: copy-configs
	@echo "🔄 Restoring all configurations..."
	@$(MAKE) -s restore-jetbrains
	@echo "✅ All configurations restored!"

# Restore JetBrains IDEs configuration
restore-jetbrains:
	@echo "🧠 Enhanced JetBrains IDEs restore starting..."
	@JETBRAINS_DIR="$$HOME/Library/Application Support/JetBrains"; \
	JETBRAINS_BACKUP_DIR="jetbrains-ides"; \
	if [ ! -d "$$JETBRAINS_BACKUP_DIR" ]; then \
		echo "⚠️  No JetBrains backup found at $$JETBRAINS_BACKUP_DIR"; \
		echo "💡 Run 'make backup' first to create a backup"; \
		exit 0; \
	fi; \
	mkdir -p "$$JETBRAINS_DIR"; \
	echo "📋 Restoring JetBrains IDEs configurations..."; \
	for backup_dir in "$$JETBRAINS_BACKUP_DIR"/*/; do \
		if [ -d "$$backup_dir" ]; then \
			IDE_NAME=$$(basename "$$backup_dir"); \
			if [[ "$$IDE_NAME" == .* ]]; then \
				continue; \
			fi; \
			TARGET_DIR="$$JETBRAINS_DIR/$$IDE_NAME"; \
			echo "🔄 Restoring $$IDE_NAME → $$TARGET_DIR"; \
			mkdir -p "$$TARGET_DIR"; \
			if [ -d "$$backup_dir/codestyles" ]; then \
				echo "  🎨 Restoring code styles"; \
				cp -R "$$backup_dir/codestyles" "$$TARGET_DIR/"; \
			fi; \
			if [ -d "$$backup_dir/options" ]; then \
				echo "  ⚙️  Restoring IDE options"; \
				cp -R "$$backup_dir/options" "$$TARGET_DIR/"; \
			fi; \
			if [ -d "$$backup_dir/keymaps" ]; then \
				echo "  ⌨️  Restoring custom keymaps"; \
				cp -R "$$backup_dir/keymaps" "$$TARGET_DIR/"; \
			fi; \
			if [ -d "$$backup_dir/colors" ]; then \
				echo "  🌈 Restoring color schemes"; \
				cp -R "$$backup_dir/colors" "$$TARGET_DIR/"; \
			fi; \
			if [ -d "$$backup_dir/templates" ]; then \
				echo "  📝 Restoring file templates"; \
				cp -R "$$backup_dir/templates" "$$TARGET_DIR/"; \
			fi; \
			if [ -f "$$backup_dir/disabled_plugins.txt" ]; then \
				echo "  🚫 Restoring disabled plugins list"; \
				cp "$$backup_dir/disabled_plugins.txt" "$$TARGET_DIR/"; \
			fi; \
			for vm_file in "$$backup_dir"/*.vmoptions; do \
				if [ -f "$$vm_file" ]; then \
					echo "  🚀 Restoring VM options: $$(basename "$$vm_file")"; \
					cp "$$vm_file" "$$TARGET_DIR/"; \
				fi; \
			done; \
			if [ -f "$$backup_dir/plugins_list.txt" ]; then \
				echo "  🔌 Plugin list available for $$IDE_NAME"; \
				echo "    💡 Manually reinstall plugins from: $$backup_dir/plugins_list.txt"; \
			fi; \
			echo "  ✅ $$IDE_NAME restoration complete"; \
		fi; \
	done; \
	if [ -f "$$JETBRAINS_BACKUP_DIR/.ideavimrc" ]; then \
		echo "⌨️  Restoring shared .ideavimrc"; \
		cp "$$JETBRAINS_BACKUP_DIR/.ideavimrc" "$$HOME/"; \
	fi; \
	if [ -f "$$JETBRAINS_BACKUP_DIR/idea.vmoptions" ]; then \
		echo "🚀 Restoring global VM options"; \
		cp "$$JETBRAINS_BACKUP_DIR/idea.vmoptions" "$$JETBRAINS_DIR/"; \
	fi
	@echo "✅ Enhanced JetBrains IDEs restore complete!"
	@echo ""
	@echo "📋 Manual steps required:"
	@echo "1. Launch each IDE and reinstall plugins from the plugins_list.txt files"
	@echo "2. Restart IDEs to ensure all configurations are loaded"
	@echo "3. Verify your settings in each IDE's preferences"

# Restore macOS system settings
restore-macos:
	@echo "🍎 Restoring macOS system settings..."
	@if [ -d "macos" ] && [ -f "macos/restore_macos_settings.sh" ]; then \
		cd macos && ./restore_macos_settings.sh; \
	else \
		echo "⚠️  No macOS backup found or restore script missing"; \
		echo "💡 Run 'make backup-macos' first to create a backup"; \
		exit 0; \
	fi

# Install/restore macOS configurations (alias for restore-macos)
macos: restore-macos
