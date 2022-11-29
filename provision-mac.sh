#!/usr/bin/env bash

# Note: This script is designed to only be run once, on a completely
#       fresh Mac. If you've already done some setup, it might break
#       things. It's not idempotent -- not even a little.
#       If you're stumbling across this from elsewhere, don't blindly
#       run it without understanding what it does.

function timerData() {
  echo $1: $SECONDS >> provision_timing.txt
}

# die on errors
set -e

# set up input
exec </dev/tty >/dev/tty

# make sure we're in the right place...
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

date >> provision_timing.txt
timerData "START"

# copy dotfiles
./install_symlinks.sh

# ssh config
mkdir -p -m 700 ~/.ssh
cp resources/ssh_config.base ~/.ssh/config

# Ask for the administrator password
echo "Now we need sudo access to install {(Rosetta),Homebrew,some GUI apps} and change the shell."
sudo -v
still_need_sudo=1
while [ $still_need_sudo -ne 0 ]; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

if [[ $(uname -m) == 'arm64' ]]; then
  HBBASE=/opt/homebrew

  timerData "PRE-ROSETTA"
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  timerData "POST-ROSETTA"
else
  HBBASE=/usr/local

  timerData "PRE-BREW"
fi

HBBIN=$HBBASE/bin

# install homebrew
export HOMEBREW_NO_ANALYTICS=1
echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval $($HBBIN/brew shellenv)

# Turning off quarantine for casks; assuming I trust any apps that
#   made it into the Brewfile. *slightly* perilous, though.
HOMEBREW_CASK_OPTS="--no-quarantine" \
  $HBBIN/brew bundle install --no-lock --file=$DOTFILES_ROOT/install_lists/Brewfile

# set fish as user shell
targetShell="$HBBIN/fish"
echo $targetShell | sudo tee -a /etc/shells
sudo chsh -s $targetShell $USER

# homebrew doesn't link OpenJDK by default; do it while we still have sudo
sudo ln -sfn $HBBASE/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

# no more sudo needed!
still_need_sudo=0
sudo -k

# clean up after homebrew
$HBBIN/brew cleanup -s
rm -rf $($HBBIN/brew --cache)
export HOMEBREW_NO_AUTO_UPDATE=0

timerData "POST-BREW"

# make sure we're running in a local git working copy
#  (this hooks us in if we were set up from the bootstrap script)
if [[ ! -d .git ]]; then
  git init --initial-branch=main
  git remote add origin https://github.com/sjml/dotfiles.git
  git fetch
  git reset origin/main
  git branch --set-upstream-to=origin/main main
  git checkout .
fi
# swap to ssh; credentials can get added later
git remote set-url origin git@github.com:sjml/dotfiles.git

# Projects folder is where most code stuff lives; link this there, too,
#  because otherwise I'll forget where it is
if [[ ! -d ~/Projects/dotfiles ]]; then
  mkdir -p -m 700 ~/Projects
  ln -s $DOTFILES_ROOT ~/Projects/dotfiles
fi

# any vim bundles
vim +PluginInstall +qall

# make parallel chill
mkdir -p $HOME/.parallel
touch $HOME/.parallel/will-cite

# setup asdf
source $($HBBIN/brew --prefix asdf)/asdf.sh
shimPath="$HOME/.asdf/shims"
asdf plugin add python
asdf plugin add nodejs
asdf plugin add ruby

# copying version check from envup
env_remVer() {
    asdf list all $1 2>&1 \
        | grep -vE "\s*[a-zA-Z-]" \
        | sort -V \
        | grep "^\s*$2" \
        | tail -1 \
        | xargs
}

# python setup
py3version=$(env_remVer python 3)
LDFLAGS="-L$HBBASE/opt/zlib/lib -L$HBBASE/opt/sqlite/lib" \
  CPPFLAGS="-I$HBBASE/opt/zlib/include -I$HBBASE/opt/sqlite/include" \
  asdf install python $py3version

asdf global python $py3version
asdf reshim python
$shimPath/pip3 install --upgrade pip
$shimPath/pip3 install wheel
$shimPath/pip3 install -r install_lists/python3-dev-packages.txt
asdf reshim python

py2version=$(env_remVer python 2)
LDFLAGS="-L$HBBASE/opt/zlib/lib -L$HBBASE/opt/sqlite/lib" \
  CPPFLAGS="-I$HBBASE/opt/zlib/include -I$HBBASE/opt/sqlite/include" \
  asdf install python $py2version
asdf global python $py3version $py2version
asdf reshim python
$shimPath/pip2 install --upgrade pip
$shimPath/pip2 install wheel
$shimPath/pip2 install -r install_lists/python2-dev-packages.txt
asdf reshim python

# asdf install python miniconda3-latest
# asdf global python $py3version $py2version miniconda3-latest
# $shimPath/conda update --all -y

curl -sSL https://install.python-poetry.org/ | $shimPath/python -
$HOME/.local/bin/poetry config virtualenvs.in-project true

timerData "POST-PYTHON"

# ruby setup
rbversion=$(env_remVer ruby 3)
RUBY_CONFIGURE_OPTS="--with-openssl-dir=$($HBBIN/brew --prefix openssl@1.1)" \
  asdf install ruby $rbversion
