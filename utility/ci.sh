#!/usr/bin/env bash

# turning this off for now until re-evaluating how bad homebrew's Python is
# if it's unlinked
exit 0

# real script starts here
cd "$(dirname "$0")"

echo "Setting homebrew taps..."
brew update
cat ../install_lists/Brewfile | sed -n "s/^tap[[:space:]]*'\([^']*\)'/\1/p" | xargs -n 1 brew tap
brew update

echo "Running Brewfile audit..."
./brewfile_audit.py
status=$?
if [ $status -ne 0 ]; then
  echo "Bad Brewfile audit; going deeper..."
  ./brewfile_audit.py --deep-deps
  exit 1
else
  exit $status
fi

