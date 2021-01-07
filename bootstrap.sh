 #!/bin/bash

scriptPath=$HOME
cd $scriptPath

if [[ -d $scriptPath/.dotfiles ]]; then
  echo "There's already a .dotfiles directory in $scriptPath. Aborting bootstrap."
  exit 1
fi

curl -L https://api.github.com/repos/sjml/dotfiles/tarball > $scriptPath/dotfiles.tar.gz
pathName=$(tar -ztvf dotfiles.tar.gz | head -1 | awk 'match($0,/sjml-dotfiles-([a-f0-9]*)/) {print substr($0,RSTART,RLENGTH)}')
tar -xzf dotfiles.tar.gz
rm $scriptPath/dotfiles.tar.gz
mv $scriptPath/$pathName $scriptPath/.dotfiles

cd $scriptPath/.dotfiles
if [[ $OSTYPE == darwin* ]]; then
  ./provision-mac.sh
else
  ./provision-linux.sh
fi

