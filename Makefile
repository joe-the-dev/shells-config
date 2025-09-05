.PHONY: all install copy-configs brew asdf jetbrains iterm2 omf env help clean \
	check-deps upgrade-deps backup restore restore-jetbrains \
	install-jetbrains-plugins update install-packages

# Default target
all: install

# Detect OS and set platform-specific variables
SHELL := /bin/bash
OS := $(shell ./scripts/detect_os.sh)
PLATFORM_DIR := platforms/$(OS)

# Main installation target
install: update check-deps copy-configs install-packages asdf jetbrains terminal omf env
	@echo "🎉 All configurations installed successfully for $(OS)!"

# Help target
help:
	@echo "Available targets:"
	@echo "  all              - Install all configurations (default)"
	@echo "  install          - Same as 'all'"
	@echo "  update           - Update git repository"
	@echo "  copy-configs     - Copy dotfiles to home directory"
	@echo "  brew             - Install Homebrew packages"
	@echo "  asdf             - Install asdf plugins and tools"
	@echo "  jetbrains        - Install JetBrains IDEs configuration"
	@echo "  iterm2           - Install iTerm2 configuration"
	@echo "  omf              - Install Oh My Fish configuration"
	@echo "  env              - Setup environment variables"
	@echo "  check-deps       - Check for required dependencies"
	@echo "  upgrade-deps     - Upgrade all package managers and tools"
	@echo "  backup           - Run backup script"
	@echo "  restore          - Restore all configurations"
	@echo "  restore-jetbrains - Restore only JetBrains IDEs configuration"
	@echo "  clean            - Clean up old versions and cache files"
	@echo "  help             - Show this help message"

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

# Platform-specific package installation
install-packages:
	@echo "📦 Installing packages for $(OS)..."
	@if [ "$(OS)" = "macos" ]; then \
		$(MAKE) -s brew; \
	elif [ "$(OS)" = "ubuntu" ]; then \
		$(MAKE) -s ubuntu-packages; \
	elif [ "$(OS)" = "manjaro" ]; then \
		$(MAKE) -s manjaro-packages; \
	else \
		echo "⚠️  Package installation not configured for $(OS)"; \
	fi

# macOS Homebrew packages (renamed from brew target)
brew:
	@echo "🍺 Installing Homebrew packages..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "⚠️  Homebrew not found - please install Homebrew first"; \
		echo "💡 Install from: https://brew.sh"; \
		exit 1; \
	fi
	@if [ -f "$(PLATFORM_DIR)/brew/Brewfile" ]; then \
		echo "📦 Installing packages..."; \
		brew bundle install --file=$(PLATFORM_DIR)/brew/Brewfile --verbose || \
		(echo "⚠️  Some packages may have failed - this might be normal for packages requiring sudo"; \
		 echo "💡 You can manually run: brew bundle install --file=$(PLATFORM_DIR)/brew/Brewfile"); \
	else \
		echo "⚠️  $(PLATFORM_DIR)/brew/Brewfile not found"; \
	fi

# Ubuntu/Debian package installation
ubuntu-packages:
	@echo "🐧 Installing Ubuntu/Debian packages..."
	@if [ -f "$(PLATFORM_DIR)/packages.txt" ]; then \
		echo "📦 Installing packages from $(PLATFORM_DIR)/packages.txt..."; \
		sudo apt update; \
		sudo apt install -y $$(grep -v '^#' "$(PLATFORM_DIR)/packages.txt" | grep -v '^$$' | tr '\n' ' '); \
		echo "✅ Ubuntu packages installed"; \
	else \
		echo "⚠️  $(PLATFORM_DIR)/packages.txt not found"; \
	fi

# Manjaro/Arch package installation
manjaro-packages:
	@echo "🏔️  Installing Manjaro/Arch packages..."
	@if [ -f "$(PLATFORM_DIR)/packages.txt" ]; then \
		echo "📦 Installing packages from $(PLATFORM_DIR)/packages.txt..."; \
		sudo pacman -Syu --needed $$(grep -v '^#' "$(PLATFORM_DIR)/packages.txt" | grep -v '^$$' | tr '\n' ' '); \
		echo "✅ Manjaro packages installed"; \
	else \
		echo "⚠���  $(PLATFORM_DIR)/packages.txt not found"; \
	fi

# Platform-specific terminal configuration
terminal:
	@echo "🖥️  Setting up terminal for $(OS)..."
	@if [ "$(OS)" = "macos" ]; then \
		$(MAKE) -s iterm2; \
	elif [ "$(OS)" = "ubuntu" ] || [ "$(OS)" = "manjaro" ] || [ "$(OS)" = "linux" ]; then \
		$(MAKE) -s linux-terminal; \
	else \
		echo "⚠️  Terminal configuration not available for $(OS)"; \
	fi

# Linux terminal configuration
linux-terminal:
	@echo "🐧 Setting up Linux terminal configuration..."
	@if [ -f "platforms/linux/terminal_config.sh" ]; then \
		echo "📋 Applying terminal configuration..."; \
		cat platforms/linux/terminal_config.sh >> "$$HOME/.bashrc"; \
		echo "✅ Terminal configuration added to ~/.bashrc"; \
	else \
		echo "⚠️  Linux terminal config not found"; \
	fi

