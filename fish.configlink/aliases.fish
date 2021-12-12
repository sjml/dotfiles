
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
# alias vim="nvim" # nvim starup is slow and I'm not really using the fanciness

# platform-specific aliases
switch (uname)
  case Darwin
    alias c="code ."
    alias edot="code ~/.dotfiles"

    function o;open -a $argv;end
    complete -c o -a (basename -s .app /Applications{,/Utilities}/*.app|awk '{printf "\"%s\" ", $0 }')
end

