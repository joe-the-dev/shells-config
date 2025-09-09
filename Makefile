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

# Include sub-makefiles
include makefiles/install.mk
include makefiles/backup.mk
include makefiles/utils.mk

# Export variables to sub-makefiles
export HOME_DIR CONFIG_DIR JETBRAINS_DIR ITERM2_APP_SUPPORT BACKUP_TIMESTAMP
export SRC_BREW SRC_ASDF_RC SRC_ASDF_TOOLS SRC_GITCONFIG SRC_GITIGNORE
export TARGET_BREWFILE TARGET_ASDF_RC TARGET_ASDF_TOOLS TARGET_GITCONFIG TARGET_GITIGNORE
export BLUE GREEN YELLOW RED RESET

.PHONY: all install help

# Default target
all: install

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
	@echo "💡 Examples:"
	@echo "  make install-minimal  # Quick setup with essentials"
	@echo "  make backup          # Full backup"
	@echo "  make backup-apps     # Apps only"
	@echo "  make restore         # Full restore"
