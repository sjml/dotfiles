#!/bin/bash


# make sure we're in the right place...
cd "$(dirname "$0")"
LOCAL_ROOT=$(pwd -P)

source ../../resources/utility_functions.sh

if [[ $OSTYPE == darwin* ]]; then
  settingsBase="$HOME/Library/Application Support/Sublime Text 3"
else
  settingsBase="$HOME/.config/sublime-text-3"
fi
settingsDir="$settingsBase/Packages"
mkdir -p "$settingsDir"

link_file "$LOCAL_ROOT/user-directory" "$settingsDir/User"


