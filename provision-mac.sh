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
echo "Cleaning up Homebrew..."
brew cleanup -s --force
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
  git checkout .
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
# curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
# py2version=$(brew info python@2 | sed -n 's/^python@2: stable \([0-9.]*\).*/\1/p')
# py3version=$(brew info python   | sed -n 's/^python: stable \([0-9.]*\).*/\1/p')
# CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" $HOME/.pyenv/bin/pyenv install -v $py2version
# CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" $HOME/.pyenv/bin/pyenv install -v $py3version
py2base=2.7
py3base=3.6
git clone https://github.com/momo-lab/pyenv-install-latest.git "$(/usr/local/bin/pyenv root)"/plugins/pyenv-install-latest
/usr/local/bin/pyenv install-latest $py2base
/usr/local/bin/pyenv install-latest $py3base
/usr/local/bin/pyenv install-latest miniconda3
py2version=$(pyenv versions | grep $py2base | xargs)
py3version=$(pyenv versions | grep $py3base | xargs)
minicondaversion=$(pyenv versions | grep miniconda3 | xargs)
/usr/local/bin/pyenv global $py2version $py3version $minicondaversion

# (this path is set in the zsh configs, but we're in bash, still)
pyPath="$HOME/.pyenv/shims"
$pyPath/pip2 install --upgrade pip
$pyPath/pip3 install --upgrade pip
$pyPath/pip2 install -r install_lists/python-dev-packages.txt
$pyPath/conda install --yes --file install_lists/python-sci-packages.txt

timerData "POST-PYTHON"

# rust setup
curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
$HOME/.cargo/bin/rustup install nightly

timerData "POST-RUST"

# node setup
zsh -i -c 'nvm install node; \
           nvm use node; \
           npm install -g $(cat install_lists/node-packages.txt);'

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

# Turn off unneeded menu bar items
defaults -currentHost write dontAutoLoad -array-add "/System/Library/CoreServices/Menu Extras/Displays.menu"
defaults -currentHost write dontAutoLoad -array-add "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"
defaults -currentHost write dontAutoLoad -array-add "/System/Library/CoreServices/Menu Extras/Volume.menu"
defaults -currentHost write dontAutoLoad -array-add "/System/Library/CoreServices/Menu Extras/User.menu"

# Clock formatting: with seconds, 12 hr AM/PM, no flashing separators
defaults write com.apple.menuextra.clock DateFormat -string "h:mm:ss a"
defaults write com.apple.menuextra.clock FlashDateSeparators -bool false

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Text selection in QuickLook
defaults write com.apple.finder QLEnableTextSelection -bool true

# Don't open folders in tabs
defaults write com.apple.finder FinderSpawnTab -bool false

# Set ~ as the default location for new Finder windows
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Show icons for external hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library

# Expand save and print panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# disable tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 0

# enable two-fingered right-click
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1

# disable three-fingered tap for lookup
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 0

# enable three-finger swipe through pages
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 1

# enable four-finger swipe through fullscreen apps
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2

# enable four-finger-swipes for Mission Control and App Expose
defaults write com.apple.dock showMissionControlGestureEnabled -bool true
defaults write com.apple.dock showAppExposeGestureEnabled -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2

# enable four-finger spread to show desktop
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2
defaults write com.apple.dock showDesktopGestureEnabled -bool true

# disable Launchpad gesture
defaults write com.apple.dock showLaunchpadGestureEnabled -bool false

# Enable Control-Scroll to zoom screen
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Require password 5 minutes after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -float 300.0

# Set screen saver to Shell with visible clock
defaults -currentHost write com.apple.screensaver modulePath -string "/System/Library/Screen Savers/Shell.saver"
defaults -currentHost write com.apple.screensaver moduleName -string "Shell"
defaults -currentHost write com.apple.screensaver showClock -bool true

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Disable Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Set the icon size of Dock items to biggest
defaults write com.apple.dock tilesize -int 128

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Turn off Dock magnification
defaults write com.apple.dock magnification -bool false

# Allow slow-motion minimize effects when holding down shift (relic from old OS X :D)
defaults write com.apple.dock slow-motion-allowed -bool true

# Hot corner, bottom-left: Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Don't automatically update apps
defaults write com.apple.commerce AutoUpdate -bool false

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# set up Dock
dockutil --remove all --no-restart
declare -a dockList=(\
  App\ Store\
  Mail\
  Firefox\
  Tweetbot\
  Messages\
  iTunes\
  Photos\
  Steam\
  itch\
  Affinity\ Designer\
  Pixelmator\
  Sublime\ Text\
  Visual\ Studio\ Code\
  Unity/Unity\
  Xcode\
  Utilities/Terminal\
  System\ Preferences\
)
for app in "${dockList[@]}"; do
  dockutil --add "/Applications/$app.app" --no-restart
done
dockutil --add "~/Downloads" --section others --view grid --display stack --no-restart

killall cfprefsd
killall SystemUIServer
killall Finder
killall Dock
killall Mail

timerData "POST-GUI"

# NLP data comes last because it can take a looooong time
$pyPath/python -m nltk.downloader all
$pyPath/python -m spacy.en.download all

timerData "DONE"

cd ~
echo "And that's it! You're good to go, but restarting might be wise."
