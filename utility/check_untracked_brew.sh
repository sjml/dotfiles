#!/usr/bin/env bash

cd "$(dirname "$0")"
cd ..

echo "Formulae not in Brewfile:"
comm -23 \
  <(brew leaves | sort) \
  <(grep -E "^\s*brew ['\"]" ./install_lists/Brewfile | sed -E "s/.*brew ['\"]([^'\"]+)['\"].*/\1/" | sort)

echo
echo "Casks not in Brewfile:"
comm -23 \
  <(brew list --cask | sort) \
  <(grep -E "^\s*cask ['\"]" ./install_lists/Brewfile | sed -E "s/.*cask ['\"]([^'\"]+)['\"].*/\1/" | sort)
