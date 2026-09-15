# Path to oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Custom theme: ~/.oh-my-zsh/custom/themes/dotfiles.zsh-theme
# (setup.sh symlinks it from this repo). Shows folder, git branch, time.
ZSH_THEME="dotfiles"

# The prompt runs git status on every command, and scanning for untracked files
# is the slow half of that in a large repo. The theme shows one ✗ either way.
DISABLE_UNTRACKED_FILES_DIRTY=true

# zsh-completions installs into site-functions, which is already on fpath on
# Linux; Homebrew's prefix is not, so add it when it exists.
for _p in /opt/homebrew/share/zsh-completions /usr/local/share/zsh-completions; do
    [ -d "$_p" ] && fpath=("$_p" $fpath)
done

# Plugins live in ~/.oh-my-zsh/plugins/* and ~/.oh-my-zsh/custom/plugins/*
plugins=(
    git
    tmux
    history-substring-search
    fzf                  # Ctrl-R history, Ctrl-T files, Alt-C cd
    command-not-found    # unknown command -> the package that provides it
    extract              # x <archive>, any format
    colored-man-pages
    sudo                 # Esc Esc prefixes the current line with sudo
    copypath             # cwd to the clipboard
    copyfile             # file contents to the clipboard
    copybuffer           # Ctrl-O: current command line to the clipboard
    fancy-ctrl-z         # Ctrl-Z on an empty line resumes the last job
    gh
)

source "$ZSH/oh-my-zsh.sh"

# history-substring-search: up/down search history by the typed prefix
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# fzf: fd honours .gitignore and beats the default find walk. Ctrl-T and Alt-C
# inherit FZF_DEFAULT_COMMAND, but Alt-C needs directories rather than files.
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
fi

# oh-my-zsh already turns on menu selection and case-insensitive matching; these
# only add the headers saying which group a match came from.
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' list-dirs-first true

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups
setopt share_history

# Editor
export EDITOR="vim"
export VISUAL="vim"

# Local overrides, not tracked in the repo
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# zsh-autosuggestions: fall back to completion when history has no match, and
# stop searching once the line is long enough to be a paste rather than
# something being typed. Both must be set before the plugin is sourced.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=200

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
