#!/bin/zsh

if $(gls &>/dev/null) 
then
  alias ls="gls -F --color"
  alias ll="gls -lh --color"
  alias la="gls -FA --color"
  alias lla="gls -lhA --color"
fi

alias tma="tmux attach"

alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
alias ffdev='/Applications/Firefox.app/Contents/MacOS/firefox-bin -no-remote -P dev'

alias reload!='. ~/.zshrc'

