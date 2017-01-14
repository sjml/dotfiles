#!/bin/bash

declare -a packages=()
declare -a casks=()
declare -a taps=()
declare -a mass=()

while read command; do
  if [[ ${#command} -eq 0 ]]; then
    continue
  elif [[ $command =~ ^[[:space:]]*# ]]; then
    continue
  elif [[ $command =~ ^[[:space:]]*tap[[:space:]]*\' ]]; then
    tap=$(echo $command | sed -E "s/tap[[:space:]]+'([^']*)'/\1/")
    taps+=($tap)
  elif [[ $command =~ ^[[:space:]]*brew[[:space:]]*\' ]]; then
    pkg=$(echo $command | sed -E "s/brew[[:space:]]+'([^']*)'/\1/")
    packages+=($pkg)
  elif [[ $command =~ ^[[:space:]]*cask[[:space:]]*\' ]]; then
    cask=$(echo $command | sed -E "s/cask[[:space:]]+'([^']*)'/\1/")
    casks+=($cask)
  elif [[ $command =~ ^[[:space:]]*mas[[:space:]]*\' ]]; then
    # echo $command
    appName=$(echo $command | sed -E "s/mas[[:space:]]+'([^']*)'.*/\1/")
    appId=$(echo $command | sed -E "s/.*id:[[:space:]]+([0-9]*)/\1/")
    mass+=($appId)
  fi
done <Brewfile


# I wanna tap everything
for tap in "${taps[@]}"; do
  /usr/local/bin/brew tap $tap
done

# refresh!
sudo -v

# get the casks first; this can be the time-consuming part where we
#  lose sudo if we aren't careful
mkdir -p ~/Library/Caches/Homebrew/Cask
for cask in "${casks[@]}"; do
  /usr/local/bin/brew cask fetch $cask
  sudo -v # TODO: move this to magical indefinite loop?
done

# now actually install
for cask in "${casks[@]}"; do
  /usr/local/bin/brew cask install $cask
  sudo -v # nothing should take longer than the timeout
done

# no more sudo needed!
sudo -k

# but we will need to bother the user once more... <sigh>
# just bouncing out to make sure we sign in with the correct ID here
mas signout
echo -n "AppleID username: "
read appleID
/usr/local/bin/mas signin $appleID

# finally, our beloved CLI things, which Simply Work™
for package in "${packages[@]}"; do
  /usr/local/bin/brew install $package
done
