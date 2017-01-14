#!/bin/bash

# just yanking this from the install_symlinks script; should centralize it someplace

link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then
      local currentSrc="$(readlink "$dst")"
      if [ "$currentSrc" == "$src" ]; then
        skip=true;
      else
        echo "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi
    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      echo "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.bak"
      echo "moved $dst to ${dst}.bak"
    fi

    if [ "$skip" == "true" ]
    then
      echo "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    # echo "linked $1 to $2"
  fi
}

# make sure we're in the right place...
cd "$(dirname "$0")"
LOCAL_ROOT=$(pwd -P)

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


