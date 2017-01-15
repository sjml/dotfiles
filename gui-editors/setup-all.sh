#!/bin/bash

cd "$(dirname "$0")"

for editor_directory in */; do
  $editor_directory/setup.sh
done
