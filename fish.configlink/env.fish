# unicode. always, unicode
set -x LANG en_US.UTF-8
set -x LANGUAGE $LANG
set -x LC_ALL $LANG

source $HOME/.config/fish/path.fish

# Preferred editor for local and remote sessions
set -x EDITOR "vim"
if test -f "$HOME/bin/sublime-wait"
  set -x VISUAL "$HOME/bin/sublime-wait"
end

## homebrew setup
# don't phone home
set -x HOMEBREW_NO_ANALYTICS 1
# relax
set -x HOMEBREW_AUTO_UPDATE_SECS "86400"
# don't build from scratch if a bottle download fails
set -x HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 1

## python setup
# since we have our own plans for the prompt
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
# pipenv's default behavior is silly
set -x PIPENV_VENV_IN_PROJECT 1

## purty colors
set -x LSCOLORS exfxcxdxbxegedabagacad
# set LSCOLORS GxFxCxDxBxegedabagaced
set -x CLICOLOR 1
