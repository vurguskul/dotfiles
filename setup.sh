#!/bin/bash

# Back up real files that are in the way, but leave existing symlinks alone
# (re-running setup.sh just refreshes them below).
for f in .tmux.conf .vimrc .zshrc; do
    if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        echo "Existing $f was found. Moving to ${f}_bak ...!"
        mv "$HOME/$f" "$HOME/${f}_bak"
    fi
done

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
mkdir -p ~/.oh-my-zsh/custom/themes
ln -sfn "$DIR/dotfiles.zsh-theme" ~/.oh-my-zsh/custom/themes/dotfiles.zsh-theme

echo "Installing plugin managers..."
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

if command -v zsh >/dev/null 2>&1 && [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "Setting zsh as the default shell..."
    chsh -s "$(command -v zsh)"
fi
