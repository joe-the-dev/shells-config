# WebStorm Plugin Installation - Complete Guide

## ✨ Quick Start - Recommended Method

**Run the automated script:**
```bash
cd ~/Documents/Playground/shells-config/jetbrains-ides/WebStorm2025.2
./install-plugins.sh
```

---

## 📝 Manual Installation Commands

### Single Plugin Installation

**Command format:**
```bash
~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins <plugin-id>
```

**Examples:**
```bash
# Install IdeaVIM
~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins IdeaVIM

# Install GitHub Copilot
~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins github-copilot-intellij

# Install Vue.js
~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins vuejs

# Install Terraform
~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins terraform
```

### Install All Plugins at Once

**Fish Shell:**
```fish
cd ~/Documents/Playground/shells-config/jetbrains-ides/WebStorm2025.2

for plugin in (cat plugins_manifest.txt | grep -v '^#' | grep -v '^$' | grep -v '.jar')
    ~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins $plugin
end
```

**Bash:**
```bash
cd ~/Documents/Playground/shells-config/jetbrains-ides/WebStorm2025.2

while IFS= read -r plugin; do
    if [[ ! -z "$plugin" && ! "$plugin" =~ ^# && ! "$plugin" =~ \.jar$ ]]; then
        ~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins "$plugin"
    fi
done < plugins_manifest.txt
```

### Using Symlink (Shorter Command)

If you have `$HOME/jetbrain` in your PATH:
```bash
webstorm installPlugins IdeaVIM
```

---

## 📋 Your Plugin List

Based on your `plugins_manifest.txt`:

### Core Plugins (Should Install)
- `IdeaVIM` - Vim emulation
- `github-copilot-intellij` - AI code completion

### IDE-Specific Plugins (May Install)
- `dotenv` - .env file support
- `terraform` - Terraform/HCL support
- `swagger` - OpenAPI/Swagger support
- `mcpserver` - MCP server support
- `mdx` - MDX file support

### Bundled Plugins (Will Show as "Unknown")
These are already included with WebStorm:
- `javascript-debugger`
- `react`
- `vuejs`
- `yaml`
- `editorconfig-plugin`
- `karma`
- `tasks`
- `clouds-docker-impl`
- `vcs-github-IU`
- `vcs-gitlab-IU`
- `vcs-svn`

### Special Files (Skip)
- `solarized_theme.jar` - Custom theme (install manually via Settings)

---

## 🔍 Understanding the Output

### Successful Installation
```
plugin repositories: [null]
looking up plugins: [IdeaVIM]
installed plugin: PluginNode{id=IdeaVIM, name='IdeaVim'}
```

### Already Installed
```
looking up plugins: [IdeaVIM]
already installed: IdeaVIM
```

### Plugin Not Found
```
plugin repositories: [null]
looking up plugins: [clouds-docker-impl]
unknown plugins: [clouds-docker-impl]
```
*This usually means it's a bundled plugin or the ID has changed*

### IDE Running Error
```
Only one instance of WebStorm can be run at a time.
```
*Solution: Close WebStorm completely and try again*

---

## ⚠️ Important Notes

1. **Close WebStorm First**
   - The command will fail if WebStorm is running
   - Check with: `pgrep -f "WebStorm"`

2. **Some Plugins May Fail**
   - Bundled plugins show as "unknown"
   - This is normal and expected

3. **Custom Themes (.jar files)**
   - Cannot be installed via CLI
   - Install manually: Settings → Plugins → ⚙️ → Install Plugin from Disk

4. **Verify Installation**
   - Restart WebStorm after installation
   - Check: Settings → Plugins

---

## 🔧 Troubleshooting

### WebStorm Not Found
If you get "WebStorm not found", update the path:
```bash
# Check where WebStorm is installed
ls -la ~/Applications/ | grep WebStorm
ls -la /Applications/ | grep WebStorm

# Use the correct path
/path/to/WebStorm.app/Contents/MacOS/webstorm installPlugins <plugin-id>
```

### IDE is Running
```bash
# Check if running
pgrep -f "WebStorm"

# Kill the process if needed
pkill -f "WebStorm"
```

---

## 🎯 Quick Test

Test with a single plugin first:
```bash
~/Applications/WebStorm.app/Contents/MacOS/webstorm installPlugins IdeaVIM
```

If this works, you can install all plugins using any of the methods above.

---

## 📚 Additional Resources

- **Helper Script**: `./install-plugins.sh` (in this directory)
- **Plugin Manifest**: `./plugins_manifest.txt`
- **Original Plugin List**: `./plugins_list.txt`

---

**Created**: 2025-11-12  
**WebStorm Version**: 2025.2.4

