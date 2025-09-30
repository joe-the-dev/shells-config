# Main Makefile - Entry point and orchestration
# This file includes other Makefiles and provides the main interface

# Configuration variables
HOME_DIR := $(HOME)
CONFIG_DIR := $(HOME_DIR)/.config
JETBRAINS_DIR := $(HOME_DIR)/Library/Application Support/JetBrains
ITERM2_APP_SUPPORT := $(HOME_DIR)/Library/Application Support/iTerm2
BACKUP_TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Source directories
SRC_BREW := brew/Brewfile
SRC_ASDF_RC := asdf/.asdfrc
SRC_ASDF_TOOLS := asdf/.tool-versions
SRC_GITCONFIG := gitconfig/.gitconfig
SRC_GITIGNORE := gitconfig/.gitignore_global

# Target files
TARGET_BREWFILE := $(HOME_DIR)/.Brewfile
TARGET_ASDF_RC := $(HOME_DIR)/.asdfrc
TARGET_ASDF_TOOLS := $(HOME_DIR)/.tool-versions
TARGET_GITCONFIG := $(HOME_DIR)/.gitconfig
TARGET_GITIGNORE := $(HOME_DIR)/.gitignore_global

# Colors for output
BLUE := \033[34m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Include configuration system first
include makefiles/config.mk

# Include sub-makefiles
include makefiles/install.mk
include makefiles/backup.mk
include makefiles/utils.mk

# Export variables to sub-makefiles (fixed syntax)
export HOME_DIR
export CONFIG_DIR
export JETBRAINS_DIR
export ITERM2_APP_SUPPORT
export BACKUP_TIMESTAMP
export SRC_BREW
export SRC_ASDF_RC
export SRC_ASDF_TOOLS
export SRC_GITCONFIG
export SRC_GITIGNORE
export TARGET_BREWFILE
export TARGET_ASDF_RC
export TARGET_ASDF_TOOLS
export TARGET_GITCONFIG
export TARGET_GITIGNORE
export BLUE
export GREEN
export YELLOW
export RED
export RESET

.PHONY: all install help show-config configure-ci configure-minimal configure-dev configure-reset
.PHONY: macos

# Default target
all: install

# Alias for macOS restore
macos: restore-macos

# Help target - shows all available commands
help:
	@echo "🔧 Available commands:"
	@echo ""
	@echo "📥 Installation & Setup:"
	@echo "  all              - Install all configurations (default)"
	@echo "  install          - Same as 'all'"
	@echo "  install-minimal  - Install only essential configs (git, fish, nvim)"
	@echo "  install-dev      - Install development tools (brew, asdf, jetbrains)"
	@echo "  install-tools    - Install productivity tools (karabiner, hammerspoon, iterm2)"
	@echo ""
	@echo "📦 Individual Components:"
	@echo "  copy-configs     - Copy dotfiles to home directory"
	@echo "  brew             - Install Homebrew packages"
	@echo "  asdf             - Install asdf plugins and tools"
	@echo "  jetbrains        - Install JetBrains IDEs configuration"
	@echo "  iterm2           - Install iTerm2 configuration"
	@echo "  omf              - Install Oh My Fish configuration"
	@echo "  env              - Setup environment variables"
	@echo "  set-fish-default - Set Fish as the default shell"
	@echo ""
	@echo "💾 Backup & Restore:"
	@echo "  backup           - Run complete backup (apps + macOS)"
	@echo "  backup-apps      - Backup application configurations only"
	@echo "  backup-macos     - Backup macOS system settings only"
	@echo "  backup-sync      - Backup and sync to git"
	@echo "  restore          - Restore all configurations"
	@echo "  restore-jetbrains - Restore only JetBrains IDEs configuration"
	@echo "  restore-macos    - Restore macOS system settings"
	@echo "  macos            - Install/restore macOS configurations"
	@echo ""
	@echo "🛠️  Utilities & Maintenance:"
	@echo "  update           - Update git repository"
	@echo "  check-deps       - Check for required dependencies"
	@echo "  upgrade-deps     - Upgrade all package managers and tools"
	@echo "  clean            - Clean up old versions and cache files"
	@echo "  status           - Show current configuration status"
	@echo "  dry-run          - Show what would be installed without doing it"
	@echo "  validate-config  - Validate configuration files"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "⚙️  Configuration Management:"
	@echo "  show-config      - Display current feature flag settings"
	@echo "  configure-ci     - Set up configuration for CI/CD environments"
	@echo "  configure-minimal - Set up minimal configuration (essentials only)"
	@echo "  configure-dev    - Set up full development configuration"
	@echo "  configure-reset  - Reset all configuration to defaults"
	@echo ""
	@echo "💡 Examples:"
	@echo "  make install-minimal  # Quick setup with essentials"
	@echo "  make backup          # Full backup"
	@echo "  make backup-apps     # Apps only"
	@echo "  make restore         # Full restore"
	@echo "  make show-config     # View current settings"
	@echo "  make configure-ci    # Optimize for CI/CD"

# Configuration preset targets
configure-ci:
	@echo "🔧 Configuring for CI/CD environment..."
	@mkdir -p config
	@cp config/features.conf config/features.conf.backup 2>/dev/null || true
	@echo "# CI/CD optimized configuration" > config/features.conf
	@echo "ENABLE_BREW_INSTALL=true" >> config/features.conf
	@echo "ENABLE_ASDF_INSTALL=true" >> config/features.conf
	@echo "ENABLE_JETBRAINS_INSTALL=false" >> config/features.conf
	@echo "ENABLE_ITERM2_INSTALL=false" >> config/features.conf
	@echo "ENABLE_OMF_INSTALL=true" >> config/features.conf
	@echo "ENABLE_KARABINER_INSTALL=false" >> config/features.conf
	@echo "ENABLE_HAMMERSPOON_INSTALL=false" >> config/features.conf
	@echo "ENABLE_NVIM_INSTALL=true" >> config/features.conf
	@echo "ENABLE_APPS_BACKUP=false" >> config/features.conf
	@echo "ENABLE_MACOS_BACKUP=false" >> config/features.conf
	@echo "ENABLE_JETBRAINS_BACKUP=false" >> config/features.conf
	@echo "ENABLE_ITERM2_BACKUP=false" >> config/features.conf
	@echo "ENABLE_KARABINER_BACKUP=false" >> config/features.conf
	@echo "SKIP_HEAVY_OPERATIONS=true" >> config/features.conf
	@echo "DRY_RUN_MODE=false" >> config/features.conf
	@echo "VERBOSE_OUTPUT=true" >> config/features.conf
	@echo "CI_MODE=true" >> config/features.conf
	@echo "SKIP_INTERACTIVE=true" >> config/features.conf
	@echo "PARALLEL_EXECUTION=true" >> config/features.conf
	@echo "MINIMAL_MODE=false" >> config/features.conf
	@echo "✅ CI/CD configuration applied"

configure-minimal:
	@echo "🔧 Configuring for minimal setup..."
	@mkdir -p config
	@cp config/features.conf config/features.conf.backup 2>/dev/null || true
	@echo "# Minimal configuration - essentials only" > config/features.conf
	@echo "ENABLE_BREW_INSTALL=false" >> config/features.conf
	@echo "ENABLE_ASDF_INSTALL=true" >> config/features.conf
	@echo "ENABLE_JETBRAINS_INSTALL=false" >> config/features.conf
	@echo "ENABLE_ITERM2_INSTALL=false" >> config/features.conf
	@echo "ENABLE_OMF_INSTALL=true" >> config/features.conf
	@echo "ENABLE_KARABINER_INSTALL=false" >> config/features.conf
	@echo "ENABLE_HAMMERSPOON_INSTALL=false" >> config/features.conf
	@echo "ENABLE_NVIM_INSTALL=true" >> config/features.conf
	@echo "ENABLE_APPS_BACKUP=false" >> config/features.conf
	@echo "ENABLE_MACOS_BACKUP=false" >> config/features.conf
	@echo "ENABLE_JETBRAINS_BACKUP=false" >> config/features.conf
	@echo "ENABLE_ITERM2_BACKUP=false" >> config/features.conf
	@echo "ENABLE_KARABINER_BACKUP=false" >> config/features.conf
	@echo "SKIP_HEAVY_OPERATIONS=true" >> config/features.conf
	@echo "DRY_RUN_MODE=false" >> config/features.conf
	@echo "VERBOSE_OUTPUT=false" >> config/features.conf
	@echo "CI_MODE=false" >> config/features.conf
	@echo "MINIMAL_MODE=true" >> config/features.conf
	@echo "✅ Minimal configuration applied"

configure-dev:
	@echo "🔧 Configuring for full development setup..."
	@mkdir -p config
	@cp config/features.conf config/features.conf.backup 2>/dev/null || true
	@echo "# Full development configuration" > config/features.conf
	@echo "ENABLE_BREW_INSTALL=true" >> config/features.conf
	@echo "ENABLE_ASDF_INSTALL=true" >> config/features.conf
	@echo "ENABLE_JETBRAINS_INSTALL=true" >> config/features.conf
	@echo "ENABLE_ITERM2_INSTALL=true" >> config/features.conf
	@echo "ENABLE_OMF_INSTALL=true" >> config/features.conf
	@echo "ENABLE_KARABINER_INSTALL=true" >> config/features.conf
	@echo "ENABLE_HAMMERSPOON_INSTALL=true" >> config/features.conf
	@echo "ENABLE_NVIM_INSTALL=true" >> config/features.conf
	@echo "ENABLE_APPS_BACKUP=true" >> config/features.conf
	@echo "ENABLE_MACOS_BACKUP=true" >> config/features.conf
	@echo "ENABLE_JETBRAINS_BACKUP=true" >> config/features.conf
	@echo "ENABLE_ITERM2_BACKUP=true" >> config/features.conf
	@echo "ENABLE_KARABINER_BACKUP=true" >> config/features.conf
	@echo "SKIP_HEAVY_OPERATIONS=false" >> config/features.conf
	@echo "DRY_RUN_MODE=false" >> config/features.conf
	@echo "VERBOSE_OUTPUT=false" >> config/features.conf
	@echo "CI_MODE=false" >> config/features.conf
	@echo "MINIMAL_MODE=false" >> config/features.conf
	@echo "✅ Full development configuration applied"

configure-reset:
	@echo "🔄 Resetting configuration to defaults..."
	@if [ -f config/features.conf.backup ]; then \
		mv config/features.conf.backup config/features.conf; \
		echo "✅ Configuration restored from backup"; \
	else \
		git checkout config/features.conf 2>/dev/null || echo "❌ No backup found, manual reset required"; \
	fi
