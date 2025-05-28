#!/bin/bash

# Detect OS type
if [[ "$(uname)" == "Darwin" ]]; then
  echo "✅ Detected macOS"
  
  # Move to the macos directory (relative to script location)
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$SCRIPT_DIR/macos" || { echo "❌ macos directory not found!"; exit 1; }

  # Execute mac_init.sh
  if [[ -x ./mac_init.sh ]]; then
    echo "🚀 Running mac_init.sh..."
    ./mac_init.sh
  else
    echo "❌ mac_init.sh is missing or not executable"
    exit 1
  fi
else
  echo "⚠️ This script is only for macOS. Exiting."
  exit 1
fi
