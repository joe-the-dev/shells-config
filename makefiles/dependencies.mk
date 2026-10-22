# Dependency Graph System for Installation
# Defines installation order based on dependencies

# Define dependency relationships
# Format: target: dependencies (space-separated)
DEPENDENCY_MAP := \
	update: \
	brew: update \
	_copy-git: update \
	_copy-env: update \
	copy-configs: _copy-git _copy-env \
	_copy-fish: copy-configs \
	asdf: brew _copy-fish \
	omf: _copy-fish \
	iterm2: brew \
	env: _copy-env \
	set-fish-default: _copy-fish omf

# Installation phases with dependencies resolved
PHASE_1_TARGETS := update _copy-git _copy-env
PHASE_2_TARGETS := brew copy-configs
PHASE_3_TARGETS := _copy-fish asdf
PHASE_4_TARGETS := omf iterm2 env
PHASE_5_TARGETS := set-fish-default

# Function to check if target needs to be skipped
define check_skip_condition
	@if [ "$(1)" = "brew" ] && command -v brew >/dev/null 2>&1; then \
		echo "ℹ️  Homebrew already installed, skipping"; \
		exit 0; \
	fi; \
	if [ "$(1)" = "asdf" ] && command -v asdf >/dev/null 2>&1; then \
		echo "ℹ️  ASDF already installed, checking plugins only"; \
	fi
endef

# Function to validate dependencies
define validate_dependencies
	@echo "🔍 Validating dependencies for $(1)..."
	@case "$(1)" in \
		omf) \
			if ! command -v fish >/dev/null 2>&1; then \
				echo "❌ Fish shell required for OMF installation"; \
				echo "💡 Run: make install-fish first"; \
				exit 1; \
			fi ;; \
		asdf) \
			if ! command -v brew >/dev/null 2>&1; then \
				echo "❌ Homebrew required for ASDF installation"; \
				echo "💡 Run: make brew first"; \
				exit 1; \
			fi ;; \
		set-fish-default) \
			if ! command -v fish >/dev/null 2>&1; then \
				echo "❌ Fish shell required to set as default"; \
				echo "💡 Run: make install-fish first"; \
				exit 1; \
			fi ;; \
	esac
endef

# Smart installation with dependency resolution
install-smart:
	@echo "🧠 Starting smart installation with dependency resolution..."
	@echo "📊 Installation will proceed in 5 phases based on dependencies"
	@echo ""
	@echo "📋 Phase 1: Core prerequisites"
	@$(MAKE) -s install-phase-1
	@echo ""
	@echo "📋 Phase 2: Package managers and basic configs"
	@$(MAKE) -s install-phase-2
	@echo ""
	@echo "📋 Phase 3: Shell and runtime tools"
	@$(MAKE) -s install-phase-3
	@echo ""
	@echo "📋 Phase 4: Applications and environments"
	@$(MAKE) -s install-phase-4
	@echo ""
	@echo "📋 Phase 5: Final configurations"
	@$(MAKE) -s install-phase-5
	@echo ""
	@echo "✅ Smart installation completed successfully!"

# Phase implementations
install-phase-1:
	@echo "🔧 Phase 1: Installing core prerequisites..."
	@for target in $(PHASE_1_TARGETS); do \
		echo "  → Installing $$target"; \
		$(MAKE) -s $$target || exit 1; \
	done
	@echo "✅ Phase 1 completed"

install-phase-2:
	@echo "🔧 Phase 2: Installing package managers and basic configs..."
	@for target in $(PHASE_2_TARGETS); do \
		echo "  → Installing $$target"; \
		$(call validate_dependencies,$$target); \
		$(MAKE) -s $$target || exit 1; \
	done
	@echo "✅ Phase 2 completed"

install-phase-3:
	@echo "🔧 Phase 3: Installing shell and runtime tools..."
	@for target in $(PHASE_3_TARGETS); do \
		echo "  → Installing $$target"; \
		$(call validate_dependencies,$$target); \
		$(MAKE) -s $$target || exit 1; \
	done
	@echo "✅ Phase 3 completed"

install-phase-4:
	@echo "🔧 Phase 4: Installing applications and environments..."
	@for target in $(PHASE_4_TARGETS); do \
		echo "  → Installing $$target"; \
		$(call validate_dependencies,$$target); \
		$(MAKE) -s $$target || exit 1; \
	done
	@echo "✅ Phase 4 completed"

install-phase-5:
	@echo "🔧 Phase 5: Applying final configurations..."
	@for target in $(PHASE_5_TARGETS); do \
		echo "  → Installing $$target"; \
		$(call validate_dependencies,$$target); \
		$(MAKE) -s $$target || exit 1; \
	done
	@echo "✅ Phase 5 completed"

# Individual phase targets for granular control
.PHONY: install-smart install-phase-1 install-phase-2 install-phase-3 install-phase-4 install-phase-5

# Dependency checking utilities
check-dependencies:
	@echo "🔍 Checking installation dependencies..."
	@echo ""
	@echo "📋 Required system dependencies:"
	@echo -n "  Git: "; command -v git >/dev/null && echo "✅ Available" || echo "❌ Missing"
	@echo -n "  Make: "; command -v make >/dev/null && echo "✅ Available" || echo "❌ Missing"
	@echo -n "  Curl: "; command -v curl >/dev/null && echo "✅ Available" || echo "❌ Missing"
	@echo -n "  Rsync: "; command -v rsync >/dev/null && echo "✅ Available" || echo "❌ Missing"
	@echo ""
	@echo "📋 Optional dependencies:"
	@echo -n "  Homebrew: "; command -v brew >/dev/null && echo "✅ Available" || echo "⚠️  Will be installed"
	@echo -n "  Fish shell: "; command -v fish >/dev/null && echo "✅ Available" || echo "⚠️  Will be installed"
	@echo -n "  ASDF: "; command -v asdf >/dev/null && echo "✅ Available" || echo "⚠️  Will be installed"

show-dependency-graph:
	@echo "📊 Installation Dependency Graph:"
	@echo ""
	@echo "Phase 1 (Core Prerequisites):"
	@echo "  └── update (git repository)"
	@echo "  └── _copy-git (git configuration)"
	@echo "  └── _copy-env (environment template)"
	@echo ""
	@echo "Phase 2 (Package Managers & Basic Configs):"
	@echo "  └── brew (depends: update)"
	@echo "  └── copy-configs (depends: _copy-git, _copy-env)"
	@echo ""
	@echo "Phase 3 (Shell & Runtime Tools):"
	@echo "  └── _copy-fish (depends: copy-configs)"
	@echo "  └── asdf (depends: brew, _copy-fish)"
	@echo ""
	@echo "Phase 4 (Applications & Environments):"
	@echo "  └── omf (depends: _copy-fish)"
	@echo "  └── iterm2 (depends: brew)"
	@echo "  └── env (depends: _copy-env)"
	@echo ""
	@echo "Phase 5 (Final Configuration):"
	@echo "  └── set-fish-default (depends: _copy-fish, omf)"
