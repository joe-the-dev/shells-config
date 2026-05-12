# Performance: Only load in interactive mode
if not status is-interactive
    exit
end

# Environment loading with better error handling
if test -f $HOME/.env
    bass source $HOME/.env
end

# Better Homebrew detection and setup
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

# Conditional tool loading
command -q direnv; and eval (direnv hook fish)
test -f (brew --prefix asdf 2>/dev/null)/libexec/asdf.fish; and source (brew --prefix asdf)/libexec/asdf.fish

# Better terminal and display settings
set fish_greeting
set -gx TERM xterm-256color
set -gx EDITOR nvim
set -gx VISUAL nvim

# Environment variables
set -gx ASDF_NODEJS_VERIFY_RELEASE_SIGNATURES no
set -gx HOMEBREW_PREFIX /opt/homebrew
set -x SSH_AUTH_SOCK ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

# PATH management with better organization
set -l homebrew_paths $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin
set -l user_paths $HOME/.local/bin $HOME/jetbrain
set -l pnpm_path $HOME/Library/pnpm

# Build PATH systematically
for path_dir in $homebrew_paths $user_paths $pnpm_path
    if test -d $path_dir; and not contains $path_dir $PATH
        set -gx PATH $path_dir $PATH
    end
end

# Enhanced aliases with better organization
# Basic file operations
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias clr realclear

# Git aliases
alias g git
alias gs "git status"
alias ga "git add"
alias gc "git commit"
alias gcm "git commit -m"
alias gp "git push"
alias gl "git log --oneline"

# Kubernetes aliases
alias k kubectl
alias kl kubectl
alias kctl kubectl
alias konf "kubectl config"
alias kfwd "kpfwd"
alias kns "kubectl config set-context --current --namespace"

# Editor aliases
alias vi nvim
command -qv nvim && alias vim nvim

# Enhanced eza integration
if type -q eza
    alias ll "eza -l -g --icons --git"
    alias lla "ll -a"
    alias lt "eza --tree --level=2 --icons"
    alias lta "lt -a"
end

# Better FZF integration
if type -q fzf
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    end
end

# Enhanced functions with error handling
function __check_nvmrc --on-variable PWD --description 'Auto-use Node version from .nvmrc'
    status --is-command-substitution; and return

    if test -f .nvmrc; and test -r .nvmrc; and type -q nvm
        echo "🔄 Switching to Node version specified in .nvmrc"
        nvm use
    end
end

function realclear --description 'Clear terminal completely'
    clear
    printf '\e[3J'
end

function pnpm_format --description 'Format and lint with pnpm'
    if not type -q pnpm
        echo "❌ pnpm not found"
        return 1
    end
    echo "🎨 Formatting code..."
    pnpm format
    echo "🔧 Fixing lint issues..."
    pnpm lint:fix
end

# Enhanced upgrade function with better error handling
function upgrade-all --description 'Upgrade all package managers and tools'
    set -l failed_upgrades

    if type -q brew
        echo '🍺 Upgrading Homebrew...'
        if not brew update && brew upgrade
            set -a failed_upgrades "Homebrew"
        end
    end

    if type -q asdf
        echo '🔧 Upgrading asdf...'
        if not asdf plugin-update --all; and asdf update
            set -a failed_upgrades "asdf"
        end
    end

    if type -q pnpm
        echo '📦 Upgrading pnpm...'
        if not pnpm self-update
            set -a failed_upgrades "pnpm"
        end
    end

    if type -q npm
        echo '📦 Upgrading npm globals...'
        if not npm update -g
            set -a failed_upgrades "npm"
        end
    end

    if type -q omf
        echo '🐟 Upgrading Oh My Fish...'
        if not omf update
            set -a failed_upgrades "OMF"
        end
    end

    if test (count $failed_upgrades) -eq 0
        echo '✅ All upgrades completed successfully!'
    else
        echo "❌ Some upgrades failed: "(string join ", " $failed_upgrades)
        return 1
    end
end

