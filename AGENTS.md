# 🤖 AI Agent Maintenance Guide

This document provides comprehensive guidance for AI agents to effectively maintain, debug, and extend the shells-config project. Last updated: September 10, 2025.

## 🎯 Project Overview

This is a modular configuration management system for macOS development environments that supports:
- Automatic backup and restoration of development tools and system settings
- Modular Makefile architecture for maintainability
- Support for 15+ development tools and applications
- Comprehensive macOS system settings backup
- Git-based configuration synchronization

### Core Philosophy
- **Modular**: Separate concerns into focused Makefiles
- **Reliable**: Comprehensive error handling and validation
- **Maintainable**: Clear structure with consistent patterns
- **User-friendly**: Simple commands hide complex operations

## 🏗️ Architecture Deep Dive

### Makefile Structure
```
Makefile (80 lines)           # Main orchestrator and help system
├── makefiles/backup.mk       # All backup operations (~545 lines)
├── makefiles/install.mk      # Installation and restoration (~450 lines)
└── makefiles/utils.mk        # Utilities and maintenance (~250 lines)
```

### Key Variables (Exported to Sub-makefiles)
```makefile
HOME_DIR := $(HOME)
CONFIG_DIR := $(HOME_DIR)/.config
JETBRAINS_DIR := $(HOME_DIR)/Library/Application Support/JetBrains
ITERM2_APP_SUPPORT := $(HOME_DIR)/Library/Application Support/iTerm2
BACKUP_TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Color codes for consistent output
BLUE := \033[34m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m
```

### Target Patterns
All Makefiles follow consistent patterns:

1. **Public targets**: User-facing commands (no underscore prefix)
2. **Private targets**: Internal implementation (underscore prefix)
3. **Error handling**: Exit on failure with descriptive messages
4. **Progress feedback**: Color-coded status messages
5. **Dependency checking**: Verify prerequisites before execution

## 🔧 Supported Applications & Locations

### Development Tools
| Tool | Source Directory | Target Location | Backup Target |
|------|------------------|-----------------|---------------|
| Fish Shell | `fish/` | `~/.config/fish/` | `_backup-fish` |
| Neovim | `nvim/` | `~/.config/nvim/` | `_backup-nvim` |
| Oh My Fish | `omf/` | `~/.config/omf/` | `_backup-omf` |
| Git | `gitconfig/` | `~/.gitconfig`, `~/.gitignore_global` | `_backup-gitconfig` |
| ASDF | `asdf/` | `~/.asdfrc`, `~/.tool-versions` | `_backup-asdf` |
| Bash | `bash/` | `~/.bashrc`, `~/.bash_profile` | `_backup-bash` |
| Zsh | `zsh/` | `~/.zshrc`, `~/.zprofile` | `_backup-zsh` |

### System Tools
| Tool | Source Directory | Target Location | Backup Target |
|------|------------------|-----------------|---------------|
| Karabiner | `karabiner/` | `~/.config/karabiner/` | `_backup-karabiner` |
| Hammerspoon | `hammerspoon/` | `~/.hammerspoon/` | `_backup-hammerspoon` |
| iTerm2 | `iterm2/` | `~/Library/Application Support/iTerm2/` | `_backup-iterm2` |
| Homebrew | `brew/` | `~/.Brewfile` | `_backup-brew` |
| Environment | `env/` | `~/.env` | `_backup-env` |

### JetBrains IDEs
| IDE | Source Directory | Target Location | Special Notes |
|-----|------------------|-----------------|---------------|
| IntelliJ IDEA | `jetbrains-ides/IntelliJIdea*/` | `~/Library/Application Support/JetBrains/IntelliJIdea*/` | Auto-detects versions |
| PyCharm | `jetbrains-ides/PyCharm*/` | `~/Library/Application Support/JetBrains/PyCharm*/` | Professional/Community |
| WebStorm | `jetbrains-ides/WebStorm*/` | `~/Library/Application Support/JetBrains/WebStorm*/` | Latest version only |
| DataGrip | `jetbrains-ides/DataGrip*/` | `~/Library/Application Support/JetBrains/DataGrip*/` | Database IDE |
| CLion | `jetbrains-ides/CLion*/` | `~/Library/Application Support/JetBrains/CLion*/` | C/C++ IDE |
| GoLand | `jetbrains-ides/GoLand*/` | `~/Library/Application Support/JetBrains/GoLand*/` | Go IDE |
| RubyMine | `jetbrains-ides/RubyMine*/` | `~/Library/Application Support/JetBrains/RubyMine*/` | Ruby IDE |
| PhpStorm | `jetbrains-ides/PhpStorm*/` | `~/Library/Application Support/JetBrains/PhpStorm*/` | PHP IDE |
| Rider | `jetbrains-ides/Rider*/` | `~/Library/Application Support/JetBrains/Rider*/` | .NET IDE |

