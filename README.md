# 🛠️ Development Environment Configuration

A comprehensive configuration management system for macOS development environments, supporting automatic backup and restoration of all your development tools and system settings.

## 🚀 Quick Start

### New Machine Setup
```bash
git clone <your-repo-url>
cd shells-config
make install
```

### Daily Usage
```bash
make backup          # Save your current configurations
make backup-sync     # Backup + commit + push to git
make restore         # Restore all configurations
make help           # See all available commands
```

## 📦 Supported Tools

This configuration system manages settings for:

- **🐟 Fish Shell** - Modern shell with excellent autocomplete
- **⚡ Neovim** - Vim-based text editor configuration
- **🐟 Oh My Fish (OMF)** - Fish shell framework and themes
- **⌨️ Karabiner** - Keyboard customization for macOS
- **🔨 Hammerspoon** - macOS automation and window management
- **🔧 ASDF** - Version manager for multiple languages
- **🐚 Bash/Zsh** - Traditional shell configurations
- **📝 Git** - Global git configuration and aliases
- **🍺 Homebrew** - Package manager with complete Brewfile
- **🧠 JetBrains IDEs** - IntelliJ IDEA, PyCharm, WebStorm, DataGrip, etc.
- **🖥️ iTerm2** - Terminal emulator preferences and profiles
- **🔐 Environment Variables** - Secure .env template management
- **🍎 macOS System Settings** - Comprehensive system preferences backup

## 🎯 Available Commands

### Installation & Setup
- `make install` or `make` - Install all configurations (recommended)
- `make install-minimal` - Install essential configs only
- `make install-dev` - Install development tools
- `make install-tools` - Install productivity tools
- `make update` - Update git repository to latest version

### Backup Operations
- `make backup` - Complete backup (apps + macOS system settings)
- `make backup-sync` - Complete backup + git commit/push
- `make backup-apps` - Application configurations only
- `make backup-macos` - macOS system settings only

### Restore Operations
- `make restore` - Restore all configurations from backup
- `make restore-jetbrains` - Restore only JetBrains IDEs configurations
- `make restore-macos` - Restore macOS system settings

### Individual Components
- `make brew` - Install Homebrew packages from Brewfile
- `make asdf` - Install asdf plugins and language versions
- `make jetbrains` - Setup JetBrains IDEs configurations
- `make iterm2` - Install iTerm2 preferences and profiles
- `make omf` - Setup Oh My Fish with themes and packages
- `make env` - Setup environment variables template

### Maintenance & Utilities
- `make check-deps` - Verify required dependencies are installed
- `make upgrade-deps` - Update all package managers and tools
- `make clean` - Remove temporary files and caches
- `make status` - Show configuration status
- `make validate-config` - Check configuration syntax
- `make help` - Show detailed help for all commands

## 🧠 JetBrains IDEs Support

### Supported IDEs
- IntelliJ IDEA
- PyCharm 
- WebStorm
- PhpStorm
- CLion
- GoLand
- RubyMine
- DataGrip
- Rider

### What's Backed Up
- **Code Styles** - Custom formatting rules
- **IDE Options** - All IDE preferences and settings
- **Keymaps** - Custom keyboard shortcuts
- **Color Schemes** - Custom themes and syntax highlighting
- **File Templates** - Custom file and code templates
- **Plugin Lists** - Installed plugins (for manual re-installation)
- **VM Options** - JVM settings and performance tuning
- **IdeaVim Config** - Vim emulation settings (`.ideavimrc`)

### Usage
```bash
# Backup all JetBrains IDEs
make backup

# Restore all JetBrains IDEs  
make restore-jetbrains

# Or restore everything
make restore
```

## 🍎 macOS System Settings Backup

### Comprehensive System Backup
The system now includes comprehensive macOS system settings backup covering:

