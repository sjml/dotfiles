#!/usr/bin/env zsh

while read data; do
  local name=$data[(w)1]
  local url=$data[(w)2]

  git remote add $name $url
done <git_subtrees.txt
