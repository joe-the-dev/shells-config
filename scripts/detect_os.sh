#!/bin/bash

# OS Detection Script
# Returns: macos, ubuntu, manjaro, arch, or unknown

detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                case "$ID" in
                    ubuntu|debian)
                        echo "ubuntu"
                        ;;
                    manjaro)
                        echo "manjaro"
                        ;;
                    arch)
                        echo "arch"
                        ;;
                    fedora|centos|rhel)
                        echo "fedora"
                        ;;
                    *)
                        echo "linux"
                        ;;
                esac
            else
                echo "linux"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Export the function and detect current OS
export -f detect_os
CURRENT_OS=$(detect_os)
export CURRENT_OS

# Print if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "$CURRENT_OS"
fi
