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
| `gtk4.css`      | GTK 4 user stylesheet; hides the GNOME Console window header bar |
| `ghostty.conf`  | Ghostty configuration; the Console setup (font, colours, no header bar) plus OSC 52 clipboard access |
| `ghostty-themes/` | Ghostty themes with GNOME Console's default colours, a day and a night one |
| `setup.sh`      | Backs up existing dotfiles, installs zsh + oh-my-zsh + zsh-autosuggestions/zsh-syntax-highlighting + fzf/fd + clipboard tools + Ghostty, symlinks these into `$HOME`, installs plugin managers |

## Install

```bash
git clone https://github.com/vurguskul/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` will:

1. Move any existing `~/.tmux.conf` / `~/.vimrc` / `~/.zshrc` /
   `~/.config/gtk-4.0/gtk.css` / `~/.config/ghostty/config.ghostty` aside to `*_bak`.
2. Install `zsh` via the detected package manager (`pacman`/`apt`/`dnf`/`brew`) if missing.
3. Install `zsh-autosuggestions` and `zsh-syntax-highlighting` via the same package
   manager.
4. Install `zsh-completions` where it is packaged (Arch, Homebrew). Optional — a
   platform without it is logged and skipped rather than failing the run.
5. Install `fzf` and `fd`, which the `fzf` oh-my-zsh plugin needs — without `fzf`
   present, oh-my-zsh fails to start with "Cannot find fzf installation directory."
   On Debian/Ubuntu, `fd-find` installs its binary as `fdfind`; it gets symlinked
   to `~/.local/bin/fd` since that's the name zshrc and the fzf plugin look for.
6. On Arch, install `pkgfile` and populate its file database (and enable
   `pkgfile-update.timer`), which the `command-not-found` plugin needs; without a
   populated cache that plugin loads and silently does nothing.
7. Install `wl-clipboard` and `xclip` so tmux copies reach the system clipboard
   (on macOS the built-in `pbcopy` is used instead).
