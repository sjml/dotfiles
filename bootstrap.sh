#!/bin/bash

# scriptPath=.
scriptPath=$HOME
cd $scriptPath

curl -L https://api.github.com/repos/sjml/dotfiles/tarball > $scriptPath/dotfiles.tar.gz
pathName=$(tar -ztvf dotfiles.tar.gz | head -1 | awk 'match($0,/sjml-dotfiles-([a-f0-9]*)\//) {print substr($0,RSTART,RLENGTH)}')
tar -xzf dotfiles.tar.gz
rm dotfiles.tar.gz
mv $scriptPath/$pathName $scriptPath/.dotfiles

cd $scriptPath/.dotfiles
./provision-mac.sh
