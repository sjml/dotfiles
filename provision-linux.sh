#!/usr/bin/env bash

# set up input
exec </dev/tty >/dev/tty

# make sure we're in the right place...
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

# check that we've installed the basics
GIT=$(which git)
VIM=$(which vim)
if [[ ${#GIT} -eq 0 ]] || [[ ${#VIM} -eq 0 ]]; then
  echo "Install git and vim first, then run provision-linux.sh again."
  exit 1
fi

# symlink the designated dotfiles
echo "Linking dotfiles; hang out for a second to answer potential prompts about overwriting..."
./install_symlinks.sh

# ssh config
echo "Creating SSH configuration..."
mkdir -p ~/.ssh
cp resources/ssh_config.base ~/.ssh/config

# make sure we're running in a local git working copy
#  (this hooks us in if we were set up from the bootstrap script)
if [[ ! -d .git ]]; then
  (
    # don't look at the ~/.gitconfig
    unset HOME
    git init
    git checkout -b main
    git remote add origin https://github.com/sjml/dotfiles.git
    git fetch
    git reset origin/main
    git branch --set-upstream-to=origin/main main
    git checkout .
  )
fi
# swap to ssh; credentials can get added later
git remote set-url origin git@github.com:sjml/dotfiles.git

# Projects folder is where most code stuff lives; link this there, too,
#  because otherwise I'll forget where it is
mkdir -p ~/Projects
ln -s $DOTFILES_ROOT ~/Projects/dotfiles

# any vim bundles
(
  unset HOME
  vim +PluginInstall +qall
)

# Install pyenv
mv $HOME/.gitconfig $HOME/gitconfig.bak
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
mv $HOME/gitconfig.bak $HOME/.gitconfig 

cd ~
echo "And that's it! You're good to go."
