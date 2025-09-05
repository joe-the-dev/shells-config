# Linux Terminal Configuration
# For terminals like GNOME Terminal, Konsole, etc.

# GNOME Terminal Profile Configuration
# Can be exported/imported using dconf

# Default terminal settings that work across most Linux terminals
export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=nvim

# Color scheme settings (can be applied to most terminals)
# These settings work with terminals that support 256 colors

# Terminal title format
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
