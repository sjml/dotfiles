#!/usr/bin/env bash

local function timerData() {
  echo $1: $SECONDS >> provision_timing.txt
}

# make sure we're in the right place...
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

date >> provision_timing.txt
timerData "START"

# having us echo all output
set -x

# # looks like Homebrew handles this now!
# xcode-select -p
# while [ $? -ne 0 ]; do
#   xcode-select --install
#   echo "A dialog should be up asking to install command line tools. \nPress any key when finished."
#   read -n 1 
#   xcode-select -p
# done

echo "Make sure you're signed in to the Mac App Store before continuing."
echo "Press Ctrl-C to cancel, or any other key to continue."
read -n 1 

# copy dotfiles
echo "Linking dotfiles; hang out for a second to answer potential prompts..."
./install_symlinks.sh

# Ask for the administrator password
echo "Now we need sudo access to install homebrew and change the shell."
echo "After this you can walk away for a bit\!"
sudo -v

timerData "POST-INTERACTIVE"

# install homebrew
export HOMEBREW_NO_ANALYTICS=1
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install zsh real quick so we can chsh to it while we still have sudo
brew install zsh

# try to set zsh up as the shell
targetZShell="/usr/local/bin/zsh"
# targetZShell=$(grep /zsh$ /etc/shells | tail -1)
echo $targetZShell | sudo tee -a /etc/shells
sudo chsh -s $targetZShell $USER

# done with sudo
sudo -k

# make sure we're running in a local git working copy
#  (this hooks us in if we were set up from the bootstrap script)
if [ ! -d .git ]; then
  git init
  git remote add origin https://github.com/sjml/dotfiles.git
  git fetch
  git reset origin/master
  git submodule update --init --recursive
fi

# all the goodies\! (see ./Brewfile for list)
brew bundle

timerData "POST-BREW"

# Projects folder is where most code stuff lives; link this there, too,
#  because otherwise I'll forget where it is
mkdir -p ~/Projects
ln -s $DOTFILES_ROOT ~/Projects/dotfiles

# copying Inconsolata outside of Cask because I handle all other fonts on 
#  their own, but Inconsolata is my go-to for terminal/editor/etc. so want 
#  to make sure it's available since it's name-checked in a couple config 
#  files.
cp ./resources/Inconsolata/*.ttf ~/Library/Fonts/

# any vim bundles
vim +PluginInstall +qall

# python setup
easy_install --user pip
# (this path is set in the zsh configs, but this is bash)
local pyPath="$(python -m site --user-base)/bin"
PIP_REQUIRE_VIRTUALENV="" $pyPath/pip install --user -r python-packages.txt

timerData "POST-PYTHON"

# node setup
zsh -i -c 'nvm install node; \
           nvm use node; \
           npm install -g yarn typescript angular-cli live-server vorlon surge;'

timerData "POST-NODE"

# NLP data comes last because it can take a looooong time
python -m nltk.downloader all
python -m spacy.en.download all

timerData "DONE"

cd ~
echo "And that's it\! You're good to go. Press any key to close out."
read -n 1
exec $targetZShell
