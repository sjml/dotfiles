#!/usr/bin/env bash


# make sure we're in the right place...
cd "$(dirname "$0")"
LOCAL_ROOT=$(pwd -P)

source ../../utility/utility_functions.sh
overwrite_all=false backup_all=false skip_all=false

settingsDir="$HOME/.config/zed"
mkdir -p "$settingsDir"

for src in $(find -H "$LOCAL_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
do
  dst="$settingsDir/$(basename "${src%.*}")"
  link_file "$src" "$dst"
done

# no way at the moment to install extensions from command line...
