# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  ZSH Configuration — Fedora KDE Edition
#  Forked from ilyamiro/nixos-configuration
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Aliases (adapted from original nixos-configuration)
alias edit="sudo -E nvim -n"
alias update="sudo dnf upgrade --refresh"
alias stop="systemctl poweroff"
alias edconf="nvim ~/fedora-kde-configuration/"
alias out="loginctl terminate-user $USER"
alias ls="ls --color=auto"
alias ll="ls -la"
alias la="ls -A"
alias grep="grep --color=auto"

# cd + ls
cd() {
  builtin cd "$@" && ls
}

# Source the init script for custom functions
source "$HOME/.config/zsh/zsh-init.sh"

# Oh-My-Zsh (if installed)
if [ -d "$HOME/.oh-my-zsh" ]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  plugins=(git)
  source "$ZSH/oh-my-zsh.sh"
fi

# Environment variables
export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"
