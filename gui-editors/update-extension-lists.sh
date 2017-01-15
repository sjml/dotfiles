#!/bin/bash

cd "$(dirname "$0")"

code --list-extensions > vs-code/extensions.txt
# apm list --installed --bare > atom/extensions.txt
