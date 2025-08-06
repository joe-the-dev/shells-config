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
./backup.sh
```

## 📁 What's Included

This configuration manages the following tools and their settings:

- **🐚 Fish Shell** - Modern shell with auto-suggestions and syntax highlighting
- **⚡ Oh My Fish (OMF)** - Fish shell framework and theme manager
- **📝 Neovim** - Modern Vim-based editor with LSP support
- **⌨️ Karabiner-Elements** - Keyboard customization for macOS
- **🔨 Hammerspoon** - macOS automation and window management
- **🍺 Homebrew** - Package manager with Brewfile for dependencies
- **🔀 asdf** - Version manager for multiple programming languages

## 🏗️ Project Structure

```
shells-config/
├── install.sh              # Main installation script
├── backup.sh               # Backup current configs to repo
├── install.conf.yaml       # Dotbot configuration
├── fish/                   # Fish shell configuration
├── nvim/                   # Neovim configuration  
├── omf/                    # Oh My Fish configuration
├── karabiner/              # Karabiner-Elements settings
├── hammerspoon/            # Hammerspoon scripts
├── brew/                   # Homebrew Brewfile
├── asdf/                   # asdf configuration
│   ├── .asdfrc            # asdf settings
│   ├── .tool-versions     # Global tool versions
│   └── plugins.txt        # List of installed plugins
└── dotbot/                 # Dotbot submodule
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
   - Install asdf plugins (if asdf is installed)
   - Install tool versions from `.tool-versions`

### Backing Up Current Configuration

When you make changes to your configs, backup them to the repo:

```bash
./backup.sh
```

This captures:
- All configuration files from their respective locations
- Current asdf plugin list
- Tool versions

### Installing Prerequisites

Before running the installer, ensure you have:

1. **Xcode Command Line Tools:**
   ```bash
   xcode-select --install
   ```

2. **Homebrew** (optional, for managing packages):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **asdf** (optional, for version management):
   ```bash
   # Install asdf first, then run the installer
   # The installer will automatically set up your plugins and tools
   ```

## ⚙️ Configuration Details

### Fish Shell
- Custom functions and aliases
- Syntax highlighting and auto-suggestions
- Oh My Fish theme and plugins
- Auto-completion configurations

### Neovim
- Modern Lua-based configuration
- LSP support for multiple languages
- Plugin management with lazy.nvim
- Custom keymaps and settings

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
   TOOLS=("fish" "nvim" "omf" "karabiner" "hammerspoon" "asdf" "your-tool")
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
./backup.sh
```

## 🛠️ Troubleshooting

### Permission Issues
```bash
# Make scripts executable
chmod +x install.sh backup.sh
```

### Dotbot Submodule Issues
```bash
# Update submodules
git submodule update --init --recursive
```

### asdf Not Found
```bash
# Install asdf first, then run installer
# The installer will skip asdf setup if not found
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