# Enhanced backup function
function backup --description 'Backup configuration files'
    set -l config_dir "$SHELL_BACKUP_DIR"

    if not test -d "$config_dir"
        echo "❌ ERROR: Configuration directory not found at $config_dir"
        echo "💡 Make sure SHELL_BACKUP_DIR is set correctly"
        return 1
    end

    echo "🚀 Running backup using make system..."

    pushd "$config_dir"

    if contains -- --sync $argv
        echo "🔄 Running backup with git sync enabled"
        make backup-sync
    else
        echo "📦 Running backup without git sync"
        make backup
    end

    set -l exit_code $status
    popd

    if test $exit_code -eq 0
        echo "✅ Backup completed successfully!"
    else
        echo "❌ Backup failed with exit code $exit_code"
        return $exit_code
    end
end

# New utility functions
function gcp --description 'Cherry-pick a commit onto a new branch: gcp <commit> <new-branch> <base-branch>'
    if test (count $argv) -lt 3
        echo "Usage: gcp <commit> <new-branch> <base-branch>"
        echo ""
        echo "Example:"
        echo "  gcp 32a1a189 feat/CU-869c8bx1r-s112 develop-s112"
        echo ""
        echo "  → checkout develop-s112"
        echo "  → pull origin develop-s112"
        echo "  → create branch feat/CU-869c8bx1r-s112"
        echo "  → cherry-pick <commit>"
        echo "  → git push -f origin feat/CU-869c8bx1r-s112"
        return 1
    end

    set -l commit $argv[1]
    set -l new_branch $argv[2]
    set -l base_branch $argv[3]

    echo "→ Fetching to base branch: $base_branch"
    git fetch -p; or return 1

    echo "→ Switching to base branch: $base_branch"
    git checkout $base_branch; or return 1

    echo "→ Pulling latest: $base_branch"
    git pull origin $base_branch; or return 1

    echo "→ Creating new branch: $new_branch"
    git cobd $new_branch; or return 1

    echo "→ Cherry-picking: $commit"
    git cherry-pick $commit; or return 1

    echo "→ Force pushing: $new_branch"
    git push -f origin $new_branch; or return 1

    echo ""
    echo "✓ Done — $commit cherry-picked onto $new_branch (based on $base_branch)"
end

function mkcd --description 'Create directory and cd into it'
    mkdir -p $argv[1]; and cd $argv[1]
end

function extract --description 'Extract various archive formats'
    if test (count $argv) -ne 1
        echo "Usage: extract <file>"
        return 1
    end

    switch $argv[1]
        case "*.tar.bz2"
            tar xjf $argv[1]
        case "*.tar.gz"
            tar xzf $argv[1]
        case "*.bz2"
            bunzip2 $argv[1]
        case "*.rar"
            unrar x $argv[1]
        case "*.gz"
            gunzip $argv[1]
        case "*.tar"
            tar xf $argv[1]
        case "*.tbz2"
            tar xjf $argv[1]
        case "*.tgz"
            tar xzf $argv[1]
        case "*.zip"
            unzip $argv[1]
        case "*.Z"
            uncompress $argv[1]
        case "*.7z"
            7z x $argv[1]
        case "*"
            echo "❌ '$argv[1]' cannot be extracted via extract()"
            return 1
    end
end

function weather --description 'Get weather information'
    if test (count $argv) -eq 0
        curl -s "wttr.in?format=3"
    else
        curl -s "wttr.in/$argv[1]?format=3"
    end
end

function ports --description 'Show listening ports'
    sudo lsof -iTCP -sTCP:LISTEN -n -P
end

function myip --description 'Get public IP address'
    curl -s ifconfig.me
end

# Enhanced AWS/ECS function
function ecs-cluster --description 'Select ECS cluster interactively'
    if test (count $argv) -eq 0
        echo "Usage: ecs-cluster <profile>"
        return 1
    end

    set cluster (aws ecs list-clusters --query 'clusterArns[]' --output text --profile $argv[1] 2>/dev/null | sed 's#.*/##' | fzf --prompt="Select ECS cluster: ")
    if test -n "$cluster"
        echo $cluster
    else
        echo "❌ No cluster selected or AWS CLI error"
        return 1
    end
end

# Better abbreviations
abbr --add zz 'fg'
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'

# ASDF configuration with better error handling
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

if test -d $_asdf_shims; and not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

# Load external configuration files with error handling
for config_file in ~/.config/fish/fzf.fish ~/.config/fish/peco.fish
    if test -f $config_file
        source $config_file
    end
end
