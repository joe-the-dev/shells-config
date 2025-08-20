# FZF Configuration and Enhancements for Fish Shell
# This file contains all fzf-related functions, configurations, and key bindings

# FZF Default Options - Enhanced appearance with Dracula theme
set -gx FZF_DEFAULT_OPTS "
--height 40%
--layout=reverse
--border
--preview-window=wrap
--marker='*'
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
"

# Use fd for file search if available, otherwise fallback to find
if command -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
else
    set -gx FZF_DEFAULT_COMMAND 'find . -type f -not -path "*/\.git/*" 2> /dev/null'
    set -gx FZF_CTRL_T_COMMAND 'find . -type f -not -path "*/\.git/*" 2> /dev/null'
    set -gx FZF_ALT_C_COMMAND 'find . -type d -not -path "*/\.git/*" 2> /dev/null'
end

# Enhanced file preview with bat or cat
set -gx FZF_CTRL_T_OPTS "
--preview 'if command -q bat; bat --color=always --style=numbers --line-range=:300 {}; else cat {}; end'
--preview-window=right:60%:wrap
"

# Enhanced directory preview with tree or ls
set -gx FZF_ALT_C_OPTS "
--preview 'if command -q tree; tree -C {} | head -100; else ls -la {} 2>/dev/null; end'
--preview-window=right:50%
"

# =============================================================================
# FZF FUNCTIONS
# =============================================================================

# Enhanced file finder with preview
function ff --description "Find files with fzf"
    set -l file (fzf --preview 'if command -q bat; bat --color=always --style=numbers --line-range=:300 {}; else cat {}; end' --preview-window=right:60%)
    if test -n "$file"
        commandline -i "$file"
    end
end

# Enhanced directory changer
function fcd --description "Change directory with fzf"
    set -l dir (fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --preview 'if command -q tree; tree -C {} | head -100; else ls -la {} 2>/dev/null; end')
    if test -n "$dir"
        cd "$dir"
        commandline -f repaint
    end
end

# Git branch switcher
function fgb --description "Switch git branch with fzf"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l branch (git branch --all --format='%(refname:short)' | sed 's|^origin/||' | sort -u | fzf --preview 'git log --oneline --color=always {} | head -10')
    if test -n "$branch"
        git checkout "$branch"
    end
end

# Git commit browser
function fgl --description "Browse git commits with fzf"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    git log --oneline --color=always | fzf --ansi --preview 'git show --color=always (echo {} | cut -d" " -f1)' --preview-window=right:60%
end

# Git file browser with status
function fgs --description "Browse git status files with fzf"
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    set -l file (git status --porcelain | fzf --preview 'git diff --color=always (echo {} | cut -c4-)' --preview-window=right:60% | cut -c4-)
    if test -n "$file"
        commandline -i "$file"
    end
end

# Process killer
function fkill --description "Kill process with fzf"
    set -l pid (ps -ef | sed 1d | fzf --multi --preview 'echo {}' | awk '{print $2}')
    if test -n "$pid"
        echo "Killing process(es): $pid"
        kill -9 $pid
    end
end

# Command history search (enhanced)
function fh --description "Search command history with fzf"
    set -l cmd (history | fzf --tiebreak=index --preview 'echo {}' --preview-window=up:3:wrap)
    if test -n "$cmd"
        commandline -r "$cmd"
    end
end

# Environment variable browser
function fenv --description "Browse environment variables with fzf"
    set -l var (env | fzf --preview 'echo {}' | cut -d= -f1)
    if test -n "$var"
        commandline -i "\$$var"
    end
end

# Enhanced SSH connection manager
function fssh --description "Connect to SSH hosts with fzf"
    if test -f ~/.ssh/config
        set -l host (grep "^Host " ~/.ssh/config | awk '{print $2}' | grep -v '*' | fzf --preview 'grep -A5 "^Host {}" ~/.ssh/config')
        if test -n "$host"
            ssh "$host"
        end
    else
        echo "No SSH config file found at ~/.ssh/config"
    end
end

# Docker container manager
function fdocker --description "Manage Docker containers with fzf"
    if not command -q docker
        echo "Docker not found"
        return 1
    end

    set -l action (echo -e "ps\nexec\nlogs\nstop\nstart\nremove" | fzf --prompt="Docker action: ")

    switch "$action"
        case "ps"
            docker ps -a | fzf --header-lines=1 --preview 'docker inspect (echo {} | awk "{print \$1}")' --preview-window=right:50%
        case "exec"
            set -l container (docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 | awk '{print $1}')
            if test -n "$container"
                docker exec -it "$container" /bin/bash
            end
        case "logs"
            set -l container (docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 | awk '{print $1}')
            if test -n "$container"
                docker logs -f "$container"
            end
        case "stop"
            set -l container (docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 --multi | awk '{print $1}')
            if test -n "$container"
                docker stop $container
            end
        case "start"
            set -l container (docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 --multi | awk '{print $1}')
            if test -n "$container"
                docker start $container
            end
        case "remove"
            set -l container (docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | fzf --header-lines=1 --multi | awk '{print $1}')
            if test -n "$container"
                echo "Are you sure you want to remove: $container? (y/N)"
                read -l confirm
                if test "$confirm" = "y" -o "$confirm" = "Y"
                    docker rm $container
                end
            end
    end
