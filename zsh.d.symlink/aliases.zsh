alias reload!='. ~/.zshrc'

if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias ll="gls -lh --color"
  alias la="gls -FA --color"
  alias lla="gls -lhA --color"
else
  alias ls="ls -F --color"
  alias ll="ls -lh --color"
  alias la="ls -FA --color"
  alias lla="ls -lhA --color"
fi

alias mkdir="mkdir -p"

alias whence="which -a"

# Mac-specific aliases
if [[ $OSTYPE == darwin* ]]; then
  if type hub > /dev/null; then
    alias git="hub"
  fi
  alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
  alias ffdev='/Applications/Firefox.app/Contents/MacOS/firefox-bin -no-remote -P dev'
  alias chromedev='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'
fi

# goofiness :)
alias techlorem='hexdump -C /dev/urandom | head -$(($LINES - 2))'
