#!/bin/bash

set -e

if ! command -v asdf >/dev/null 2>&1; then
  echo "ℹ️  asdf not found - skipping plugin installation"
  echo "💡 Install asdf first: https://asdf-vm.com/guide/getting-started.html"
  exit 0
fi

if [ ! -f "asdf/plugins.txt" ]; then
  echo "ℹ️  asdf/plugins.txt not found - skipping plugin installation"
  exit 0
fi

echo "🔌 Installing asdf plugins..."
while IFS= read -r plugin || [ -n "$plugin" ]; do
  if [[ -z "$plugin" || "$plugin" =~ ^[[:space:]]*# ]]; then
    continue
  fi
  plugin_name=$(echo "$plugin" | awk '{print $1}')
  echo "📦 Checking plugin: $plugin_name"
  if asdf plugin list | grep -q "^$plugin_name$"; then
    echo "⚠️  Plugin $plugin_name is already installed, skipping"
  else
    echo "Installing plugin: $plugin_name"
    if asdf plugin add $plugin; then
      echo "✅ Successfully installed plugin: $plugin_name"
    else
      echo "❌ Failed to install plugin: $plugin_name"
      exit 1
    fi
  fi
done < "asdf/plugins.txt"

echo "🔧 Installing tool versions..."
if asdf install; then
  echo "✅ asdf setup complete!"
else
  echo "❌ Some tools failed to install"
  exit 1
fi

# Ensure we exit with success code
exit 0
