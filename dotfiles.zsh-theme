# dotfiles.zsh-theme
# user@host, 24h time with seconds, full path, git branch (if any).
# e.g. diver@legion-edeavour [17:55:00] [~/development/dotfiles] [master]
# The final prompt char (❯) turns red when the last command exited non-zero.

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%{$fg[green]%}%n@%m%{$reset_color%} %{$fg[cyan]%}[%*]%{$reset_color%} %{$fg[blue]%}[%~]%{$reset_color%}$(git_prompt_info) %(?.%{$fg[green]%}.%{$fg[red]%})❯%{$reset_color%} '