end

# Project switcher (looks for git repos)
function fproject --description "Switch to project directory with fzf"
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

    set -l selected (printf '%s\n' $projects | fzf --preview 'if test -f {}/README.md; bat --color=always {}/README.md | head -20; else ls -la {}; end')
    if test -n "$selected"
        cd "$selected"
        commandline -f repaint
    end
end

# npm/yarn/pnpm script runner
function fnpm --description "Run npm/yarn/pnpm scripts with fzf"
    if test -f package.json
        set -l script (jq -r '.scripts | keys[]' package.json 2>/dev/null | fzf --preview 'jq -r ".scripts.\"{}\"" package.json')
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

# Kubernetes context and namespace switcher
function fkube --description "Switch Kubernetes context and namespace with fzf"
    if not command -q kubectl
        echo "kubectl not found"
        return 1
    end

    set -l action (echo -e "context\nnamespace\npods\nservices\nlogs" | fzf --prompt="Kubernetes action: ")

    switch "$action"
        case "context"
            set -l context (kubectl config get-contexts -o name | fzf --preview 'kubectl config view --minify --context={}')
            if test -n "$context"
                kubectl config use-context "$context"
            end
        case "namespace"
            set -l namespace (kubectl get namespaces -o name | sed 's|^namespace/||' | fzf --preview 'kubectl describe namespace {}')
            if test -n "$namespace"
                kubectl config set-context --current --namespace="$namespace"
            end
        case "pods"
            kubectl get pods | fzf --header-lines=1 --preview 'kubectl describe pod (echo {} | awk "{print \$1}")' --preview-window=right:50%
        case "services"
            kubectl get services | fzf --header-lines=1 --preview 'kubectl describe service (echo {} | awk "{print \$1}")' --preview-window=right:50%
        case "logs"
            set -l pod (kubectl get pods -o name | sed 's|^pod/||' | fzf --preview 'kubectl describe pod {}')
            if test -n "$pod"
                kubectl logs -f "$pod"
            end
    end
end

# AWS profile switcher
function faws --description "Switch AWS profile with fzf"
    if test -f ~/.aws/credentials
        set -l profile (grep '^\[' ~/.aws/credentials | sed 's/\[//g' | sed 's/\]//g' | fzf --preview 'aws configure list --profile {}')
        if test -n "$profile"
            set -gx AWS_PROFILE "$profile"
            echo "AWS_PROFILE set to: $profile"
        end
    else
        echo "No AWS credentials file found at ~/.aws/credentials"
    end
end

# Enhanced ECS cluster function (already exists in your config, but improved)
function fecs --description "Select ECS cluster with fzf"
    if not command -q aws
        echo "AWS CLI not found"
        return 1
    end

    set -l profile_arg ""
    if test (count $argv) -gt 0
        set profile_arg "--profile $argv[1]"
    end

    set -l cluster (aws ecs list-clusters --query 'clusterArns[]' --output text $profile_arg 2>/dev/null | sed 's#.*/##' | fzf --preview "aws ecs describe-clusters --clusters {} $profile_arg --query 'clusters[0]' --output table")
    if test -n "$cluster"
        echo $cluster
    end
end

# File content search with ripgrep/grep
function frg --description "Search file contents with fzf and ripgrep"
    if command -q rg
        # Handle arguments properly in Fish shell
        set -l search_term ""
        if test (count $argv) -gt 0
            set search_term $argv
        end

        rg --color=always --line-number --no-heading --smart-case $search_term |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' |
        cut -d: -f1,2 | sed 's/:/ +/'
    else
        echo "ripgrep (rg) not found. Install with: brew install ripgrep"
    end
end

# =============================================================================
# FZF ALIASES
# =============================================================================

# Short aliases for commonly used functions
alias fif ff          # Find files
alias fd fcd          # Change directory (note: conflicts with fd command, use fcd directly)
alias fgit fgl        # Git log browser
alias pk fkill        # Process killer
alias hist fh         # History search

# =============================================================================
# FZF KEY BINDINGS
# =============================================================================

# Key bindings for Fish shell (only set if interactive)
if status is-interactive
    # Ctrl+T - Insert file path
    bind \ct 'ff; commandline -f repaint'

    # Ctrl+R - Search command history
    bind \cr 'fh; commandline -f repaint'

    # Alt+C - Change directory
    bind \ec 'fcd; commandline -f repaint'

    # Ctrl+G - Git branch switcher
    bind \cg 'fgb; commandline -f repaint'

    # Ctrl+Alt+G - Git status files
    bind \e\cg 'fgs; commandline -f repaint'

    # Ctrl+Alt+P - Project switcher
    bind \e\cp 'fproject; commandline -f repaint'
end
