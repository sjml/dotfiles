#!/usr/bin/env bash

# set up input
exec </dev/tty >/dev/tty

# make sure we're in the right place...
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

# Attempt to change the default shell to zsh
currentShell=$(expr "$SHELL" : '.*/\(.*\)')
targetZShell=$(grep /zsh$ /etc/shells | tail -1)
if [[ "$currentShell" != "zsh" ]]; then
  printf "Looks like zsh isn't your default shell. Trying to change that..."
  chsh -s $targetZShell
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
  git init
  git remote add origin https://github.com/sjml/dotfiles.git
  git fetch
  git reset origin/master
  git branch --set-upstream-to=origin/master master
fi
# swap to ssh; credentials can get added later
git remote set-url origin git@github.com:sjml/dotfiles.git

# Projects folder is where most code stuff lives; link this there, too,
#  because otherwise I'll forget where it is
mkdir -p ~/Projects
ln -s $DOTFILES_ROOT ~/Projects/dotfiles

# any vim bundles
vim +PluginInstall +qall

# Install pip
easy_install --quiet --user pip
local pyPath="$(python -m site --user-base)/bin"
# not automatically installing things with pip in this script

# install zsh-nvm, Node.js, and yarn, but nothing else
zsh -i -c 'nvm install node; \
           nvm use node;'
          #  npm install -g yarn'

cd ~
echo "And that's it! You're good to go."
