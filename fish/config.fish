if status is-interactive
    # Commands to run in interactive sessions can go here
end

eval (/opt/homebrew/bin/brew shellenv)
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
