#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "🔐 Setting up environment variables..."

# Check if .env.template exists
if [ ! -f "$REPO_DIR/.env.template" ]; then
    echo "❌ .env.template not found!"
    exit 1
fi

# Check if .env already exists
if [ -f "$HOME/.env" ]; then
    echo "⚠️  ~/.env already exists!"
    echo "Do you want to:"
    echo "1) Keep existing .env file"
    echo "2) Create backup and use template"
    echo "3) View differences"
    read -p "Choose option (1-3): " choice

    case $choice in
        1)
            echo "✅ Keeping existing .env file"
            exit 0
            ;;
        2)
            echo "📋 Creating backup of existing .env..."
            cp "$HOME/.env" "$HOME/.env.backup.$(date +%Y%m%d_%H%M%S)"
            echo "✅ Backup created"
            ;;
        3)
            echo "📊 Differences between template and current .env:"
            diff "$REPO_DIR/.env.template" "$HOME/.env" || true
            read -p "Proceed with template? (y/n): " proceed
            if [[ "$proceed" != "y" ]]; then
                echo "❌ Cancelled"
                exit 0
            fi
            ;;
        *)
            echo "❌ Invalid choice"
            exit 1
            ;;
    esac
fi

# Copy template to home directory
echo "📄 Copying .env template to ~/.env..."
cp "$REPO_DIR/.env.template" "$HOME/.env"

echo "✅ Environment template installed!"
echo ""
echo "🔧 Next steps:"
echo "1. Edit ~/.env with your actual credentials:"
echo "   vim ~/.env"
echo "   # or"
echo "   code ~/.env"
echo ""
echo "2. Your credentials are safely stored locally and will NOT be synced to git"
echo "3. The template will be available on new devices for easy setup"

# Make .env readable only by user
chmod 600 "$HOME/.env"
echo "🔒 Set secure permissions (600) on ~/.env"
