#!/bin/bash

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
echo "Need sudo access to install homebrew and pip; after this you can walk away."
sudo -v

# install pip and homebrew
sudo easy_install pip
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# # homebrew installer invalidates sudo credentials, but we don't need it anymore

# TODO: copy dotfiles like here https://github.com/holman/dotfiles/blob/master/script/bootstrap

# copy Inconsolata
# doing this outside of Cask because I handle all other fonts on their own,
#  and Inconsolata is my go-to for terminal/editor/etc. so want to make sure
#  it's available since it's name-checked in a couple config files.
cp ../Inconsolata/*.ttf ~/Library/Fonts/

# all the goodies! (see Brewfile for list)
brew bundle

# python setup
pip install --user -r python-packages.txt

# node setup
git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
zsh -i -c 'nvm install node'
zsh -i -c 'nvm use node'
zsh -i -c 'npm install -g yarn'
zsh -i -c 'yarn global add typescript angular-cli fkill-cli live-server gify'

# NLP data comes last because it can take a looooong time
python -m nltk.downloader all
python -m spacy.en.download all
