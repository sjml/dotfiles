#!/usr/bin/env bash

# make sure we're in the right place...
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# symlink the designated dotfiles
./install_symlinks

# throw in our preferred monospace font
mkdir -p ~/.fonts
cp ./resources/Inconsolata/*.tff ~/.fonts/

# Install pip, but not the Python packages
easy_install --user pip
local pyPrefix=".local/bin"

# install zsh-nvm, Node.js, and yarn, but nothing else
zsh -i -c 'nvm install node'
zsh -i -c 'nvm use node'
zsh -i -c 'npm install -g yarn'

# Attempt to change the default shell to zsh
currentShell=$(expr "$SHELL" : '.*/\(.*\)')
targetZShell=$(grep /zsh$ /etc/shells | tail -1)
if [ "$currentShell" != "zsh" ]; then
  printf "Looks like zsh isn't your default shell. Trying to change that..."
  chsh -s $targetZShell
fi

cd ~
read -n 1 -p "And that's it! You're good to go. Press any key to close out."
exec $targetZShell
