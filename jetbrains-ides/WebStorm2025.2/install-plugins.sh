#!/bin/bash

# WebStorm Plugin Installation Script
# This script installs all plugins from plugins_manifest.txt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEBSTORM_EXEC="$HOME/Applications/WebStorm.app/Contents/MacOS/webstorm"
PLUGINS_FILE="$SCRIPT_DIR/plugins_manifest.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔌 WebStorm Plugin Installer${NC}"
echo "=================================="

# Check if WebStorm is running
if pgrep -f "WebStorm" > /dev/null; then
    echo -e "${RED}❌ WebStorm is currently running. Please close it first.${NC}"
    exit 1
fi

# Check if WebStorm executable exists
if [ ! -f "$WEBSTORM_EXEC" ]; then
    echo -e "${RED}❌ WebStorm not found at: $WEBSTORM_EXEC${NC}"
    echo -e "${YELLOW}💡 Update the WEBSTORM_EXEC path in this script${NC}"
    exit 1
fi

# Check if plugins file exists
if [ ! -f "$PLUGINS_FILE" ]; then
    echo -e "${RED}❌ Plugins manifest not found at: $PLUGINS_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ WebStorm found${NC}"
echo -e "${GREEN}✅ Plugins manifest found${NC}"
echo ""

# Count total plugins
TOTAL_PLUGINS=$(grep -v '^#' "$PLUGINS_FILE" | grep -v '^$' | wc -l | tr -d ' ')
echo -e "${BLUE}📦 Installing $TOTAL_PLUGINS plugins...${NC}"
echo ""

# Install each plugin
INSTALLED=0
FAILED=0
SKIPPED=0

while IFS= read -r plugin_id || [ -n "$plugin_id" ]; do
    # Skip comments and empty lines
    if [[ -z "$plugin_id" || "$plugin_id" =~ ^[[:space:]]*# ]]; then
        continue
    fi

    # Skip .jar files (these are custom themes/plugins installed manually)
    if [[ "$plugin_id" == *.jar ]]; then
        echo -e "${YELLOW}⏭️  Skipping: $plugin_id (custom JAR file)${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    echo -n "  📦 Installing: $plugin_id ... "

    # Run installation and capture output
    OUTPUT=$("$WEBSTORM_EXEC" installPlugins "$plugin_id" 2>&1)

    if echo "$OUTPUT" | grep -q "installed plugin"; then
        echo -e "${GREEN}✅ Installed${NC}"
        INSTALLED=$((INSTALLED + 1))
    elif echo "$OUTPUT" | grep -q "unknown plugin"; then
        echo -e "${YELLOW}⚠️  Not found (may be bundled)${NC}"
        FAILED=$((FAILED + 1))
    elif echo "$OUTPUT" | grep -q "Only one instance"; then
        echo -e "${RED}❌ IDE is running${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Processed${NC}"
        INSTALLED=$((INSTALLED + 1))
    fi

done < "$PLUGINS_FILE"

echo ""
echo "=================================="
echo -e "${BLUE}📊 Installation Summary${NC}"
echo -e "  ${GREEN}✅ Installed: $INSTALLED${NC}"
echo -e "  ${YELLOW}⚠️  Failed/Bundled: $FAILED${NC}"
echo -e "  ${YELLOW}⏭️  Skipped: $SKIPPED${NC}"
echo ""
echo -e "${GREEN}✨ Done! Restart WebStorm to see the changes.${NC}"

