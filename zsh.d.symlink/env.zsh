# unicode. always, unicode
export LANG=en_US.UTF-8

# emacs style line entry
bindkey -e

# Preferred editor for local and remote sessions
if [[ -z $SSH_CONNECTION ]]; then
  export EDITOR='subl'
else
  export EDITOR='vim'
fi

## python setup
# since we have our own plans for the prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

## ruby setup
#eval "$(rbenv init --no-rehash -)"
#(rbenv rehash &) 2> /dev/null

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

setopt extended_glob # more globing, all the globbing

setopt autocd # treat a path like a command to cd to it
setopt cdablevars # cd Projects --> cd ~/Projects

setopt correct # spelling correction for commands

setopt local_options # let functions have local toptions

