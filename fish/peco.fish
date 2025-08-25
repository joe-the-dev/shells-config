# PECO Configuration and Enhancements for Fish Shell
# This file contains all peco-related functions and configurations
# Peco is a simpler, faster alternative to fzf for interactive filtering

# =============================================================================
# PECO FUNCTIONS
# =============================================================================

# Enhanced command history search with peco
function ph --description "Search command history with peco"
    set -l cmd (history | peco)
    if test -n "$cmd"
        commandline -r "$cmd"
    end
end

# Process killer with peco
function pkill-peco --description "Kill process with peco"
    set -l pid (ps aux | peco | awk '{print $2}')
    if test -n "$pid"
        echo "Killing process: $pid"
        kill -9 $pid
    end
end

# File finder with peco (simple, no preview)
function pf --description "Find files with peco"
    set -l file
    if command -q fd
        set file (fd --type f --hidden --follow --exclude .git | peco)
    else
        set file (find . -type f -not -path "*/\.git/*" 2>/dev/null | peco)
    end

    if test -n "$file"
        commandline -i "$file"
    end
end

# Directory changer with peco
function pcd --description "Change directory with peco"
    set -l dir
    if command -q fd
        set dir (fd --type d --hidden --follow --exclude .git | peco)
    else
        set dir (find . -type d -not -path "*/\.git/*" 2>/dev/null | peco)
    end

    if test -n "$dir"
        cd "$dir"
        commandline -f repaint
    end
end

# Git branch switcher with peco
function pgb --description "Switch git branch with peco"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l branch (git branch --all --format='%(refname:short)' | sed 's|^origin/||' | sort -u | peco)
    if test -n "$branch"
        git checkout "$branch"
    end
end

# Git commit browser with peco
function pgl --description "Browse git commits with peco"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l commit (git log --oneline | peco)
    if test -n "$commit"
        set -l commit_hash (echo $commit | cut -d' ' -f1)
        git show $commit_hash
    end
end

# Git status files with peco
function pgs --description "Browse git status files with peco"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l file (git status --porcelain | peco | cut -c4-)
    if test -n "$file"
        commandline -i "$file"
    end
end

# Environment variable browser with peco
function penv --description "Browse environment variables with peco"
    set -l var (env | peco | cut -d= -f1)
    if test -n "$var"
        commandline -i "\$$var"
    end
end

# SSH connection manager with peco
function pssh --description "Connect to SSH hosts with peco"
    if test -f ~/.ssh/config
        set -l host (grep "^Host " ~/.ssh/config | awk '{print $2}' | grep -v '*' | peco)
        if test -n "$host"
            ssh "$host"
        end
    else
        echo "No SSH config file found at ~/.ssh/config"
    end
end

# Docker container manager with peco
function pdocker --description "Manage Docker containers with peco"
    if not command -q docker
        echo "Docker not found"
        return 1
    end

    set -l action (echo -e "ps\nexec\nlogs\nstop\nstart\nremove" | peco)

    switch "$action"
        case "ps"
            docker ps -a | peco
        case "exec"
            set -l container (docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | peco | awk '{print $1}')
            if test -n "$container"
                docker exec -it "$container" /bin/bash
            end
        case "logs"
            set -l container (docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | peco | awk '{print $1}')
            if test -n "$container"
                docker logs -f "$container"
            end
        case "stop"
            set -l containers (docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | peco | awk '{print $1}')
            if test -n "$containers"
                docker stop $containers
            end
        case "start"
            set -l containers (docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | peco | awk '{print $1}')
            if test -n "$containers"
                docker start $containers
            end
        case "remove"
            set -l containers (docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | peco | awk '{print $1}')
            if test -n "$containers"
                echo "Are you sure you want to remove: $containers? (y/N)"
                read -l confirm
                if test "$confirm" = "y" -o "$confirm" = "Y"
                    docker rm $containers
                end
            end
    end
end

