# dotfiles.zsh-theme
# Two-line prompt: user@host (bold), 24h time with seconds, full path (white),
# and git branch (if any) on top; a short "-> %" prompt below to type commands.
# e.g.
# diver@legion-edeavour [17:55:00] [~/development/dotfiles] [master]
# -> %

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT=$'%{$fg_bold[green]%}%n@%m%{$reset_color%} %{$fg[cyan]%}[%*]%{$reset_color%} %{$fg[white]%}[%~]%{$reset_color%}$(git_prompt_info)\
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '
