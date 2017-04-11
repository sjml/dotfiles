#!/usr/bin/env bash

function timerData() {
  echo $1: $SECONDS >> provision_timing.txt
}

# set up input
exec </dev/tty >/dev/tty

# make sure we're in the right place...
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

date >> provision_timing.txt
timerData "START"

# copy dotfiles
echo "Linking dotfiles..."
./install_symlinks.sh

# ssh config
echo "Creating SSH configuration..."
mkdir -p ~/.ssh
cp resources/ssh_config.base ~/.ssh/config

# Ask for the administrator password
echo "Now we need sudo access to install homebrew, some GUI apps, and change the shell."
sudo -v

timerData "PRE-BREW"

# install homebrew
export HOMEBREW_NO_ANALYTICS=1
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install zsh real quick so we can chsh to it while we still have sudo
sudo -v
brew install zsh

# try to set zsh up as the shell
targetZShell="/usr/local/bin/zsh"
# targetZShell=$(grep /zsh$ /etc/shells | tail -1)
echo $targetZShell | sudo tee -a /etc/shells
sudo chsh -s $targetZShell $USER

# using a DIY replacement for `brew bundle` that handles permissions better
echo "Installing from the Brewfile..."
./utility/brewfile_diy.sh

# the diy script does this internally, but just so it's explicit out here, too
sudo -k

# clean up after homebrew
brew cleanup -s
brew cask cleanup
rm -rf $(brew --cache)

timerData "POST-BREW"

# done with sudo
sudo -k

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

# python setup
easy_install --quiet --user pip
# (this path is set in the zsh configs, but this is bash)
pyPath="$(python -m site --user-base)/bin"
$pyPath/pip install --user -r python-packages.txt

timerData "POST-PYTHON"

# node setup
zsh -i -c 'nvm install node; \
           nvm use node; \
           npm install -g live-server vorlon surge;'

timerData "POST-NODE"

# set up Terminal
osascript 2>/dev/null <<EOD
  tell application "Terminal"
    local allOpenedWindows
    local initialOpenedWindows
    local windowID

    set initialOpenedWindows to id of every window

    do shell script "open './SJML.terminal'"
    delay 1
    set default settings to settings set "SJML"

    delay 5
    set allOpenedWindows to id of every window
    repeat with windowID in allOpenedWindows
      if initialOpenedWindows does not contain windowID then
        close (every window whose id is windowID)
      else
        set current settings of tabs of (every window whose id is windowID) to settings set "SJML"
      end if
    end repeat
  end tell
EOD

# set up Dock
declare -a dockList=(\
  App\ Store\
  Slack\
  Tweetbot\
  Firefox\
  iTunes\
  Photos\
  Steam\
  Keynote\
  Affinity\ Designer\
  Pixelmator\
  Scrivener\
  Sublime\ Text\
  Visual\ Studio\ Code\
  Xcode\
  Unity/Unity\
  VMware\ Fusion\
  Utilities/Terminal\
  System\ Preferences\
)
dockutil --remove all --no-restart
for app in "${dockList[@]}"
do
  dockutil --add "/Applications/$app.app" --no-restart
done
dockutil --add "~/Downloads" --section others --view grid --display stack --no-restart
killall Dock

timerData "POST-DOCK"

# NLP data comes last because it can take a looooong time
python -m nltk.downloader all
python -m spacy.en.download all

timerData "DONE"

cd ~
echo "And that's it! You're good to go."
