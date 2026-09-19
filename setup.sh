#!/bin/bash

# Back up real files that are in the way, but leave existing symlinks alone
# (re-running setup.sh just refreshes them below).
for f in .tmux.conf .vimrc .zshrc; do
    if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        echo "Existing $f was found. Moving to ${f}_bak ...!"
        mv "$HOME/$f" "$HOME/${f}_bak"
    fi
done
if [ -f "$HOME/.config/gtk-4.0/gtk.css" ] && [ ! -L "$HOME/.config/gtk-4.0/gtk.css" ]; then
    echo "Existing gtk-4.0/gtk.css was found. Moving to gtk.css_bak ...!"
    mv "$HOME/.config/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css_bak"
fi

echo "Installing zsh..."
if ! command -v zsh >/dev/null 2>&1; then
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm zsh
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh
    elif command -v brew >/dev/null 2>&1; then
        brew install zsh
    else
        echo "No supported package manager found. Please install zsh manually."
    fi
else
    echo "zsh is already installed."
fi

echo "Installing zsh-autosuggestions and zsh-syntax-highlighting..."
if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y zsh-autosuggestions zsh-syntax-highlighting
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting
elif command -v brew >/dev/null 2>&1; then
    brew install zsh-autosuggestions zsh-syntax-highlighting
else
    echo "No supported package manager found. Please install zsh-autosuggestions and zsh-syntax-highlighting manually."
fi

# Extra completion definitions for tools zsh does not ship completions for.
# Not packaged everywhere, so a miss here must not fail the rest of the install.
echo "Installing zsh-completions (optional)..."
if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm zsh-completions || echo "zsh-completions unavailable, skipping."
elif command -v brew >/dev/null 2>&1; then
    brew install zsh-completions || echo "zsh-completions unavailable, skipping."
else
    echo "No zsh-completions package for this platform, skipping."
fi

# The command-not-found plugin needs pkgfile's file database on Arch; without a
# populated cache the plugin loads and silently does nothing.
if command -v pacman >/dev/null 2>&1; then
    echo "Installing pkgfile for command-not-found..."
    sudo pacman -S --needed --noconfirm pkgfile
    if [ -z "$(ls -A /var/cache/pkgfile 2>/dev/null)" ]; then
        echo "Populating the pkgfile database (first run, this downloads a few MB)..."
        sudo pkgfile --update
    fi
    sudo systemctl enable --now pkgfile-update.timer 2>/dev/null || true
fi

echo "Installing clipboard tools (tmux copy -> system clipboard)..."
if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm wl-clipboard xclip
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y wl-clipboard xclip
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y wl-clipboard xclip
elif command -v pbcopy >/dev/null 2>&1; then
    echo "macOS pbcopy is built in, nothing to install."
else
    echo "No supported package manager found. Please install wl-clipboard or xclip manually."
fi

echo "Installing oh-my-zsh..."
if [ ! -d $HOME/.oh-my-zsh ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "oh-my-zsh is already installed."
fi

echo "Creating links..."
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ln -sfn "$DIR/tmux.conf" ~/.tmux.conf
ln -sfn "$DIR/vimrc" ~/.vimrc
ln -sfn "$DIR/zshrc" ~/.zshrc
mkdir -p ~/.local/bin
ln -sfn "$DIR/clipboard-copy" ~/.local/bin/clipboard-copy
mkdir -p ~/.oh-my-zsh/custom/themes
ln -sfn "$DIR/dotfiles.zsh-theme" ~/.oh-my-zsh/custom/themes/dotfiles.zsh-theme
# GTK 4 reads this stylesheet once, at application start: GNOME Console has to
# be restarted before the header bar goes away.
mkdir -p ~/.config/gtk-4.0
ln -sfn "$DIR/gtk4.css" ~/.config/gtk-4.0/gtk.css

# Console keeps its settings in gsettings rather than in a config file, so the
# font is set here instead. use-system-font has to go first: custom-font is
# ignored while it is true. font-scale, the Ctrl +/- zoom, is deliberately left
# alone - it is a per-session thing, not a preference.
KGX_FONT='Monospace 12'
if command -v gsettings >/dev/null 2>&1 &&
    gsettings writable org.gnome.Console custom-font >/dev/null 2>&1; then
    echo "Setting the GNOME Console font to $KGX_FONT..."
    gsettings set org.gnome.Console use-system-font false
    gsettings set org.gnome.Console custom-font "$KGX_FONT"
fi

echo "Installing plugin managers..."
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else
    echo "Vundle is already installed."
fi
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "tpm is already installed."
fi

# tpm only loads plugins that are already on disk; cloning tpm alone leaves
# tmux-resurrect & co. missing and silently inactive.
echo "Installing tmux plugins..."
~/.tmux/plugins/tpm/bin/install_plugins
if tmux has-session 2>/dev/null; then
    echo "Reloading tmux config in the running server..."
    tmux source-file ~/.tmux.conf
fi

if command -v zsh >/dev/null 2>&1 && [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "Setting zsh as the default shell..."
    chsh -s "$(command -v zsh)"
fi
