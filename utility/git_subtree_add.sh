#!/usr/bin/env zsh

if [[ $# -lt 2 ]]; then
  echo "Usage: git_subtree_add.sh [URL] [LOCAL_PATH]"
  exit 1
fi

name=""
if [[ ${1:0:14} = "git@github.com" ]]; then
  name=$(echo $1 | sed -n "s/git@github.com:.*\/\(.*\).git/\1/p")
elif [[ ${1:0:18} = "https://github.com" ]]; then
  name=$(echo $1 | sed -n "s/https:\/\/github.com\/.*\/\(.*\)/\1/p")
else
  echo "ERROR: Couldn't parse URL. Do this manually."
  exit 1
fi
name=$name:l

git subtree add --prefix=$2 --squash $1 master
echo "$name	$1	$2" >> git_subtrees.txt
