# Main Makefile - Entry point and orchestration
# This file includes other Makefiles and provides the main interface

# Configuration variables
HOME_DIR := $(HOME)
CONFIG_DIR := $(HOME_DIR)/.config
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
include makefiles/dependencies.mk

# Export variables to sub-makefiles
export HOME_DIR CONFIG_DIR ITERM2_APP_SUPPORT BACKUP_TIMESTAMP
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
	@echo "  install-dev      - Install development tools (brew, asdf)"
	@echo "  install-tools    - Install productivity tools (karabiner, hammerspoon, iterm2)"
	@echo "  install-smart    - Smart install with automatic dependency resolution"
	@echo "  show-dependency-graph - Show the installation dependency graph"
	@echo ""
	@echo "📦 Individual Components:"
	@echo "  copy-configs     - Copy dotfiles to home directory"
	@echo "  brew             - Install Homebrew packages"
	@echo "  asdf             - Install asdf plugins and tools"
	@echo "  iterm2           - Install iTerm2 configuration"
	@echo "  omf              - Install Oh My Fish configuration"
	@echo "  env              - Setup environment variables"
	@echo "  set-fish-default - Set Fish as the default shell"
	@echo ""
	@echo "💾 Backup & Restore:"
	@echo "  backup           - Run complete backup"
	@echo "  backup-apps      - Backup application configurations only"
	@echo "  restore          - Restore all configurations"
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
