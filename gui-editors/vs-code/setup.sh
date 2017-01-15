#!/bin/bash


# make sure we're in the right place...
cd "$(dirname "$0")"
LOCAL_ROOT=$(pwd -P)

source ../../resources/utility_functions.sh

settingsDir="$HOME/Library/Application Support/Code"
mkdir -p "$settingsDir/User"

install_symlinks () {
  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$LOCAL_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
  do
    dst="$settingsDir/User/$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}
install_symlinks

while read extension; do
  code --install-extension $extension
done <extensions.txt


