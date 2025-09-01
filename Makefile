.PHONY: all install copy-configs brew asdf intellij iterm2 omf env help clean check-deps upgrade-deps backup

# Default target
all: install

# Main installation target
install: check-deps copy-configs brew asdf intellij iterm2 omf env
	@echo "🎉 All configurations installed successfully!"

# Help target
help:
	@echo "Available targets:"
	@echo "  all          - Install all configurations (default)"
	@echo "  install      - Same as 'all'"
	@echo "  copy-configs - Copy dotfiles to home directory"
	@echo "  brew         - Install Homebrew packages"
	@echo "  asdf         - Install asdf plugins and tools"
	@echo "  intellij     - Install IntelliJ IDEA configuration"
	@echo "  iterm2       - Install iTerm2 configuration"
	@echo "  omf          - Install Oh My Fish configuration"
	@echo "  env          - Setup environment variables"
	@echo "  check-deps   - Check for required dependencies"
	@echo "  upgrade-deps - Upgrade all package managers and tools"
	@echo "  backup       - Run backup script"
	@echo "  clean        - Clean up temporary files"
	@echo "  help         - Show this help message"

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

# Install IntelliJ IDEA configuration
intellij:
	@echo "🧠 Installing IntelliJ IDEA configuration..."
	@if [ ! -d "intellij" ]; then \
		echo "⚠️  No IntelliJ config found"; \
		exit 0; \
	fi
	@INTELLIJ_VERSIONS_DIR="$$HOME/Library/Application Support/JetBrains"; \
	mkdir -p "$$INTELLIJ_VERSIONS_DIR"; \
	if [ -f "intellij/intellij_version.txt" ]; then \
		INTELLIJ_VERSION=$$(cat "intellij/intellij_version.txt"); \
		INTELLIJ_DIR="$$INTELLIJ_VERSIONS_DIR/$$INTELLIJ_VERSION"; \
		echo "📋 Restoring to specific version: $$INTELLIJ_VERSION"; \
	else \
		INTELLIJ_DIR=$$(find "$$INTELLIJ_VERSIONS_DIR" -name "IntelliJIdea*" -type d | sort -V | tail -1); \
		if [ -z "$$INTELLIJ_DIR" ]; then \
			INTELLIJ_DIR="$$INTELLIJ_VERSIONS_DIR/IntelliJIdea2025.2"; \
			echo "📋 Creating new config directory: IntelliJIdea2025.2"; \
		else \
			echo "📋 Using existing IntelliJ directory: $$(basename "$$INTELLIJ_DIR")"; \
		fi; \
	fi; \
	mkdir -p "$$INTELLIJ_DIR"; \
	if [ -d "intellij/codestyles" ]; then \
		echo "🎨 Restoring code styles..."; \
		cp -R "intellij/codestyles" "$$INTELLIJ_DIR/"; \
	fi; \
	if [ -d "intellij/options" ]; then \
		echo "⚙️  Restoring IDE options..."; \
		cp -R "intellij/options" "$$INTELLIJ_DIR/"; \
	fi; \
	if [ -f "intellij/idea.vmoptions" ]; then \
		echo "🚀 Restoring JVM options..."; \
		cp "intellij/idea.vmoptions" "$$INTELLIJ_DIR/"; \
	fi; \
	if [ -f "intellij/disabled_plugins.txt" ]; then \
		echo "🔌 Restoring disabled plugins list..."; \
		cp "intellij/disabled_plugins.txt" "$$INTELLIJ_DIR/"; \
	fi; \
	if [ -f "intellij/plugins_list.txt" ]; then \
		echo "🔌 Plugin list available at intellij/plugins_list.txt"; \
		echo "💡 Please reinstall these plugins manually from JetBrains Marketplace"; \
	fi; \
	if [ -f "intellij/.ideavimrc" ]; then \
		echo "⌨️  Restoring .ideavimrc..."; \
		cp "intellij/.ideavimrc" "$$HOME/"; \
	fi
	@echo "✅ IntelliJ IDEA configuration restored!"

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
	@ITERM2_APP_SUPPORT="$$HOME/Library/Application Support/iTerm2"; \
	mkdir -p "$$ITERM2_APP_SUPPORT"; \
	if [ -d "iterm2/DynamicProfiles" ]; then \
		echo "🎨 Restoring Dynamic Profiles..."; \
		cp -R "iterm2/DynamicProfiles" "$$ITERM2_APP_SUPPORT/"; \
	fi; \
	if [ -d "iterm2/Scripts" ]; then \
		echo "📜 Restoring iTerm2 Scripts..."; \
		cp -R "iterm2/Scripts" "$$ITERM2_APP_SUPPORT/"; \
	fi; \
	if [ -f "iterm2/version.txt" ]; then \
		cp "iterm2/version.txt" "$$ITERM2_APP_SUPPORT/"; \
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

# Run backup script
backup:
	@echo "💾 Running backup..."
	@if [ -f "backup.sh" ]; then \
		./backup.sh; \
	else \
		echo "❌ backup.sh not found"; \
	fi

# Clean up temporary files
clean:
	@echo "🧹 Cleaning up..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "✅ Cleanup complete!"
