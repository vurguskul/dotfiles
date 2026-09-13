# dotfiles

Personal dotfiles for a terminal-centric development setup: **tmux**, **Vim**, and
**zsh** (oh-my-zsh), plus a small installer that symlinks them into `$HOME`.

## Contents

| File            | Purpose |
|-----------------|---------|
| `tmux.conf`     | tmux configuration (targets tmux 3.0+) |
| `vimrc`         | Vim configuration, managed with Vundle |
| `zshrc`         | zsh configuration, loads oh-my-zsh |
| `dotfiles.zsh-theme` | Custom oh-my-zsh prompt theme (user@host, time, path, git branch) |
| `clipboard-copy` | Helper tmux pipes copied text to; picks a clipboard backend and drops empty input |
| `setup.sh`      | Backs up existing dotfiles, installs zsh + oh-my-zsh + zsh-autosuggestions/zsh-syntax-highlighting + clipboard tools, symlinks these into `$HOME`, installs plugin managers |

## Install

```bash
git clone https://github.com/vurguskul/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` will:

1. Move any existing `~/.tmux.conf` / `~/.vimrc` / `~/.zshrc` aside to `*_bak`.
2. Install `zsh` via the detected package manager (`pacman`/`apt`/`dnf`/`brew`) if missing.
3. Install `zsh-autosuggestions` and `zsh-syntax-highlighting` via the same package
   manager.
4. Install `wl-clipboard` and `xclip` so tmux copies reach the system clipboard
   (on macOS the built-in `pbcopy` is used instead).
5. Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) into `~/.oh-my-zsh` (unattended;
   keeps our `zshrc`, does not `chsh` or launch a shell).
6. Symlink `tmux.conf` → `~/.tmux.conf`, `vimrc` → `~/.vimrc`, `zshrc` → `~/.zshrc`,
   `clipboard-copy` → `~/.local/bin/clipboard-copy`, and `dotfiles.zsh-theme` →
   `~/.oh-my-zsh/custom/themes/dotfiles.zsh-theme`.
7. Clone [Vundle](https://github.com/VundleVim/Vundle.vim) into `~/.vim/bundle/Vundle.vim`.
8. Clone [tpm](https://github.com/tmux-plugins/tpm) into `~/.tmux/plugins/tpm` and
   install the tmux plugins listed in `tmux.conf`, reloading a running tmux server.
9. Set `zsh` as the default login shell (`chsh`) if it isn't already.

### Finish setup

- **Vim plugins:** open Vim and run `:PluginInstall`. `YouCompleteMe` needs a
  separate compile step (`~/.vim/bundle/YouCompleteMe/install.py`).
- **tmux plugins:** `setup.sh` installs these already. If you edit the `@plugin`
  list later, press `prefix + I` (prefix is `C-a`) inside tmux, or run
  `~/.tmux/plugins/tpm/bin/install_plugins`. tpm only loads plugins that are
  already on disk, so a missing clone leaves them silently inactive.
- **zsh:** log out and back in for the shell change to take effect. Put machine-local
  tweaks in `~/.zshrc.local` (sourced if present, not tracked here).

## tmux highlights

- Prefix remapped from `C-b` to **`C-a`**.
- Split panes with `prefix + \` (horizontal) and `prefix + -` (vertical); new
  panes/windows inherit the current pane's directory.
- `Alt + arrows` to move between panes, `Ctrl+Alt + Left/Right` to switch windows,
  `Alt+Shift + arrows` to resize.
- Mouse mode on, `vi` copy/status keys, 10k-line history.
- **Copy to the system clipboard.** In copy mode (`prefix + [`): `v` starts a
  selection, `C-v` toggles block selection, `y` (or `Enter`) copies and exits,
  `Y` copies without clearing the selection. Releasing a mouse drag copies too.
  `prefix + C-v` pastes the system clipboard into the pane.
  tmux pipes every copy to `clipboard-copy` (via `copy-command`), which picks a
  backend at run time — `wl-copy` on Wayland, else `xclip` / `xsel` / `pbcopy`.
  `set-clipboard on` additionally emits OSC 52, so copying still works over SSH or
  with no clipboard binary installed, given terminal support.

  `clipboard-copy` deliberately ignores empty input. tmux pipes an empty selection
  whenever a copy key is pressed without one — pressing `Enter` to leave copy mode,
  a stray drag, a double-click on blank space — and handing zero bytes to `wl-copy`
  makes it claim the clipboard while offering only `application/x-zerosize`. Every
  later paste then fails (`No compatible transfer format found` in GTK apps), so
  without the guard those keystrokes silently wipe the clipboard.
- `prefix + r` reloads the config.
- Plugins: `tmux-sensible`, `tmux-resurrect`, `tmux-continuum` (auto restore of
  sessions, panes, and shell history), `tmux-colors-solarized` (dark).

## vimrc highlights

- Vundle-managed plugins including `vim-colorschemes`, `plantuml-syntax` /
  `vim-slumlord`, and a Python stack (`indentpython`, `syntastic`, `vim-flake8`,
  `YouCompleteMe`).
- 2-space indentation, `expandtab`, line numbers, 256-color forced,
  system clipboard (`unnamedplus`).
- `colorscheme ron`.
- `Jenkinsfile` is treated as Groovy syntax.
- Register macros for editing C/C++ includes:
  - `@l` — convert `"header.h"` to `<header.h>` on the current line.
  - `@g` — convert `<header.h>` back to `"header.h"`.

## zshrc highlights

- Loads oh-my-zsh with the custom `dotfiles` theme (`dotfiles.zsh-theme`, symlinked
  into `~/.oh-my-zsh/custom/themes/`) and the `git` / `tmux` / `history-substring-search`
  plugins. Two-line prompt: `user@host` (bold), 24h time with seconds, the full path
  (white), and the git branch on top, with a short `-> %` prompt below to type
  commands, e.g.:
  ```
  user@hostname [17:55:00] [~/development/dotfiles] [master]
  -> %
  ```
- Up/down arrows and vi `k`/`j` search history by the currently typed prefix
  (`history-substring-search`).
- `zsh-autosuggestions` and `zsh-syntax-highlighting`, installed via the system
  package manager by `setup.sh`, are sourced directly from their package install
  path (not via oh-my-zsh's custom plugin mechanism).
- 10k-line shared history with de-duplication.
- `EDITOR`/`VISUAL` set to `vim`.
- Sources `~/.zshrc.local` for machine-specific settings if it exists.

## Notes

- No `bashrc` or Git config is included.