- **🖥️ Display Settings** - Monitor configurations, DisplayLink settings
- **🖱️ Dock & Menu Bar** - Dock preferences, menu bar settings
- **📁 Finder** - Finder preferences and sidebar configurations
- **⌨️ Keyboard & Input** - Keyboard layouts, shortcuts, emoji settings
- **🖲️ Trackpad & Mouse** - Trackpad gestures and mouse settings
- **🚀 Mission Control** - Spaces and Exposé configurations
- **🌐 Network** - Network configurations (sanitized)
- **🔊 Audio** - Audio devices and MIDI setup
- **♿ Accessibility** - Accessibility preferences
- **⚙️ System Preferences** - Global domain and system-wide settings
- **🔧 Third-party Apps** - BetterZip, LuLu, and other supported apps

### Automatic Restore Script Generation
Each macOS backup automatically generates a restore script at `macos/restore_macos_settings.sh` that can:
- Restore all backed up settings with confirmation prompts
- Restart affected system services
- Provide detailed restoration feedback

### Usage
```bash
make backup-macos        # Backup macOS settings only
make restore-macos       # Restore macOS settings
./macos/restore_macos_settings.sh  # Direct restore script
```

## 📂 Directory Structure

```
shells-config/
├── Makefile               # Main orchestrator (modular system)
├── README.md              # This documentation
├── makefiles/             # Modular Makefile components
│   ├── backup.mk         # All backup operations
│   ├── install.mk        # Installation & restoration
│   ├── utils.mk          # Utilities & maintenance
│   └── README.md         # Modular system documentation
│
├── asdf/                  # ASDF version manager
│   └── plugins.txt       # Installed plugins list
│
├── bash/                  # Bash shell configuration
├── brew/                  # Homebrew packages
│   └── Brewfile          # All installed packages/casks/taps
│
├── env/                   # Environment variables
│   ├── template.env      # Template with examples
���   └── home.env          # Backup of ~/.env
│
├── fish/                  # Fish shell configuration
│   ├── config.fish       # Main Fish configuration
│   ├── functions/        # Custom Fish functions
│   └── completions/      # Command completions
│
├── gitconfig/             # Git configuration
├── hammerspoon/           # macOS automation
│   ├── init.lua          # Main Hammerspoon config
│   └── Spoons/           # Hammerspoon extensions
│
├── iterm2/               # iTerm2 terminal
│   ├── com.googlecode.iterm2.plist # Main preferences
│   ├── DynamicProfiles/  # Dynamic profile configurations
│   └── Scripts/          # iTerm2 automation scripts
│
├── jetbrains-ides/       # All JetBrains IDEs
│   ├── IntelliJIdea2025.2/
│   ├── PyCharm2025.2/
│   ├── WebStorm2025.2/
│   ├── DataGrip2025.2/
│   └── .ideavimrc        # Shared IdeaVim configuration
│
├── karabiner/            # Keyboard customization
│   ├── karabiner.json    # Main configuration
│   └── automatic_backups/ # Recent backup files (2 most recent)
│
├── macos/                # macOS system settings
│   ├── restore_macos_settings.sh # Auto-generated restore script
│   ├── system_info.txt   # System information snapshot
│   ├── display/          # Display and monitor settings
│   ├── dock/             # Dock preferences
│   ├── finder/           # Finder settings
│   ├── keyboard/         # Keyboard and input settings
│   ├── trackpad/         # Trackpad configurations
│   ├── mission_control/  # Mission Control settings
│   ├── audio/            # Audio device settings
│   ├── accessibility/    # Accessibility preferences
│   ├── system/           # System-wide preferences
│   └── third_party/      # Third-party app settings
│
├── nvim/                 # Neovim configuration
├── omf/                  # Oh My Fish framework
└── zsh/                  # Zsh shell configuration
```

## 🔄 Backup & Restore Process

### Modern Backup System
The backup system uses a modular Make-based approach:

```bash
# Complete backup with git sync
make backup-sync

# This will:
# 1. Backup all application configurations
# 2. Backup comprehensive macOS system settings
# 3. Generate restore scripts automatically
# 4. Commit changes with timestamp
# 5. Push to remote repository
```

### Individual Backup Operations
```bash
make backup-apps         # Applications only (fast)
make backup-macos        # macOS system settings only
make backup              # Everything (apps + macOS)
```