asdf global ruby $rbversion
asdf reshim ruby

$shimPath/gem update --system
yes | $shimPath/gem update
yes | $shimPath/gem install bundler
$shimPath/gem cleanup

timerData "POST-RUBY"

# node setup
nodeversion=$(env_remVer nodejs "\d*[02468]\.")
NODEJS_CHECK_SIGNATURES="no" asdf install nodejs $nodeversion

asdf global nodejs $nodeversion
asdf reshim nodejs

ASDF_SKIP_RESHIM=1 $shimPath/npm install -g npm
ASDF_SKIP_RESHIM=1 $shimPath/npm install -g $(cat install_lists/node-packages.txt)
asdf reshim nodejs

timerData "POST-NODE"

# rust setup
curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path

timerData "POST-RUST"

# set up Terminal
cp ./resources/FiraMod/* $HOME/Library/Fonts/

osascript 2>/dev/null <<EOD
  tell application "Terminal"
    local allOpenedWindows
    local initialOpenedWindows
    local windowID

    set initialOpenedWindows to id of every window

    do shell script "open './resources/SJML.terminal'"
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

# let QuickLook stuff run without Gatekeeper complaining
xattr -cr ~/Library/QuickLook/*
qlmanage -r
qlmanage -r cache

# set up default associations
duti ~/.duti

# this will pop a permissions window, but no way around it
#   (this is a good thing to have security around, I will agree)
defaultbrowser firefox

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

# Only show icons for *external* hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Don't bug me about using new hard drives for Time Machine
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool "true"

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: turn off delay on proxy icon display (>= Big Sur)
defaults write com.apple.Finder NSToolbarTitleViewRolloverDelay -float 0

# Finder: show proxy icons all the time (>= Monterey)
defaults write com.apple.universalaccess showWindowTitlebarIcons -bool "true"

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
xattr -d com.apple.FinderInfo ~/Library
chflags nohidden ~/Library

# Expand save and print panels by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Turn off the "feature" where iCloud offloads files you haven't used in a while
defaults write com.apple.bird optimize-storage -int 0

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

# show the app switcher on every monitor
defaults write com.apple.dock appswitcher-all-displays -bool true

# Enable ⌃-Scroll to zoom screen
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Require password 5 minutes after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -float 300.0

# Set screen saver to Drift (blue) with visible clock
defaults -currentHost write com.apple.screensaver modulePath -string "/System/Library/Screen Savers/Drift.saver"
defaults -currentHost write com.apple.screensaver moduleName -string "Drift"
defaults -currentHost write com.apple.screensaver moduleDict -dict moduleName "Drift" path "/System/Library/Screen Savers/Drift.saver" type 0
defaults -currentHost write com.apple.ScreenSaver.Drift ColorScheme -string "blues"
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

# Don't show recent apps in the Dock
defaults write com.apple.dock show-recents -bool false

# Turn off Dock magnification
defaults write com.apple.dock magnification -bool false

# Allow slow-motion minimize effects when holding down shift (relic from old OS X :D)
defaults write com.apple.dock slow-motion-allowed -bool true

# Move windows with ⌘-⌃-click anywhere in them
defaults write -g NSWindowShouldDragOnGesture -bool true

# Hot corner, bottom-left: Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Don't rearrange spaces based on my random ⌘-tabbing around
defaults write com.apple.dock mru-spaces -bool false

# Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Do not automatically update apps
defaults write com.apple.commerce AutoUpdate -bool false

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# Set archive utility to not open a new window when it extracts things
defaults write com.apple.archiveutility dearchive-reveal-after -int 0

# set up Dock
dockutil --remove all --no-restart
declare -a dockList=(\
  /Applications/Firefox.app \
  /System/Applications/Mail.app \
  /System/Applications/Messages.app \
  /Applications/WhatsApp.app \
  /System/Applications/Calendar.app \
  /Applications/Overcast.app \
  /System/Applications/Music.app \
  /System/Applications/Photos.app \
  /Applications/Pixelmator\ Pro.app \
  /Applications/Affinity\ Designer\ 2.app \
  /Applications/Zotero.app \
  /Applications/Sublime\ Text.app \
  /Applications/Visual\ Studio\ Code.app \
  /Applications/Xcode.app \
  /System/Applications/Utilities/Terminal.app \
  /System/Applications/System\ Preferences.app \
)
for app in "${dockList[@]}"; do
  dockutil --add "$app" --no-restart
done
dockutil --add "~/Downloads" --section others --view grid --display stack --no-restart

# make iCloud Drive documents somewhat findable from the command line
ln -s $HOME/Library/Mobile\ Documents/com~apple~CloudDocs $HOME/iCloudDocs

# killall complains if there's no instances running, so ignore it
#   (and don't error)
killall cfprefsd 2> /dev/null || true
killall SystemUIServer 2> /dev/null || true
killall Finder 2> /dev/null || true
killall Dock 2> /dev/null || true
killall Mail 2> /dev/null || true

timerData "POST-GUI"



timerData "DONE"

cd ~
echo
echo
echo "And that's it! You're good to go, but restarting might be wise."
