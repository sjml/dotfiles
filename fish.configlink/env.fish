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
# let it do its business
set -x HOMEBREW_NO_ENV_HINTS 1
# Cask otherwise adds their own quarantine flag that
#   can break things. Figure anything I'm installing
#   via cask is something I either trust or will be
#   removing the flag so I can run it anyway, so it's
#   kind of pointless.
set -x HOMEBREW_CASK_OPTS "--no-quarantine"

set -x DYLD_FALLBACK_LIBRARY_PATH /opt/homebrew/lib

## asdf shenanigans
# asdf-nodejs insists on checking signatures by default.
#   not a bad idea, but it's alone in trying to do this
#   and I'd rather it behave like other asdf plugins.
set -x NODEJS_CHECK_SIGNATURES "no"
# asdf-nodejs wants to reshim after any npm -g install,
#   which runs the postinstall hooks for all nested
#   dependences.
set -x ASDF_SKIP_RESHIM 1
## side-note: seems like the nodejs plugin for asdf is
##            bad? like, not well thought out at all?
##            look how its relevant environment vars
##            aren't even using the same prefix!
##            (and yes, these vars are specific to
##            asdf-nodejs, despite the naming.)
##            this is a real pity!


## python setup
# since we have our own plans for the prompt
set -x VIRTUAL_ENV_DISABLE_PROMPT 1
# pipenv's default behavior is silly
set -x PIPENV_VENV_IN_PROJECT 1

## devbox setup
# devbox thinks it's better than me
set -x devbox_no_prompt true

## purty colors
set -x LSCOLORS exfxcxdxbxegedabagacad
# set LSCOLORS GxFxCxDxBxegedabagaced
set -x CLICOLOR 1
