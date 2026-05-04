#!/bin/bash

cd "$(dirname "$0")"

code --list-extensions > vs-code/extensions.txt


if [[ $OSTYPE == darwin* ]]; then
  zedConfig="$HOME/Library/Application Support/Zed"
else
  zedConfig="$XDG_DATA_HOME/zed"
fi

jq '
  .extensions
  | to_entries
  | map({ (.key): .value.manifest.version })
  | add
' "$zedConfig/extensions/index.json" > zed/extensions.json