### macOS System Settings
| Category | Source Directory | Backup Scope | Restore Method |
|----------|------------------|---------------|----------------|
| Display | `macos/display/` | Monitor configs, DisplayLink | System restart may be required |
| Dock | `macos/dock/` | Dock preferences, position | Dock restart automatic |
| Finder | `macos/finder/` | Finder settings, sidebar | Finder restart automatic |
| Keyboard | `macos/keyboard/` | Layouts, shortcuts, emoji | Logout required |
| Trackpad | `macos/trackpad/` | Gestures, sensitivity | Immediate effect |
| Mission Control | `macos/mission_control/` | Spaces, Exposé | Immediate effect |
| Audio | `macos/audio/` | Audio devices, MIDI | Immediate effect |
| Accessibility | `macos/accessibility/` | Accessibility features | Immediate effect |
| System | `macos/system/` | Global preferences | Mixed restart requirements |
| Third-party | `macos/third_party/` | BetterZip, LuLu, etc. | App-specific |

## 📋 Common Maintenance Tasks

### Adding a New Application

1. **Create backup target** in `makefiles/backup.mk`:
```makefile
# Add to backup-apps target
@$(MAKE) -s _backup-newtool

# Create backup implementation
_backup-newtool:
	@echo "🔄 Backing up newtool config files → newtool/"
	@src="$$HOME/.config/newtool"; \
	dst="newtool"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		rsync -a "$$src"/ "$$dst"/; \
	fi
```

2. **Create installation target** in `makefiles/install.mk`:
```makefile
# Add to copy-configs target
@$(MAKE) -s _copy-newtool

# Create copy implementation
_copy-newtool:
	@if [ -d "newtool" ]; then \
		echo "🔧 Copying newtool config..."; \
		rm -rf "$$HOME/.config/newtool"; \
		mkdir -p "$$HOME/.config"; \
		cp -a "newtool" "$$HOME/.config/newtool"; \
	fi
```

3. **Test the implementation**:
```bash
make backup           # Should include your new tool
make restore          # Should restore the configuration
```

### Modifying Backup Behavior

**For application configs**: Edit `makefiles/backup.mk`
**For system settings**: Edit the `backup-macos` target in `makefiles/backup.mk`
**For installation logic**: Edit `makefiles/install.mk`

### Adding New macOS System Settings

1. **Identify the preference domain**:
```bash
defaults domains | tr ',' '\n' | grep -i "appname"
```

2. **Add to appropriate category** in `makefiles/backup.mk`:
```makefile
# In _backup-macos-category target
if defaults read com.company.appname >/dev/null 2>&1; then \
	echo "📋 Backing up AppName preferences..."; \
	defaults export com.company.appname "$$category_dir/appname.plist"; \
fi
```

3. **Add restore command** to auto-generated restore script logic.

## 🐛 Troubleshooting Guide

### Common Issues and Solutions

#### 1. Git Sync Failures
**Symptoms**: `make backup-sync` fails with merge conflicts
**Diagnosis**: Check git status and branch
**Solution**:
```bash
git status
git pull origin main
# Resolve conflicts manually
make backup-sync
```

#### 2. JetBrains Backup Missing
**Symptoms**: IDE configurations not backed up
**Diagnosis**: Check if IDE directories exist
**Solution**:
```bash
ls -la ~/Library/Application\ Support/JetBrains/
# Verify IDE names match patterns in backup script
```

#### 3. Permission Denied Errors
**Symptoms**: Cannot copy files to system locations
**Diagnosis**: Check file permissions and ownership
**Solution**:
```bash
# Fix ownership
sudo chown -R $USER:staff ~/.config/
# Fix permissions
chmod -R 755 ~/.config/
```

#### 4. macOS Settings Not Restoring
**Symptoms**: System settings unchanged after restore
**Diagnosis**: Check if restart is required
**Solution**:
```bash
# Some settings require logout/restart
sudo shutdown -r now
```

### Debugging Makefile Issues

#### Enable Verbose Mode
```bash
make backup VERBOSE=1
```

#### Test Individual Components
```bash
make _backup-fish      # Test specific backup target
make _copy-nvim        # Test specific copy target
```

#### Validate Make Syntax
```bash
make -n backup         # Dry run - shows commands without executing
```

## 🔍 Code Quality Standards

### Makefile Best Practices

1. **Error Handling**: Always check for directory existence before operations
2. **User Feedback**: Provide clear, colored status messages
3. **Atomic Operations**: Use `rsync` for reliable file copying
4. **Path Safety**: Quote all paths to handle spaces
5. **Conditional Logic**: Check for prerequisites before execution

