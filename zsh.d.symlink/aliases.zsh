alias reload!='. ~/.zshrc'

if $(gls &>/dev/null); then
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

# Mac-specific aliases
if [[ $OSTYPE == darwin* ]]; then
  alias edot="code ~/.dotfiles"
fi

