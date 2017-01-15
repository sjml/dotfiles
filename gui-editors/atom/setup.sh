#!/bin/bash


# make sure we're in the right place...
cd "$(dirname "$0")"
LOCAL_ROOT=$(pwd -P)

source ../../resources/utility_functions.sh

link_file "$LOCAL_ROOT/config-directory" "$HOME/.atom"
apm install --packages-file ./extensions.txt