# Kubernetes context switcher with peco
function pkube --description "Switch Kubernetes context with peco"
    if not command -q kubectl
        echo "kubectl not found"
        return 1
    end

    set -l action (echo -e "context\nnamespace\npods\nservices\nlogs" | peco)

    switch "$action"
        case "context"
            set -l context (kubectl config get-contexts -o name | peco)
            if test -n "$context"
                kubectl config use-context "$context"
            end
        case "namespace"
            set -l namespace (kubectl get namespaces -o name | sed 's|^namespace/||' | peco)
            if test -n "$namespace"
                kubectl config set-context --current --namespace="$namespace"
            end
        case "pods"
            kubectl get pods | peco
        case "services"
            kubectl get services | peco
        case "logs"
            set -l pod (kubectl get pods -o name | sed 's|^pod/||' | peco)
            if test -n "$pod"
                kubectl logs -f "$pod"
            end
    end
end

# AWS profile switcher with peco
function paws --description "Switch AWS profile with peco"
    if test -f ~/.aws/credentials
        set -l profile (grep '^\[' ~/.aws/credentials | sed 's/\[//g' | sed 's/\]//g' | peco)
        if test -n "$profile"
            set -gx AWS_PROFILE "$profile"
            echo "AWS_PROFILE set to: $profile"
        end
    else
        echo "No AWS credentials file found at ~/.aws/credentials"
    end
end

# Project switcher with peco
function pproject --description "Switch to project directory with peco"
    set -l project_dirs ~/Documents ~/Projects ~/dev ~/Development ~/workspace ~/code
    set -l projects

    for dir in $project_dirs
        if test -d "$dir"
            set -a projects (find "$dir" -type d -name ".git" -maxdepth 3 2>/dev/null | xargs -I {} dirname {})
        end
    end

    if test (count $projects) -eq 0
        echo "No git repositories found in common project directories"
        return 1
    end

    set -l selected (printf '%s\n' $projects | peco)
    if test -n "$selected"
        cd "$selected"
        commandline -f repaint
    end
end

# npm/pnpm script runner with peco
function pnpm-peco --description "Run npm/pnpm scripts with peco"
    if test -f package.json
        set -l script (jq -r '.scripts | keys[]' package.json 2>/dev/null | peco)
        if test -n "$script"
            if command -q pnpm
                pnpm run "$script"
            else if command -q yarn
                yarn "$script"
            else
                npm run "$script"
            end
        end
    else
        echo "No package.json found in current directory"
    end
end

# File content search with ripgrep and peco
function prg --description "Search file contents with peco and ripgrep"
    if command -q rg
        set -l search_term ""
        if test (count $argv) -gt 0
            set search_term $argv
        end

        set -l result (rg --line-number --no-heading --smart-case $search_term | peco)
        if test -n "$result"
            set -l file (echo $result | cut -d: -f1)
            set -l line (echo $result | cut -d: -f2)
            echo "Opening $file at line $line"
            if command -q nvim
                nvim "+$line" "$file"
            else
                echo "File: $file, Line: $line"
                echo "Content: $result"
            end
        end
    else
        echo "ripgrep (rg) not found. Install with: brew install ripgrep"
    end
end

# Enhanced ECS cluster with peco
function pecs --description "Select ECS cluster with peco"
    if not command -q aws
        echo "AWS CLI not found"
        return 1
    end

    set -l profile_arg ""
    if test (count $argv) -gt 0
        set profile_arg "--profile $argv[1]"
    end

    set -l cluster (aws ecs list-clusters --query 'clusterArns[]' --output text $profile_arg 2>/dev/null | sed 's#.*/##' | peco)
    if test -n "$cluster"
        echo $cluster
    end
end

# =============================================================================
# PECO KEY BINDINGS
# =============================================================================

# Key bindings for peco functions (only set if interactive)
if status is-interactive
    # Ctrl+P for peco history search (alternative to fzf's Ctrl+R)
    bind \cp 'ph; commandline -f repaint'

    # Alt+P for peco file finder
    bind \ep 'pf; commandline -f repaint'

    # Alt+Shift+P for peco directory changer
    bind \eP 'pcd; commandline -f repaint'

    # Ctrl+Alt+B for peco git branch switcher
    bind \e\cb 'pgb; commandline -f repaint'
end

# =============================================================================
# PECO ALIASES
# =============================================================================

# Shorter aliases for peco functions
alias pecoh ph           # Peco history
alias pecof pf           # Peco find files
alias pecocd pcd         # Peco change directory
alias pecogit pgl        # Peco git log
alias pecopk pkill-peco  # Peco process kill