8. Install [Ghostty](https://ghostty.org) if missing: `pacman` on Arch, the
   Homebrew cask on macOS, the snap elsewhere (Debian/Ubuntu and Fedora only
   have it in third-party repos).
9. Install [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) into `~/.oh-my-zsh` (unattended;
   keeps our `zshrc`, does not `chsh` or launch a shell).
10. Symlink `tmux.conf` → `~/.tmux.conf`, `vimrc` → `~/.vimrc`, `zshrc` → `~/.zshrc`,
    `clipboard-copy` → `~/.local/bin/clipboard-copy`, `dotfiles.zsh-theme` →
    `~/.oh-my-zsh/custom/themes/dotfiles.zsh-theme`, `gtk4.css` →
    `~/.config/gtk-4.0/gtk.css`, `ghostty.conf` →
    `~/.config/ghostty/config.ghostty`, and each file in `ghostty-themes/` into
    `~/.config/ghostty/themes/`.
11. Set the GNOME Console font to `Monospace 12` (the `KGX_FONT` variable in
    `setup.sh`). Console has no config file — its settings are gsettings keys.
12. Clone [Vundle](https://github.com/VundleVim/Vundle.vim) into `~/.vim/bundle/Vundle.vim`.
13. Clone [tpm](https://github.com/tmux-plugins/tpm) into `~/.tmux/plugins/tpm` and
    install the tmux plugins listed in `tmux.conf`, reloading a running tmux server.
14. Set `zsh` as the default login shell (`chsh`) if it isn't already.

### Finish setup

- **Vim plugins:** open Vim and run `:PluginInstall`. `YouCompleteMe` needs a
  separate compile step (`~/.vim/bundle/YouCompleteMe/install.py`).
- **tmux plugins:** `setup.sh` installs these already. If you edit the `@plugin`
  list later, press `prefix + I` (prefix is `C-a`) inside tmux, or run
  `~/.tmux/plugins/tpm/bin/install_plugins`. tpm only loads plugins that are
  already on disk, so a missing clone leaves them silently inactive.
- **zsh:** log out and back in for the shell change to take effect. Put machine-local
  tweaks in `~/.zshrc.local` (sourced if present, not tracked here).
- **GNOME Console:** quit every Console window and start a new one. GTK 4 reads
  `~/.config/gtk-4.0/gtk.css` once, when the application starts.
- **Ghostty:** press `Ctrl+Shift+,` in a running Ghostty to reload the config;
  the header bar setting only applies to windows opened afterwards.

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
  into `~/.oh-my-zsh/custom/themes/`). Two-line prompt: `user@host` (bold), 24h
  time with seconds, the full path (white), and the git branch on top, with a
  short `-> %` prompt below to type commands, e.g.:
  ```
  user@hostname [17:55:00] [~/development/dotfiles] [master]
  -> %
  ```
- Up/down arrows search history by the currently typed prefix
  (`history-substring-search`).
- oh-my-zsh plugins and the keys they add:

  | Key | What it does | Plugin |
  |-----|--------------|--------|
  | `Ctrl-R` | fuzzy history search | `fzf` |
  | `Ctrl-T` | fuzzy file picker into the command line | `fzf` |
  | `Alt-C` | fuzzy `cd` | `fzf` |
  | `Ctrl-U` / `Ctrl-D` | half-page up / down inside any fzf picker | `fzf` |
  | `Esc Esc` | prefix the current line with `sudo` | `sudo` |
  | `Ctrl-O` | copy the current line to the clipboard | `copybuffer` |
  | `Ctrl-Z` | on an empty line, resume the last job | `fancy-ctrl-z` |

  Plus `extract` (`x <archive>`, any format), `copypath` / `copyfile`,
  `colored-man-pages`, `command-not-found`, `gh` completions, and `git` / `tmux`.
  `dirhistory` is deliberately *not* enabled: all four of its bindings
  (`Alt` + arrows) are taken by `tmux.conf` for pane switching.
- `fzf` uses `fd` for its file and directory walks when `fd` is installed, so it
  honours `.gitignore` and skips `.git`.
- `FZF_DEFAULT_OPTS` binds `Ctrl-U` / `Ctrl-D` to fzf's `half-page-up` /
  `half-page-down`, which the tool implements but ships unbound. This replaces
  `Ctrl-D`'s default `delete-char/eof` and `Ctrl-U`'s `unix-line-discard` inside
  the picker; `Ctrl-W` still deletes a word and `Esc` / `Ctrl-C` still abort.
  Note the `Ctrl-R` history list is the one widget fzf does *not* draw with
  `--reverse`, so it runs bottom-up and `Ctrl-U` is what walks back into older
  entries - which is the vim direction anyway.
- `zsh-autosuggestions` and `zsh-syntax-highlighting`, installed via the system
  package manager by `setup.sh`, are sourced directly from their package install
  path (not via oh-my-zsh's custom plugin mechanism). Suggestions fall back to
  completion when history has no match, and stop once the line passes 200
  characters, which is long enough to be a paste rather than something typed.
- 100k-line shared history with de-duplication.
- `DISABLE_UNTRACKED_FILES_DIRTY` is set: the prompt runs `git status` on every
  command, and scanning for untracked files is the slow half of that in a large
  repo. The theme shows a single `✗` either way.
- `EDITOR`/`VISUAL` set to `vim`.
- Sources `~/.zshrc.local` for machine-specific settings if it exists.

## gtk4.css highlights

- Hides the **GNOME Console** (`kgx`) window header bar, which costs 46px of
  height and shows a title tmux already puts in its own status line. Console has
  no setting for this, so the bar is hidden in CSS.
- GTK has no `display: none`. The bar is *collapsed* instead: every widget inside
  it is shrunk to zero and made transparent, and a negative top margin on the bar
  swallows the handful of pixels the shrunken children still ask for. The top bar
  area then measures exactly 0px, and 40px (the tab bar alone) once a second tab
  is open.
- The rules are scoped so they touch nothing else:

  | Selector part | Why |
  |---------------|-----|
  | `window.terminal-window` | Console's own window class — bare `headerbar` would flatten the header of every GTK 4 app on the system |
  | `toolbarview.main-box` | the bar around the terminal, not `toolbarview.overview` in the tab overview, whose header has to keep working |
  | `> *:not(popover)` chains | a `GtkPopover` is a child *widget* of its menu button in GTK 4, so `headerbar *` would shrink the main menu along with the bar that opens it |

- With no header bar there is no title to grab and no window buttons:

  | Key | What it does |
  |-----|--------------|
  | `Alt+F10` | maximise / restore |
  | `Super`+`H` | minimise |
  | `Super` + drag | move the window |
  | `Ctrl+Shift+W` | close (or `Ctrl+D` to end the shell) |

  All of those are stock GNOME bindings, so there is nothing to configure.
  Console has no configurable keybindings of its own — `org.gnome.Console` has
  no keys for them — so a terminal-specific shortcut is not on offer: any
  binding added here would be a window-manager one, grabbing the key
  desktop-wide and taking it away from every other application.
- The main menu goes with the bar, and the Preferences window with it. Console's
  settings are `org.gnome.Console` gsettings keys — `gsettings list-recursively
  org.gnome.Console` — so set them from the shell. `setup.sh` sets the font that
  way (`KGX_FONT`, `Monospace 12`); it leaves `font-scale`, the `Ctrl` + `+`/`-`
  zoom, alone.

## ghostty.conf highlights

- [Ghostty](https://ghostty.org) is a GTK 4 terminal that implements **OSC 52**,
  which Console and every other VTE-based terminal lack. With it, tmux's
  `set-clipboard on` and Vim over SSH reach the local clipboard with no
  clipboard binary involved. Ghostty's terminfo (`xterm-ghostty`) advertises the
  `Ms` capability, so tmux picks this up without any `terminal-features` entry.
- Writing the clipboard is allowed; reading it asks first (`clipboard-read =
  ask`), since a silent read would hand the clipboard to anything that prints
  to the terminal, remote hosts included.
- **SSH works on hosts without Ghostty's terminfo.** Out of the box, `ssh` from
  Ghostty fails with `missing or unsuitable terminal: xterm-ghostty`, since
  remote hosts don't know that `TERM`. `shell-integration-features =
  ssh-terminfo,ssh-env` makes Ghostty's zsh integration wrap `ssh`: it installs
  the terminfo entry on each new host (`infocmp` locally, `tic` remotely),
  remembers where it worked (`ghostty +ssh-cache` lists and clears that), and
  falls back to `TERM=xterm-256color` where it can't. Shells inside tmux aren't
  affected, since tmux sets `TERM` to `screen-256color`.
- Same font as Console: `Monospace`, 12pt.
- **Same colours as Console.** `ghostty-themes/console-day` and `console-night`
  carry the palette of Console's default livery, copied from
  `standard_livery()` in its `src/kgx-livery-manager.c`: 16 GNOME-palette
  colours shared by both modes, black on white by day and white on `#1c1c1f` by
  night. `theme = light:console-day,dark:console-night` picks one from the GNOME
  style setting, the way Console's `theme = auto` does. Cursor and selection
  are left unset, as in Console, so both invert the cell.
- **No header bar**, like `gtk4.css` gives Console, but as a plain setting:
  `gtk-titlebar = false`. GNOME draws no server-side title bar on Wayland, so
  the window ends up with none; the tab bar still appears from the second tab
  on. `window-decoration = none` would drop the bar too, but also the window's
  shadow and rounded corners.
- The same stock GNOME keys move, maximise and minimise the window (`Super` +
  drag, `Alt+F10`, `Super`+`H`); `Ctrl+Shift+W` closes the tab.

## Notes

- No `bashrc` or Git config is included.
