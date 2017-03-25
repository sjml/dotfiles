#!/usr/bin/env zsh

SRC_DIR=$(cd "$(dirname "$0")"; pwd)
cd $SRC_DIR

while read data; do
  local name=$data[(w)1]
  local url=$data[(w)2]
  local prefix=$data[(w)3]

  local found=0
  while read -r rem; do
    if [[ $rem[(w)1] = $name ]]; then
      if [[ $rem[(w)2] = $url ]]; then
        found=1
        break
      fi
    fi
  done <<< $(git remote -v)
  if [[ $found -eq 0 ]]; then
    echo "Couldn't find $url in remote list."
    exit 1
  fi

  cd ..
  git subtree pull --prefix=$prefix --squash $name master
  cd $SRC_DIR
  
done <git_subtrees.txt