# Platform-aware JetBrains installation
jetbrains:
	@echo "🧠 Installing JetBrains IDEs configuration..."
	@JETBRAINS_BACKUP_DIR="$(PLATFORM_DIR)/jetbrains-ides"; \
	if [ ! -d "$$JETBRAINS_BACKUP_DIR" ]; then \
		echo "⚠️  No JetBrains backup found at $$JETBRAINS_BACKUP_DIR"; \
		echo "💡 Run 'make backup' first to create a backup"; \
		exit 0; \
	fi; \
	if [ "$(OS)" = "macos" ]; then \
		$(MAKE) -s restore-jetbrains; \
		$(MAKE) -s install-jetbrains-plugins; \
	else \
		echo "⚠️  JetBrains plugin installation only supported on macOS currently"; \
		$(MAKE) -s restore-jetbrains; \
	fi
	@echo "✅ JetBrains IDEs configuration installed!"

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
	@echo "🔌 Installing asdf plugins and tools..."
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

# Install JetBrains plugins automatically using CLI
install-jetbrains-plugins:
	@echo "🔌 Installing JetBrains plugins from backup..."
	@if [ "$(OS)" = "macos" ]; then \
		JETBRAINS_DIR="$$HOME/Library/Application Support/JetBrains"; \
		JETBRAINS_BACKUP_DIR="$(PLATFORM_DIR)/jetbrains-ides"; \
	else \
		JETBRAINS_DIR="$$HOME/.local/share/JetBrains"; \
		JETBRAINS_BACKUP_DIR="$(PLATFORM_DIR)/jetbrains-ides"; \
	fi; \
	if [ ! -d "$$JETBRAINS_BACKUP_DIR" ]; then \
		echo "⚠️  No JetBrains backup found at $$JETBRAINS_BACKUP_DIR"; \
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
					if [ "$(OS)" = "macos" ]; then \
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
					else \
						echo "    ℹ️  Plugin CLI installation not supported on $(OS), manual installation required"; \
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

# Install iTerm2 configuration (macOS only)
iterm2:
	@echo "🖥️  Installing iTerm2 configuration..."
	@if [ "$(OS)" != "macos" ]; then \
		echo "⚠️  iTerm2 is only available on macOS"; \
		exit 0; \
	fi
	@if [ ! -d "$(PLATFORM_DIR)/iterm2" ]; then \
		echo "⚠️  No iTerm2 config found at $(PLATFORM_DIR)/iterm2"; \
		exit 0; \
	fi
	@if pgrep -x "iTerm2" > /dev/null; then \
		echo "⚠️  iTerm2 is currently running. Please close it first."; \
		exit 0; \
	fi
	@if [ -f "$(PLATFORM_DIR)/iterm2/com.googlecode.iterm2.plist" ]; then \
		echo "📋 Restoring iTerm2 preferences..."; \
		cp "$(PLATFORM_DIR)/iterm2/com.googlecode.iterm2.plist" "$$HOME/Library/Preferences/"; \
	fi
	@ITERM2_APP_SUPPORT="$$HOME/Library/Application Support/iTerm2"; \
	mkdir -p "$$ITERM2_APP_SUPPORT"; \
	if [ -d "$(PLATFORM_DIR)/iterm2/DynamicProfiles" ]; then \
		echo "🎨 Restoring Dynamic Profiles..."; \
		cp -R "$(PLATFORM_DIR)/iterm2/DynamicProfiles" "$$ITERM2_APP_SUPPORT/"; \
	fi; \
	if [ -d "$(PLATFORM_DIR)/iterm2/Scripts" ]; then \
		echo "📜 Restoring iTerm2 Scripts..."; \
		cp -R "$(PLATFORM_DIR)/iterm2/Scripts" "$$ITERM2_APP_SUPPORT/"; \
	fi; \
	if [ -f "$(PLATFORM_DIR)/iterm2/version.txt" ]; then \
		cp "$(PLATFORM_DIR)/iterm2/version.txt" "$$ITERM2_APP_SUPPORT/"; \
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
			fish -c "omf install $$package" || echo "⚠���  Failed to install $$package"; \
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
	@if [ ! -f "env/template.env" ]; then \
		echo "❌ env/template.env not found!"; \
		exit 1; \
	fi
	@if [ -f "$$HOME/.env" ]; then \
		echo "⚠️  ~/.env already exists!"; \
		echo "Creating backup..."; \
		cp "$$HOME/.env" "$$HOME/.env.backup.$$(date +%Y%m%d_%H%M%S)"; \
		echo "✅ Backup created"; \
	fi
	@echo "📄 Copying .env template to ~/.env..."
	@cp "env/template.env" "$$HOME/.env"
	@chmod 600 "$$HOME/.env"
	@echo "🔒 Set secure permissions (600) on ~/.env"
	@echo "✅ Environment template installed!"
	@echo "💡 Edit ~/.env with your actual credentials"

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
		echo "��� Upgrading asdf..."; \
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

# Run backup script
backup:
	@echo "💾 Running backup..."
	@if [ -f "backup.sh" ]; then \
		./backup.sh; \
	else \
		echo "❌ backup.sh not found"; \
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

# Clean up temporary files
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
