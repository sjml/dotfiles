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

# make sure we're running in a local git working copy
#  (this hooks us in if we were set up from the bootstrap script)
if [[ ! -d .git ]]; then
  git init
  git remote add origin https://github.com/sjml/dotfiles.git
  git fetch
  git reset origin/master
fi
# ensure that submodules are set up
if [[ ! -d zsh.d.symlink/vendor/zsh-autosuggestions/src ]]; then
  git submodule update --init --recursive
fi

# Projects folder is where most code stuff lives; link this there, too,
#  because otherwise I'll forget where it is
mkdir -p ~/Projects
ln -s $DOTFILES_ROOT ~/Projects/dotfiles

# throw in our preferred monospace font
mkdir -p ~/.fonts
cp ./resources/Inconsolata/*.ttf ~/.fonts/

# any vim bundles
vim +PluginInstall +qall

# Install pip
easy_install --user pip
local pyPath="$(python -m site --user-base)/bin"
# not automatically installing things with pip in this script

# install zsh-nvm, Node.js, and yarn, but nothing else
zsh -i -c 'nvm install node; \
           nvm use node; \
           npm install -g yarn'

cd ~
read -n 1 -p "And that's it! You're good to go. Press any key to close out."
exec $targetZShell