### Restore on New Machine
```bash
# Clone your config repository
git clone <your-repo-url> shells-config
cd shells-config

# Complete installation
make install

# This will:
# 1. Update repository to latest version
# 2. Check and install dependencies
# 3. Copy all configuration files to proper locations
# 4. Install Homebrew packages from Brewfile
# 5. Setup ASDF tools and language versions
# 6. Configure all JetBrains IDEs with plugins
# 7. Setup iTerm2, OMF, and environment variables
# 8. Optionally restore macOS system settings
```

## 🏗️ Architecture

### Modular Makefile System
The system uses a modular architecture for better maintainability:

- **Main Makefile** (~80 lines) - Orchestration and help system
- **makefiles/backup.mk** (~545 lines) - All backup operations
- **makefiles/install.mk** (~450 lines) - Installation and restoration
- **makefiles/utils.mk** (~250 lines) - Utilities and maintenance

### Benefits
- **Maintainable** - Each module has clear responsibilities
- **Scalable** - Easy to add new tools and features
- **Reliable** - Comprehensive error handling and validation
- **Efficient** - Parallel execution where possible

## 🔧 Prerequisites

### Required
- **Git** - For repository management
- **Make** - For running the build system (pre-installed on macOS)

### Recommended
- **Homebrew** - Package manager for macOS
- **Fish Shell** - Modern shell with great defaults

### Optional
- **ASDF** - Multi-language version manager
- **JetBrains IDEs** - Any JetBrains development environments

## 🎨 Customization

### Adding New Tools
1. Add backup logic to `makefiles/backup.mk` in the `backup-apps` section
2. Create a new `_backup-newtool` target following existing patterns
3. Add installation logic to `makefiles/install.mk` if needed
4. Add a corresponding restoration target in `makefiles/install.mk`
5. Test with `make backup` and `make restore`

### Modifying Backup Behavior
Edit the appropriate Makefile module:
- **Application backups**: `makefiles/backup.mk`
- **macOS settings**: `makefiles/backup.mk` (backup-macos target)
- **Installation logic**: `makefiles/install.mk`
- **Git sync behavior**: `makefiles/backup.mk` (backup-sync target)

### Example: Adding a New Application
```makefile
# In makefiles/backup.mk, add to backup-apps target:
@$(MAKE) -s _backup-myapp

# Add the backup target:
_backup-myapp:
	@echo "🔄 Backing up myapp config files → myapp/"
	@src="$$HOME/.config/myapp"; \
	dst="myapp"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		rsync -a "$$src"/ "$$dst"/; \
	fi

# In makefiles/install.mk, add installation target:
myapp:
	@echo "🔧 Setting up MyApp configuration..."
	@$(MAKE) -s _copy-myapp

_copy-myapp:
	@if [ -d "myapp" ]; then \
		echo "📋 Copying MyApp configuration files..."; \
		cp -R myapp/. "$$HOME/.config/myapp/"; \
	fi
```

## 🚨 Important Notes

### Security
- Environment variables are handled securely with proper file permissions
- Sensitive data uses template approach (never commit actual secrets)
- Git configurations exclude sensitive files
- macOS system backups sanitize sensitive network information

### Plugin Management
- **JetBrains plugins are listed but not automatically installed**
- After restoration, manually reinstall plugins from the generated `plugins_manifest.txt` files
- This ensures compatibility and proper licensing
- Plugin IDs are extracted for easier CLI installation

### macOS System Settings
- **Review before restoring**: macOS settings backups include system-wide preferences
- **Restart may be required**: Some settings require logout/restart to take effect
- **DisplayLink support**: Special handling for DisplayLink monitor configurations
- **Third-party apps**: Automatically detects and backs up supported third-party applications

### Version Compatibility
- The system detects and backs up multiple IDE versions automatically
- Restoration preserves version-specific configurations
- Cross-version compatibility is maintained where possible
- Only the latest version of each JetBrains IDE is backed up to reduce storage

## 📊 System Information

### Backup Statistics
The system generates comprehensive statistics during backup:
- Number of backed up configurations
- File counts and sizes
- System information snapshots
- Timestamps for all operations

### Monitoring
Use these commands to monitor your configuration system:
```bash
make status           # Show current configuration status
make validate-config  # Validate all configurations
make check-deps      # Verify all dependencies are installed
```
