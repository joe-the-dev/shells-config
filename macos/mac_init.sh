#!/bin/bash

set -e

echo "🍏 Starting macOS setup..."

# 1. Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  echo "🔧 Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH (Apple Silicon support)
  if [[ -d "/opt/homebrew/bin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  elif [[ -d "/usr/local/bin" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.bash_profile
  fi
else
  echo "✅ Homebrew already installed"
fi

echo "🔄 Updating Homebrew..."
brew update

# 2. Tap additional sources
echo "➕ Adding useful Homebrew taps..."
brew tap homebrew/cask
brew tap homebrew/cask-fonts

# 3. Install CLI tools
echo "💻 Installing CLI tools..."
brew install git
brew install fish
brew install neovim
brew install tmux
brew install fzf
brew install gh
brew install jq
brew install ripgrep
brew install bat
brew install fd
brew install eza
brew install asdf
brew install lazygit

# 4. Install GUI apps (cask)
echo "🖥️ Installing GUI apps..."
brew install --cask iterm2
brew install --cask hiddenbar
brew install --cask visual-studio-code
brew install --cask jetbrains-toolbox
brew install --cask docker
brew install --cask google-chrome
brew install --cask firefox
brew install --cask spotify
brew install --cask rectangle
brew install --cask raycast

# 5. Developer tools
echo "🛠️ Installing developer tools..."
brew install --cask postman
brew install --cask mongodb-compass
brew install --cask intellij-idea

# 6. Fonts (optional)
echo "🔤 Installing fonts..."
brew install --cask font-fira-code
brew install --cask font-jetbrains-mono

# 7. Cleanup
echo "🧹 Cleaning up..."
brew cleanup

echo "✅ macOS dev environment setup complete!"


echo "🐟 Setting up Fish shell..."

# Ensure fish is installed
if ! command -v fish &>/dev/null; then
  echo "❌ Fish shell not found! Please check Homebrew install."
  exit 1
fi

# Add fish to /etc/shells if it's not there
FISH_PATH=$(which fish)
if ! grep -q "$FISH_PATH" /etc/shells; then
  echo "📎 Adding fish to /etc/shells..."
  echo "$FISH_PATH" | sudo tee -a /etc/shells
fi

# Set fish as the default shell
if [[ "$SHELL" != "$FISH_PATH" ]]; then
  echo "🧬 Changing default shell to fish..."
  chsh -s "$FISH_PATH"
fi

# Install Oh My Fish (OMF)
if [[ ! -d "$HOME/.local/share/omf" ]]; then
  echo "🌊 Installing Oh My Fish..."
  curl -L https://get.oh-my.fish | fish
else
  echo "✅ OMF already installed"
fi

# Install OMF plugins
echo "🔌 Installing OMF plugins..."
fish -c "omf install bobthefish"
fish -c "omf install z"

# Move custom fish config from local `fish/` directory
CONFIG_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/fish"
CONFIG_TARGET="$HOME/.config/fish"

if [[ -d "$CONFIG_SOURCE" ]]; then
  echo "📁 Copying custom fish config to ~/.config/fish..."
  mkdir -p "$CONFIG_TARGET"
  cp -r "$CONFIG_SOURCE/"* "$CONFIG_TARGET/"
else
  echo "⚠️ fish/ directory not found. Skipping config copy."
fi
