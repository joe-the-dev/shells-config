if test -f $HOME/.env
    bass source $HOME/.env
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

eval (/opt/homebrew/bin/brew shellenv)
eval (direnv hook fish)
#eval (env _AWS_COMPLETE=fish_source aws)
source (brew --prefix asdf)/libexec/asdf.fish
set fish_greeting

set -gx TERM xterm-256color
set -Ux ASDF_NODEJS_VERIFY_RELEASE_SIGNATURES no
set -Ux HOMEBREW_PREFIX /opt/homebrew
set -x SSH_AUTH_SOCK ~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh

set -l asdf_dir ~/.asdf
# Add Homebrew to PATH
set -x PATH $HOMEBREW_PREFIX/bin $HOMEBREW_PREFIX/sbin $PATH

# Add JetBrain to PATH if directory exists
if test -d $HOME/jetbrain
    set -x PATH $HOME/jetbrain $PATH
end

alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias k kubectl
alias kl kubectl
alias kctl kubectl
alias konf "kubectl config"
alias kfwd "kpfwd"

alias vi nvim

command -qv nvim && alias vim nvim

if type -q eza
  alias ll "eza -l -g --icons"
  alias lla "ll -a"
end

function __check_rvm --on-variable PWD --description 'Do nvm stuff'
  status --is-command-substitution; and return

  if test -f .nvmrc; and test -r .nvmrc;
    nvm use
  else
  end
end

function realclear
	clear
       	printf '\e[3J'
end

function pnpm_format
	pnpm format
	pnpm lint:fix
end

function pnpm_document
	pnpm run generate:zod:schema:validators
	pnpm run generate:sca-profile-adaptor:spec:types
	pnpm run generate:types:and:validators
end

alias clr realclear
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims


function ecs-cluster
    set cluster (aws ecs list-clusters --query 'clusterArns[]' --output text --profile $argv[1] | sed 's#.*/##' | fzf)
    if test -n "$cluster"
        echo $cluster
    end
end

# Created by `pipx` on 2025-08-06 07:17:37
set PATH $PATH /Users/joe.ta/.local/bin

# pnpm
set -gx PNPM_HOME "/Users/joe.ta/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

 abbr --add zz 'fg'

function upgrade-all
    if type -q brew
        echo 'Upgrading Homebrew...'
        brew update && brew upgrade
    end
    if type -q asdf
        echo 'Upgrading asdf...'
        asdf plugin-update --all; and asdf update
    end
    if type -q pnpm
        echo 'Upgrading pnpm...'
        pnpm self-update
    end
    if type -q npm
        echo 'Upgrading npm...'
        npm update -g
    end
    if type -q omf
        echo 'Upgrading omf...'
        omf update
    end
    echo 'All upgrades complete.'
end

function backup
    # Change to the shells-config directory
    set -l config_dir "$SHELL_BACKUP_DIR"

    if not test -d "$config_dir"
        echo "❌ ERROR: Configuration directory not found at $config_dir"
        echo "💡 Make sure SHELL_BACKUP_DIR is set correctly"
        return 1
    end

    echo "🚀 Running backup using make system..."

    # Change to config directory and run make
    pushd "$config_dir"

    # Check if --sync flag is provided
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

# Load FZF configurations and functions
if test -f ~/.config/fish/fzf.fish
    source ~/.config/fish/fzf.fish
end

# Load PECO configurations and functions
if test -f ~/.config/fish/peco.fish
    source ~/.config/fish/peco.fish
end
