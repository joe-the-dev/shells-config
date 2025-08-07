#!/bin/bash

set -e

if ! command -v brew >/dev/null 2>&1; then
  echo "⚠️  Homebrew not found - please install Homebrew first"
  echo "💡 Install from: https://brew.sh"
  exit 0
fi

echo "🍺 Installing Homebrew packages from Brewfile..."
echo "📦 Installing packages..."

if brew bundle install --file=brew/Brewfile --verbose; then
  echo "✅ Homebrew packages installed successfully!"
else
  echo "⚠️  Some packages may have failed - this might be normal for packages requiring sudo"
  echo "💡 If you see permission errors, you can:"
  echo "   1. Run the installer again and enter your password when prompted"
  echo "   2. Or manually run: brew bundle install --file=brew/Brewfile"
fi

exit 0
