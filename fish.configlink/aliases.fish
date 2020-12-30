
if type -q gls
  alias ls="gls -F --color"
  alias ll="gls -lh --color"
  alias la="gls -FA --color"
  alias lla="gls -lhA --color"
else
  alias ls="ls -F --color"
  alias ll="ls -lh --color"
  alias la="ls -FA --color"
  alias lla="ls -lhA --color"
end

alias mkdir="mkdir -p"

# platform-specific aliases
switch (uname)
  case Darwin
    alias edot="code ~/.dotfiles"
end

