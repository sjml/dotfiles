#!/usr/bin/env bash

# wrapper script for [Teller](https://github.com/sjml/Teller)
#   so it's easier to invoke from the command line

args=("$@")

if [[ "$1" == -* ]]; then
  caller="$HOME/Applications/tellers/Teller.app/Contents/MacOS/Teller"
else
  caller="$HOME/Applications/tellers/Teller-$1.app/Contents/MacOS/Teller"
  args=("${args[@]:1}")
fi

if ! test -f "$caller"; then
  echo "That teller ($caller) doesn't exist. :("
  exit 1
fi
if ! test -x "$caller"; then
  echo "That teller ($caller) is not executable. Weird!"
  exit 1
fi

"$caller" "${args[@]}"
