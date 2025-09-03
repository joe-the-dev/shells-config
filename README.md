# 🛠️ Development Environment Configuration

A comprehensive configuration management system for macOS development environments, supporting automatic backup and restoration of all your development tools.

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

## 🎯 Available Commands

### Installation
- `make install` or `make` - Install all configurations (recommended)
- `make update` - Update git repository to latest version
- `make copy-configs` - Copy dotfiles to home directory only

### Individual Components
- `make brew` - Install Homebrew packages from Brewfile
- `make asdf` - Install asdf plugins and language versions
- `make jetbrains` - Setup JetBrains IDEs configurations
- `make iterm2` - Install iTerm2 preferences and profiles
- `make omf` - Setup Oh My Fish with themes and packages
- `make env` - Setup environment variables template

### Backup & Restore
- `make backup` - Backup all current configurations to repository
- `make restore` - Restore all configurations from backup
- `make restore-jetbrains` - Restore only JetBrains IDEs configurations

### Maintenance
- `make check-deps` - Verify required dependencies are installed
- `make upgrade-deps` - Update all package managers and tools
- `make clean` - Remove temporary files and caches
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

## 📂 Directory Structure

```
shells-config/
├── backup.sh              # Comprehensive backup script
├── Makefile               # Main installation and management system
├── README.md              # This documentation
│
├── asdf/                  # ASDF version manager
│   ├── .asdfrc           # ASDF configuration
│   ├── .tool-versions    # Language versions
│   └── plugins.txt       # Installed plugins list
│
├── bash/                  # Bash shell configuration
├── brew/                  # Homebrew packages
│  └── Brewfile            # All installed packages/casks/taps
│
├── env/                   # Environment variables
│   ├── template.env      # Template with examples
│   ├── home.env          # Backup of ~/.env
│   └── README.md         # Environment setup guide
│
├── fish/                  # Fish shell configuration
│   ├── config.fish       # Main Fish configuration
│   ├── functions/        # Custom Fish functions
│   └── completions/      # Command completions
│
├── gitconfig/             # Git configuration
│   ├── .gitconfig        # Global git settings
│   └── .gitignore_global # Global gitignore patterns
│
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
│   ├── .ideavimrc        # Shared IdeaVim configuration
│   └── ...               # Other IDE versions
│
├── karabiner/            # Keyboard customization
├── nvim/                 # Neovim configuration
├── omf/                  # Oh My Fish framework
└── zsh/                  # Zsh shell configuration
```

## 🔄 Backup & Restore Process

### Automated Backup
The backup system automatically detects and backs up:
- All configuration files from their standard locations
- Multiple versions of JetBrains IDEs
- Homebrew package lists (generates fresh Brewfile)
- Environment variables (securely)
- Plugin lists for easy reinstallation

### Git Integration
```bash
# Backup and sync to git
./backup.sh --sync

# This will:
# 1. Backup all configurations
# 2. Commit changes with timestamp
# 3. Push to remote repository
```

### Restore on New Machine
```bash
# Clone your config repository
git clone <your-repo-url> shells-config
cd shells-config

# Install everything
make install

# This will:
# 1. Update repository to latest version
# 2. Check dependencies
# 3. Copy all configuration files
# 4. Install Homebrew packages
# 5. Setup ASDF tools and versions
# 6. Configure all JetBrains IDEs
# 7. Setup iTerm2, OMF, and environment
```

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
1. Add the tool name to the `TOOLS` array in `backup.sh`
2. Add a case handler for the tool in `backup.sh`
3. Add a corresponding restoration target in the `Makefile`
4. Test with `make backup` and `make restore`

### Modifying Backup Behavior
Edit `backup.sh` to customize:
- Which files/directories to include
- Backup frequency and automation
- Git sync behavior

## 🚨 Important Notes

### Security
- Environment variables are handled securely with proper file permissions
- Sensitive data uses template approach (never commit actual secrets)
- Git configurations exclude sensitive files

### Plugin Management
- JetBrains plugins are **listed but not automatically installed**
- After restoration, manually reinstall plugins from the generated lists
- This ensures compatibility and proper licensing

### Version Compatibility
- The system detects and backs up multiple IDE versions
- Restoration preserves version-specific configurations
- Cross-version compatibility is maintained where possible

## 🤝 Contributing

1. Fork the repository
2. Make your changes
3. Test with `make backup` and `make restore`
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.
