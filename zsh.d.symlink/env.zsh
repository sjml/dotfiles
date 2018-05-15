# unicode. always, unicode
export LANG=en_US.UTF-8
export LANGUAGE=$LANG
export LC_ALL=$LANG

# vim style line entry
bindkey -v

# Preferred editor for local and remote sessions
export EDITOR="vim"
export VISUAL="$HOME/bin/sublime-wait"

## homebrew setup
# don't phone home
export HOMEBREW_NO_ANALYTICS=1

## python setup
# since we have our own plans for the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

# purty colors
export LSCOLORS=exfxcxdxbxegedabagacad
# export LSCOLORS=GxFxCxDxBxegedabagaced
export CLICOLOR=1

# remember...
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# config options
setopt no_beep # ssshhhhhh

setopt appendhistory # instead of overwriting it
setopt histignoredups # don't record identical commands
setopt extendedhistory # print timestamps in history file

setopt extended_glob # more globbing, all the globbing

setopt autocd # treat a path like a command to cd to it
setopt cdablevars # cd Projects --> cd ~/Projects

setopt correct # spelling correction for commands

setopt local_options # let functions have local options

