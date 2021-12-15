#!/usr/bin/env bash


# make sure we're in the right place...
cd "$(dirname "$0")"
LOCAL_ROOT=$(pwd -P)

source ../../utility/utility_functions.sh
overwrite_all=false backup_all=false skip_all=false

if [[ $OSTYPE == darwin* ]]; then
  settingsBase="$HOME/Library/Application Support"
else
  settingsBase="$HOME/.config"
fi
settingsDir="$settingsBase/Code/User"
mkdir -p "$settingsDir"

for src in $(find -H "$LOCAL_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
do
  dst="$settingsDir/$(basename "${src%.*}")"
  link_file "$src" "$dst"
done

while read extension; do
  code --install-extension $extension
done <extensions.txt


