#!/usr/bin/env bash

# make sure we're in the right place...
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

# Attempt to change the default shell to zsh
currentShell=$(expr "$SHELL" : '.*/\(.*\)')
targetZShell=$(grep /zsh$ /etc/shells | tail -1)
if [ "$currentShell" != "zsh" ]; then
  printf "Looks like zsh isn't your default shell. Trying to change that..."
  chsh -s $targetZShell
fi

# symlink the designated dotfiles
echo "Linking dotfiles; hang out for a second to answer potential prompts about overwriting..."
./install_symlinks.sh

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
