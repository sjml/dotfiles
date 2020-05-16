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
still_need_sudo=1
while still_need_sudo; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

timerData "PRE-BREW"

# install homebrew
export HOMEBREW_NO_ANALYTICS=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# all the installations
echo "Installing from the Brewfile..."
brew bundle install --file=$DOTFILES_ROOT/install_lists/Brewfile

# try to set zsh up as the shell
targetZShell="/usr/local/bin/zsh"
# targetZShell=$(grep /zsh$ /etc/shells | tail -1)
echo $targetZShell | sudo tee -a /etc/shells
sudo chsh -s $targetZShell $USER

# no more sudo needed!
still_need_sudo=0
sudo -k

# clean up after homebrew
echo "Cleaning up Homebrew..."
brew cleanup -s
rm -rf $(brew --cache)
export HOMEBREW_NO_AUTO_UPDATE=0

timerData "POST-BREW"

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


# pull in environment check functions
source "$HOME/bin/envup"

# python setup
pyPath="$HOME/.pyenv/shims"
pyenv="/usr/local/bin/pyenv"

py3version=$(env_remVer pyenv 3)
$pyenv install $py3version
$pyenv global $py3version
$pyenv rehash
$pyPath/pip3 install --upgrade pip
$pyPath/pip3 install -r install_lists/python3-dev-packages.txt
$pyenv rehash

py2version=$(env_remVer pyenv 2)
$pyenv install $py2version
$pyenv global $py3version $py2version
$pyenv rehash
$pyPath/pip2 install --upgrade pip
$pyPath/pip2 install -r install_lists/python2-dev-packages.txt
$pyenv rehash

$pyenv install miniconda3-latest
$pyenv global $py3version $py2version miniconda3-latest
$pyPath/conda update --all -y
$pyPath/conda install anaconda-navigator -y

eval "$($pyenv init -)"

curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | $pyPath/python
$HOME/.poetry/bin/poetry config virtualenvs.in-project true

timerData "POST-PYTHON"

# ruby setup
rbPath="$HOME/.rbenv/shims"
rbenv="/usr/local/bin/rbenv"
rbversion=$(env_remVer rbenv)
$rbenv install $rbversion

$rbenv global $rbversion
eval "$($rbenv init -)"

$rbPath/gem update --system
yes | $rbPath/gem update
yes | $rbPath/gem install bundler
$rbPath/gem cleanup

timerData "POST-RUBY"

# node setup
nodePath="$HOME/.nodenv/shims"
nodenv="/usr/local/bin/nodenv"
git clone https://github.com/nodenv/node-build-update-defs.git "$(nodenv root)"/plugins/node-build-update-defs
$nodenv update-version-defs
nodeversion=$(env_remVer nodenv)
$nodenv install $nodeversion

$nodenv global $nodeversion
eval "$($nodenv init -)"

$nodePath/npm install -g npm
$nodePath/npm install -g $(cat install_lists/node-packages.txt)

timerData "POST-NODE"

# rust setup
curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path --profile=complete

timerData "POST-RUST"

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

# set up default associations
duti ~/.duti

# Turn off unneeded menu bar items
defaults -currentHost write dontAutoLoad -array-add "/System/Library/CoreServices/Menu Extras/Displays.menu"
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

# Try to re-enable subpixel anti-aliasing post-Mojave
defaults write -g CGFontRenderingFontSmoothingDisabled -bool false

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
  Messages\
  iTunes\
  Photos\
  Pixelmator\ Pro\
  Affinity\ Designer\
  Sublime\ Text\
  Visual\ Studio\ Code\
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



timerData "DONE"

cd ~
echo "And that's it! You're good to go, but restarting might be wise."
