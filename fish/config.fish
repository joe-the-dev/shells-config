# Only load in interactive mode
if not status is-interactive
    return
end

# ── Environment ──────────────────────────────────────────────────────────────

# Native .env loading (skips comments, handles KEY=VALUE and export KEY=VALUE)
if test -f $HOME/.env
    for line in (grep -v '^\s*#' $HOME/.env | grep '=')
        set -l parts (string split -m1 '=' -- $line)
        set -gx (string trim -- $parts[1] | string replace -r '^export\s+' '') (string trim -- $parts[2])
    end
end

# Homebrew — hardcoded for Apple Silicon (avoids spawning brew on every shell)
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
fish_add_path --global --move /opt/homebrew/bin /opt/homebrew/sbin
if test -n "$MANPATH[1]"
    set -gx MANPATH '' $MANPATH
end
set -gx INFOPATH /opt/homebrew/share/info $INFOPATH

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SSH_AUTH_SOCK ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
set fish_greeting

# ── PATH ─────────────────────────────────────────────────────────────────────

fish_add_path /usr/local/bin /usr/bin /bin /usr/sbin /sbin
fish_add_path $HOME/.local/bin $HOME/jetbrain $HOME/Library/pnpm
fish_add_path /opt/homebrew/opt/curl/bin
fish_add_path /Users/dat.ta/.antigravity/antigravity/bin

# asdf shims — prepend so they shadow system binaries
if test -z $ASDF_DATA_DIR
    set -l shims $HOME/.asdf/shims
else
    set -l shims $ASDF_DATA_DIR/shims
end
if test -d $shims; and not contains $shims $PATH
    set -gx --prepend PATH $shims
end

# ── Tool integrations ─────────────────────────────────────────────────────────

command -q direnv; and eval (direnv hook fish)
test -f /opt/homebrew/opt/asdf/libexec/asdf.fish; and source /opt/homebrew/opt/asdf/libexec/asdf.fish

# ── Aliases ───────────────────────────────────────────────────────────────────

# Files
alias ls  'ls -p -G'
alias la  'ls -A'
alias ll  'ls -l'
alias lla 'll -A'
alias clr realclear

if type -q eza
    alias ll  'eza -l -g --icons --git'
    alias lla 'll -a'
    alias lt  'eza --tree --level=2 --icons'
    alias lta 'lt -a'
end

# Editor
alias vi nvim
command -q nvim; and alias vim nvim

# Kubernetes
alias k    kubectl
alias kl   kubectl
alias kctl kubectl
alias konf 'kubectl config'
alias kfwd kpfwd
alias kns  'kubectl config set-context --current --namespace'

# ── Abbreviations ─────────────────────────────────────────────────────────────

# Navigation
abbr --add ..   'cd ..'
abbr --add ...  'cd ../..'
abbr --add .... 'cd ../../..'
abbr --add zz   fg

# Git — abbreviations expand in-place so tab completion works on subcommands
abbr --add lg  lazygit
abbr --add g   git
abbr --add gs  'git status'
abbr --add ga  'git add'
abbr --add gc  'git commit'
abbr --add gcm 'git commit -m'
abbr --add gp  'git push'
abbr --add gl  'git log --oneline'

# ── Functions ─────────────────────────────────────────────────────────────────

function realclear --description 'Clear terminal completely'
    clear
    printf '\e[3J'
end

function mkcd --description 'Create directory and cd into it'
    mkdir -p $argv[1]; and cd $argv[1]
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

function extract --description 'Extract various archive formats'
    if test (count $argv) -ne 1
        echo "Usage: extract <file>"
        return 1
    end

    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            unrar x $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*'
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

function ecs-cluster --description 'Select ECS cluster interactively'
    if test (count $argv) -eq 0
        echo "Usage: ecs-cluster <profile>"
        return 1
    end

    set -l cluster (aws ecs list-clusters --query 'clusterArns[]' --output text --profile $argv[1] 2>/dev/null | sed 's#.*/##' | fzf --prompt="Select ECS cluster: ")
    if test -n "$cluster"
        echo $cluster
    else
        echo "❌ No cluster selected or AWS CLI error"
        return 1
    end
end

function upgrade-all --description 'Upgrade all package managers and tools'
    set -l failed_upgrades

    if type -q brew
        echo '🍺 Upgrading Homebrew...'
        if not brew update; or not brew upgrade
            set -a failed_upgrades Homebrew
        end
    end

    if type -q asdf
        echo '🔧 Upgrading asdf...'
        if not asdf plugin-update --all; and asdf update
            set -a failed_upgrades asdf
        end
    end

    if type -q pnpm
        echo '📦 Upgrading pnpm...'
        if not pnpm self-update
            set -a failed_upgrades pnpm
        end
    end

    if type -q npm
        echo '📦 Upgrading npm globals...'
        if not npm update -g
            set -a failed_upgrades npm
        end
    end

    if type -q omf
        echo '🐟 Upgrading Oh My Fish...'
        if not omf update
            set -a failed_upgrades OMF
        end
    end

    if test (count $failed_upgrades) -eq 0
        echo '✅ All upgrades completed successfully!'
    else
        echo "❌ Some upgrades failed: "(string join ", " $failed_upgrades)
        return 1
    end
end

function backup --description 'Backup configuration files'
    if not test -d "$SHELL_BACKUP_DIR"
        echo "❌ ERROR: Configuration directory not found at $SHELL_BACKUP_DIR"
        echo "💡 Make sure SHELL_BACKUP_DIR is set correctly"
        return 1
    end

    echo "🚀 Running backup using make system..."
    pushd "$SHELL_BACKUP_DIR"

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

# ── AWS / Fuji tunnels ────────────────────────────────────────────────────────
# Override any of these in ~/.env or your shell to switch targets without editing this file

set -gx FUJI_PROFILE fuji-mips-devlab
set -gx FUJI_TARGET  i-020ba3f6a16ae5cba
set -gx FUJI_HOST    10.101.67.228
# fuji function lives in functions/fuji.fish

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

    echo "→ Fetching latest refs"
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

# ── Tool hooks ────────────────────────────────────────────────────────────────

command -q zoxide;   and zoxide init fish | source
command -q thefuck;  and thefuck --alias | source

# ── Load fzf / peco extensions ────────────────────────────────────────────────

for config_file in ~/.config/fish/fzf.fish ~/.config/fish/peco.fish
    test -f $config_file; and source $config_file
end
