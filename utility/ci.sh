#!/usr/bin/env bash

cd "$(dirname "$0")"

brew update
./brewfile_audit.py
status=$?
if [ $status -ne 0 ]; then
  echo "Bad Brewfile audit; going deeper..."
  ./brewfile_audit.py --deep-deps
  exit 1
else
  exit $status
fi

