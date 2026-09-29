#!/usr/bin/env bash
# Symlink every file in this repo into $HOME. Existing files are moved to *.bak.
set -euo pipefail
cd "$(dirname "$0")"
DOTFILES="$PWD"

FILES=(
  .zshrc
  .zshenv
  .zprofile
  .gitconfig
  .config/git/wsl-managed.gitconfig
  .config/starship.toml
  .config/nvim
  .config/tmux/tmux.conf
  .config/mise/config.toml
)

for f in "${FILES[@]}"; do
  target="$HOME/$f"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.bak"
    echo "backed up $target -> $target.bak"
  fi
  ln -sfn "$DOTFILES/$f" "$target"
  echo "linked $target"
done
