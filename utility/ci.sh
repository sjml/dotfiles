#!/usr/bin/env bash

cd "$(dirname "$0")"

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

