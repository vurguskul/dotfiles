# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Custom theme: ~/.oh-my-zsh/custom/themes/dotfiles.zsh-theme
# (setup.sh symlinks it from this repo). Shows folder, git branch, time.
ZSH_THEME="dotfiles"

# Plugins live in ~/.oh-my-zsh/plugins/* and ~/.oh-my-zsh/custom/plugins/*
plugins=(git tmux history-substring-search)

source "$ZSH/oh-my-zsh.sh"

# history-substring-search: up/down and vi j/k search history by the typed prefix
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups
setopt share_history

# Editor
export EDITOR="vim"
export VISUAL="vim"

# Local overrides, not tracked in the repo
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# zsh-autosuggestions / zsh-syntax-highlighting, installed via the system package
# manager (see setup.sh) rather than as oh-my-zsh custom plugins. Highlighting
# must be sourced last, after everything else in this file.
for _p in \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
    [ -f "$_p" ] && source "$_p" && break
done

for _p in \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    [ -f "$_p" ] && source "$_p" && break
done
unset _p