### Example Pattern (Follow This):
```makefile
_backup-example:
	@echo "🔄 Backing up example config files → example/"
	@src="$$HOME/.config/example"; \
	dst="example"; \
	rm -rf "$$dst"; \
	mkdir -p "$$dst"; \
	if [ -d "$$src" ]; then \
		echo "📋 Found example config at $$src"; \
		rsync -a "$$src"/ "$$dst"/; \
		echo "✅ Example config backed up successfully"; \
	else \
		echo "ℹ️  No example config found at $$src"; \
	fi
```

### Directory Structure Conventions

- **Source directories**: Named after the tool (e.g., `fish/`, `nvim/`)
- **Backup targets**: Prefixed with `_backup-` (e.g., `_backup-fish`)
- **Copy targets**: Prefixed with `_copy-` (e.g., `_copy-fish`)
- **Public targets**: No prefix (e.g., `backup`, `restore`)

## 📊 Testing and Validation

### Automated Testing Commands
```bash
make check-deps       # Verify all dependencies
make validate-config  # Check configuration syntax
make status          # Show current system status
make dry-run         # Preview backup without execution
```

### Manual Testing Workflow

1. **Backup Test**:
```bash
make backup           # Full backup
git status            # Check for new/changed files
```

2. **Restore Test** (use with caution):
```bash
# Create backup of current configs first
cp -r ~/.config ~/.config.backup
make restore
# Verify configurations work
# Restore original if needed: mv ~/.config.backup ~/.config
```

3. **Sync Test**:
```bash
make backup-sync      # Test full workflow
```

## 🚀 Performance Considerations

### Backup Optimization
- Use `rsync -a` for efficient file copying
- Skip empty directories to reduce noise
- Exclude large temporary files (.git, node_modules)
- Parallelize independent operations where possible

### Storage Management
- JetBrains: Only backup latest version to save space
- Karabiner: Keep only 2 most recent automatic backups
- macOS: Compress large preference files when possible

## 🔐 Security Considerations

### Sensitive Data Handling
- **Environment variables**: Use template approach, never commit actual secrets
- **Git config**: Exclude sensitive files in .gitignore
- **Network settings**: Sanitize before backup
- **Certificates**: Exclude from backups

### File Permissions
- Maintain original file permissions during restore
- Set appropriate permissions for config directories (755)
- Protect sensitive config files (600 for SSH keys, etc.)

## 📚 References and Resources

### macOS Preference Domains
- System preferences: `com.apple.*`
- Third-party apps: Use `defaults domains` to discover
- Location: `~/Library/Preferences/`

### JetBrains Configuration Paths
- macOS: `~/Library/Application Support/JetBrains/`
- Config subdirectories: `options/`, `codestyles/`, `keymaps/`
- Version detection: Look for `build.txt` files

### Common Shell Configuration Paths
- Fish: `~/.config/fish/`
- Bash: `~/.bashrc`, `~/.bash_profile`
- Zsh: `~/.zshrc`, `~/.zprofile`
- Environment: `~/.env` (custom)

### Git Integration
- Main branch: `main` (enforced by backup-sync)
- Commit format: `"Backup configs - YYYY-MM-DD HH:MM:SS"`
- Auto-pull before backup to prevent conflicts

## 🎯 Future Enhancement Ideas

### Potential Improvements
1. **Configuration validation**: Add syntax checking for config files
2. **Selective restore**: Allow restoring individual tools
3. **Backup compression**: Reduce storage requirements
4. **Cross-platform support**: Extend to Linux/Windows
5. **Plugin system**: Allow third-party extensions
6. **Backup encryption**: Encrypt sensitive configurations
7. **Backup rotation**: Automatic cleanup of old backups
8. **Integration testing**: Automated testing in containers

### Architecture Improvements

✅ **Implemented Improvements:**
1. ~~**Parallel execution**: Speed up backup/restore operations~~ - **COMPLETED**
   - Backup operations now run in 3 parallel batches (4 jobs each)
   - Installation operations use parallel copying across batches
   - ~3x performance improvement for backup operations
   - ~2.5x performance improvement for installation operations

2. ~~**Progress indicators**: Better user feedback for long operations~~ - **COMPLETED**
   - Batch completion feedback: "✅ Batch 1 completed!"
   - Numbered progress logs: "[1/13] 🐟 Backing up fish config files → fish/"
   - Consolidated parallel execution results
   - Clear status messages with emojis and colors

🎯 **Remaining Improvements:**
3. **Rollback capability**: Undo last restore operation
4. **Configuration profiles**: Support multiple environment setups  
5. **Dependency graph**: Smart ordering of installation steps

🔮 **Future Considerations:**
- **Atomic transactions**: Ensure all-or-nothing operations
- **Incremental backups**: Only backup changed files
- **Configuration validation**: Verify configs before applying
- **Background monitoring**: Watch for config changes and auto-backup

---

*This guide should be updated whenever significant changes are made to the project architecture or when new tools are added.*
