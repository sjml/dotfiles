#!/usr/bin/env bash

# make sure we're in the right place...
cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd -P)

# having us echo all output
set -x

# # looks like Homebrew handles this now!
# xcode-select -p
# while [ $? -ne 0 ]; do
#   xcode-select --install
#   read -n 1 -p "A dialog should be up asking to install command line tools. \nPress any key when finished."
#   xcode-select -p
# done

read -n 1 -p "Make sure you're signed in to the Mac App Store before continuing. Press Ctrl-C to cancel."

# Ask for the administrator password upfront
echo "Need sudo access to install homebrew; after this you can walk away."
sudo -v

# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# # homebrew installer invalidates sudo credentials, but we don't need it anymore

# copy dotfiles
./install_symlinks

# copy Inconsolata
# doing this outside of Cask because I handle all other fonts on their own,
#  and Inconsolata is my go-to for terminal/editor/etc. so want to make sure
#  it's available since it's name-checked in a couple config files.
cp ./resources/Inconsolata/*.ttf ~/Library/Fonts/

# all the goodies! (see ./Brewfile for list)
brew bundle

# python setup
easy_install --user pip
local pyPrefix="~/Library/Python/2.7/bin"
$pyPrefix/pip install --user -r python-packages.txt

# node setup
zsh -i -c 'nvm install node'
zsh -i -c 'nvm use node'
zsh -i -c 'npm install -g yarn'
zsh -i -c 'yarn global add typescript angular-cli fkill-cli live-server gify'

# NLP data comes last because it can take a looooong time
$pyPrefix/bin/python -m nltk.downloader all
$pyPrefix/bin/python -m spacy.en.download all

# try to set zsh up as the shell
currentShell=$(expr "$SHELL" : '.*/\(.*\)')
targetZShell=$(grep /zsh$ /etc/shells | tail -1)
if [ "$currentShell" != "zsh" ]; then
  printf "Looks like zsh isn't your default shell. Trying to change that..."
  chsh -s $targetZShell
fi

cd ~
read -n 1 -p "And that's it! You're good to go. Press any key to close out."
exec $targetZShell
