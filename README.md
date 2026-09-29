# dotfiles

zsh, git, starship, nvim, tmux and mise config for my WSL (Ubuntu) setup.

## Install

```sh
git clone https://github.com/kevinyhe/dotfiles ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` symlinks each file into `$HOME`. Any file already there is moved to `<name>.bak`.

## Add a new file

1. Move it into the repo at the same path it has under `$HOME`.
2. Add the path to the `FILES` list in `install.sh`.
3. Run `./install.sh`.
