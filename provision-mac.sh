#!/usr/bin/env bash

# make sure we're in the right place...
cd "$(dirname "$0")"
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

# try to set zsh up as the shell
currentShell=$(expr "$SHELL" : '.*/\(.*\)')
targetZShell=$(grep /zsh$ /etc/shells | tail -1)
if [ "$currentShell" != "zsh" ]; then
  printf "Looks like zsh isn't your default shell. Trying to change that..."
  chsh -s $targetZShell
fi

# copy dotfiles
echo "Linking dotfiles; hang out for a second to answer potential prompts about overwriting..."
./install_symlinks.sh

# Ask for the administrator password
echo "Now we need sudo access to install homebrew; after this you can walk away."
sudo -v

# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# homebrew installer invalidates sudo credentials, but we won't need them anymore

# Projects folder is where most code stuff lives; link this there, too,
#  because otherwise I'll forget where it is
mkdir -p ~/Projects
ln -s $DOTFILES_ROOT ~/Projects/dotfiles

# copying Inconsolata outside of Cask because I handle all other fonts on 
#  their own, but Inconsolata is my go-to for terminal/editor/etc. so want 
#  to make sure it's available since it's name-checked in a couple config 
#  files.
cp ./resources/Inconsolata/*.ttf ~/Library/Fonts/

# all the goodies! (see ./Brewfile for list)
brew bundle

# python setup
easy_install --user pip
# (this path is set in the zsh configs, but this is bash)
local pyPath="$(python -m site --user-base)/bin"
$pyPath/pip install --user -r python-packages.txt

# node setup
zsh -i -c 'nvm install node; \
           nvm use node; \
           npm install -g yarn typescript angular-cli live-server vorlon surge;'

# NLP data comes last because it can take a looooong time
python -m nltk.downloader all
python -m spacy.en.download all

cd ~
read -n 1 -p "And that's it! You're good to go. Press any key to close out."
exec $targetZShell
