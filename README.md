# 🔧 Joe-The-Dev's Development Environment Configuration

A comprehensive dotfiles management system using [dotbot](https://github.com/anishathalye/dotbot) to backup, version, and restore development environment configurations across macOS machines.

## 🚀 Quick Start

### New Machine Setup
```bash
git clone --recurse-submodules <your-repo-url>
cd shells-config
./install.sh
```

### Backup Current Configuration
```bash
# Backup configs to repository
./backup.sh

# Backup and sync to git automatically
./backup.sh --sync
```

## 📁 What's Included

This configuration manages the following tools and their settings:

### 🖥️ Terminal & Shell
- **🐚 Fish Shell** - Modern shell with auto-suggestions and syntax highlighting
- **⚡ Oh My Fish (OMF)** - Fish shell framework and theme manager
- **🐚 Bash** - Traditional shell with custom `.bashrc` configuration
- **⚡ Zsh** - Z shell with custom `.zshrc` configuration
- **📺 iTerm2** - Terminal emulator with profiles, colors, and preferences

### 🛠️ Development Tools
- **📝 Neovim** - Modern Vim-based editor with LSP support
- **🧠 IntelliJ IDEA** - IDE configuration including:
  - Code styles (2-space indentation)
  - IdeaVim configuration (`.ideavimrc`)
  - Plugins and preferences
  - JVM options
- **🔀 asdf** - Version manager for multiple programming languages

### ⚙️ System & Productivity
- **⌨️ Karabiner-Elements** - Keyboard customization for macOS
- **🔨 Hammerspoon** - macOS automation and window management
- **🍺 Homebrew** - Package manager with Brewfile for dependencies

### 🔧 Git & Version Control
- **📋 Git Configuration** - Global git settings (`.gitconfig`)
- **🚫 Global Gitignore** - Universal ignore patterns (`.gitignore_global`)

## 🏗️ Project Structure

```
shells-config/
├── install.sh                    # Main installation script
├── backup.sh                     # Backup current configs to repo
├── install.conf.yaml             # Dotbot configuration
├── fish/                         # Fish shell configuration
├── nvim/                         # Neovim configuration  
├── omf/                          # Oh My Fish configuration
├── bash/                         # Bash shell configuration
│   └── .bashrc                   # Bash settings and aliases
├── zsh/                          # Zsh shell configuration
│   └── .zshrc                    # Zsh settings and aliases
├── gitconfig/                    # Git configuration
│   ├── .gitconfig                # Global git settings
│   └── .gitignore_global         # Global ignore patterns
├── intellij/                     # IntelliJ IDEA configuration
│   ├── .ideavimrc                # IdeaVim settings
│   ├── codestyles/               # Code formatting (2-space indent)
│   ├── options/                  # IDE preferences
│   └── idea.vmoptions            # JVM options
├── iterm2/                       # iTerm2 configuration
│   ├── com.googlecode.iterm2.plist   # Profiles and preferences
│   ├── DynamicProfiles/          # Custom profiles
│   └── Scripts/                  # Automation scripts
├── karabiner/                    # Karabiner-Elements settings
├── hammerspoon/                  # Hammerspoon scripts
├── brew/                         # Homebrew Brewfile
├── asdf/                         # asdf configuration
│   ├── .asdfrc                   # asdf settings
│   ├── .tool-versions            # Global tool versions
│   └── plugins.txt               # List of installed plugins
├── scripts/                      # Installation scripts
│   ├── install_brew_packages.sh
│   ├── install_asdf_plugins.sh
│   ├── install_intellij_config.sh
│   └── install_iterm2_config.sh
└── dotbot/                       # Dotbot submodule
```

## 🔄 Usage

### Installing on a New Machine

1. **Clone the repository:**
   ```bash
   git clone --recurse-submodules <your-repo-url>
   cd shells-config
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

   This will:
   - Create symlinks for all configuration files
   - Install Homebrew packages from Brewfile
   - Install asdf plugins and tool versions
   - Restore IntelliJ IDEA configuration (including 2-space indentation)
   - Restore iTerm2 profiles and preferences

### Backing Up Current Configuration

When you make changes to your configs, backup them to the repo:

```bash
# Simple backup
./backup.sh

# Backup with automatic git commit and push
./backup.sh --sync
```

**The `--sync` flag will:**
- Update main branch from remote
- Backup all configurations
- Add and commit changes with timestamp
- Push to origin/main

**This captures:**
- All configuration files from their respective locations
- Current asdf plugin list and tool versions
- IntelliJ IDEA settings and IdeaVim configuration
- iTerm2 profiles, colors, and preferences
- Git configuration and global ignore patterns
- Shell configurations (bash, zsh, fish)

### Installing Prerequisites

Before running the installer, ensure you have:

1. **Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

2. **Git** (for cloning and syncing):
   ```bash
   # Usually comes with Xcode Command Line Tools
   git --version
   ```

3. **Optional tools** (installer will handle these):
   - Homebrew (for package management)
   - asdf (for version management)
   - iTerm2 (for terminal enhancement)
   - IntelliJ IDEA (for IDE configuration)

## ⚙️ Configuration Details

### Fish Shell
- Custom functions and aliases
- Syntax highlighting and auto-suggestions
- Oh My Fish theme and plugins
- Auto-completion configurations

### Bash & Zsh
- Custom aliases and functions
- Environment variable configurations
- Shell-specific optimizations

### Neovim
- Modern Lua-based configuration
- LSP support for multiple languages
- Plugin management with lazy.nvim
- Custom keymaps and settings

### IntelliJ IDEA
- **Code Styles:** 2-space indentation for all languages
- **IdeaVim:** Comprehensive Vim emulation with custom keybindings
  - Leader key: `Space`
  - File navigation: `<leader>ff`, `<leader>fr`
  - Code actions: `<leader>ca`, `<leader>cf`
  - Debugging: `<leader>db`, `<leader>dc`
- **Plugins:** Automatically manages enabled/disabled plugins
- **JVM Options:** Custom memory and performance settings

### iTerm2
- Terminal profiles with custom themes
- Color schemes (including Solarized Dark)
- Key bindings and shortcuts
- Dynamic profiles support

### Git Configuration
- Global user settings and aliases
- Custom merge and diff tools
- Global gitignore patterns for common files

### asdf Version Management
- Automatically installs and restores plugins
- Manages tool versions globally via `.tool-versions`
- Supports legacy version files (`.nvmrc`, `.python-version`, etc.)

### Karabiner-Elements
- Custom keyboard mappings
- Complex modifications for enhanced productivity

### Hammerspoon
- Window management automation
- Custom Lua scripts for macOS integration

## 🔧 Customization

### Adding New Tools

1. **Add to backup script:**
   ```bash
   # Edit backup.sh and add your tool to TOOLS array
   TOOLS=("fish" "nvim" "omf" "karabiner" "hammerspoon" "asdf" "bash" "zsh" "gitconfig" "intellij" "iterm2" "your-tool")
   ```

2. **Add to dotbot config:**
   ```yaml
   # Edit install.conf.yaml
   - link:
       ~/.config/your-tool: your-tool
   ```

### Managing asdf Plugins

The system automatically handles asdf plugins:
- **Backup:** `./backup.sh` captures current plugins to `asdf/plugins.txt`
- **Restore:** `./install.sh` installs plugins and tool versions automatically

To manually manage:
```bash
# Add a new plugin
asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest

# Backup the changes
./backup.sh --sync
```

### Customizing IntelliJ IDEA

Your IdeaVim configuration includes:
- Leader key mappings (Space + key combinations)
- Code navigation shortcuts
- Debugging shortcuts
- File management commands

To test if IdeaVim is working:
```vim
" In IntelliJ, press Space + test
<leader>test
```

## 🛠️ Troubleshooting

### Permission Issues
```bash
# Make scripts executable
chmod +x install.sh backup.sh scripts/*.sh
```

### Dotbot Submodule Issues
```bash
# Update submodules
git submodule update --init --recursive

# Update submodules to latest versions
git submodule update --remote --merge

# Update specific submodule (like dotbot) to latest
git submodule update --remote dotbot
```

### Updating Git Submodules

When there are updates to dotbot or other submodules:

```bash
# Check current submodule status
git submodule status

# Update all submodules to their latest versions
git submodule update --remote --merge

# Update only dotbot submodule
git submodule update --remote dotbot

# Commit the submodule updates
git add .
git commit -m "Update dotbot submodule to latest version"
git push origin main
```

**Note:** After updating submodules, test your installation to ensure compatibility:
```bash
./install.sh --dry-run  # Test without making changes
```

### asdf Not Found
```bash
# Install asdf first, then run installer
# The installer will skip asdf setup if not found
```

### IntelliJ IDEA Configuration Not Loading
1. Restart IntelliJ IDEA completely
2. Check if IdeaVim plugin is enabled
3. Reload `.ideavimrc`: `Ctrl+Shift+A` → "Reload .ideavimrc"

### iTerm2 Preferences Not Restored
1. Close iTerm2 completely before running installer
2. Restart iTerm2 after installation
3. Check iTerm2 → Preferences → Profiles

### Git Sync Issues
```bash
# If backup --sync fails, manually sync:
git pull origin main
git add .
git commit -m "Update configs"
git push origin main
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `./install.sh` on a clean environment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy coding!** 🚀
