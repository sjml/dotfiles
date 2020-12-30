# unicode. always, unicode
set LANG en_US.UTF-8
set LANGUAGE $LANG
set LC_ALL $LANG

source $HOME/.config/fish/path.fish

# Preferred editor for local and remote sessions
set EDITOR "vim"
if test -f "$HOME/bin/sublime-wait"
  set VISUAL "$HOME/bin/sublime-wait"
end

## homebrew setup
# don't phone home
set HOMEBREW_NO_ANALYTICS 1
# relax
set HOMEBREW_AUTO_UPDATE_SECS "86400"
# don't build from scratch if a bottle download fails
set HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK 1

## python setup
# since we have our own plans for the prompt
set VIRTUAL_ENV_DISABLE_PROMPT 1
# pipenv's default behavior is silly
set PIPENV_VENV_IN_PROJECT 1

## purty colors
set LSCOLORS exfxcxdxbxegedabagacad
# set LSCOLORS GxFxCxDxBxegedabagaced
set CLICOLOR 1
