# Configuration utilities for shells-config
# This file provides functions to load and check feature flags

CONFIG_FILE := config/features.conf
CONFIG_LOADED := false

# Load configuration if it exists
ifneq ($(wildcard $(CONFIG_FILE)),)
    include $(CONFIG_FILE)
    CONFIG_LOADED := true
endif

# Environment variable overrides (CI/CD friendly)
ENABLE_BREW_INSTALL := $(or $(ENABLE_BREW_INSTALL),$(ENV_ENABLE_BREW_INSTALL),true)
ENABLE_ASDF_INSTALL := $(or $(ENABLE_ASDF_INSTALL),$(ENV_ENABLE_ASDF_INSTALL),true)
ENABLE_JETBRAINS_INSTALL := $(or $(ENABLE_JETBRAINS_INSTALL),$(ENV_ENABLE_JETBRAINS_INSTALL),true)
ENABLE_ITERM2_INSTALL := $(or $(ENABLE_ITERM2_INSTALL),$(ENV_ENABLE_ITERM2_INSTALL),true)
ENABLE_OMF_INSTALL := $(or $(ENABLE_OMF_INSTALL),$(ENV_ENABLE_OMF_INSTALL),true)
ENABLE_KARABINER_INSTALL := $(or $(ENABLE_KARABINER_INSTALL),$(ENV_ENABLE_KARABINER_INSTALL),true)
ENABLE_HAMMERSPOON_INSTALL := $(or $(ENABLE_HAMMERSPOON_INSTALL),$(ENV_ENABLE_HAMMERSPOON_INSTALL),true)
ENABLE_NVIM_INSTALL := $(or $(ENABLE_NVIM_INSTALL),$(ENV_ENABLE_NVIM_INSTALL),true)

# Backup flags
ENABLE_APPS_BACKUP := $(or $(ENABLE_APPS_BACKUP),$(ENV_ENABLE_APPS_BACKUP),true)
ENABLE_MACOS_BACKUP := $(or $(ENABLE_MACOS_BACKUP),$(ENV_ENABLE_MACOS_BACKUP),true)
ENABLE_JETBRAINS_BACKUP := $(or $(ENABLE_JETBRAINS_BACKUP),$(ENV_ENABLE_JETBRAINS_BACKUP),true)
ENABLE_ITERM2_BACKUP := $(or $(ENABLE_ITERM2_BACKUP),$(ENV_ENABLE_ITERM2_BACKUP),true)
ENABLE_KARABINER_BACKUP := $(or $(ENABLE_KARABINER_BACKUP),$(ENV_ENABLE_KARABINER_BACKUP),true)

# Mode flags
SKIP_HEAVY_OPERATIONS := $(or $(SKIP_HEAVY_OPERATIONS),$(ENV_SKIP_HEAVY_OPERATIONS),false)
DRY_RUN_MODE := $(or $(DRY_RUN_MODE),$(ENV_DRY_RUN_MODE),false)
VERBOSE_OUTPUT := $(or $(VERBOSE_OUTPUT),$(ENV_VERBOSE_OUTPUT),false)
CI_MODE := $(or $(CI_MODE),$(ENV_CI_MODE),false)
MINIMAL_MODE := $(or $(MINIMAL_MODE),$(ENV_MINIMAL_MODE),false)

# Function to check if a feature is enabled
define check_feature_enabled
$(if $(filter true,$(1)),true,false)
endef

# Function to conditionally execute command
define conditional_exec
@if [ "$(call check_feature_enabled,$(1))" = "true" ]; then \
    if [ "$(DRY_RUN_MODE)" = "true" ]; then \
        echo "[DRY RUN] $(2)"; \
    else \
        if [ "$(VERBOSE_OUTPUT)" = "true" ]; then \
            echo "$(GREEN)✓ Executing: $(2)$(RESET)"; \
        fi; \
        $(2); \
    fi; \
else \
    echo "$(YELLOW)⏭️  Skipping: $(3) (disabled by config)$(RESET)"; \
fi
endef

# Function to show configuration status
.PHONY: show-config
show-config:
	@echo "📋 Current Configuration:"
	@echo ""
	@echo "🔧 Installation Features:"
	@echo "  Brew: $(ENABLE_BREW_INSTALL)"
	@echo "  ASDF: $(ENABLE_ASDF_INSTALL)"
	@echo "  JetBrains: $(ENABLE_JETBRAINS_INSTALL)"
	@echo "  iTerm2: $(ENABLE_ITERM2_INSTALL)"
	@echo "  OMF: $(ENABLE_OMF_INSTALL)"
	@echo "  Karabiner: $(ENABLE_KARABINER_INSTALL)"
	@echo "  Hammerspoon: $(ENABLE_HAMMERSPOON_INSTALL)"
	@echo "  Neovim: $(ENABLE_NVIM_INSTALL)"
	@echo ""
	@echo "💾 Backup Features:"
	@echo "  Apps: $(ENABLE_APPS_BACKUP)"
	@echo "  macOS: $(ENABLE_MACOS_BACKUP)"
	@echo "  JetBrains: $(ENABLE_JETBRAINS_BACKUP)"
	@echo "  iTerm2: $(ENABLE_ITERM2_BACKUP)"
	@echo "  Karabiner: $(ENABLE_KARABINER_BACKUP)"
	@echo ""
	@echo "⚙️  Mode Settings:"
	@echo "  Skip Heavy Operations: $(SKIP_HEAVY_OPERATIONS)"
	@echo "  Dry Run Mode: $(DRY_RUN_MODE)"
	@echo "  Verbose Output: $(VERBOSE_OUTPUT)"
	@echo "  CI Mode: $(CI_MODE)"
	@echo "  Minimal Mode: $(MINIMAL_MODE)"
	@echo ""
	@echo "📁 Config File: $(if $(CONFIG_LOADED),✅ Loaded from $(CONFIG_FILE),❌ Not found)"

# Export variables for sub-makefiles
export ENABLE_BREW_INSTALL ENABLE_ASDF_INSTALL ENABLE_JETBRAINS_INSTALL
export ENABLE_ITERM2_INSTALL ENABLE_OMF_INSTALL ENABLE_KARABINER_INSTALL
export ENABLE_HAMMERSPOON_INSTALL ENABLE_NVIM_INSTALL
export ENABLE_APPS_BACKUP ENABLE_MACOS_BACKUP ENABLE_JETBRAINS_BACKUP
export ENABLE_ITERM2_BACKUP ENABLE_KARABINER_BACKUP
export SKIP_HEAVY_OPERATIONS DRY_RUN_MODE VERBOSE_OUTPUT CI_MODE MINIMAL_MODE
