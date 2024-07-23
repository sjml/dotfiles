
alias ls="eza -F --icons --no-quotes"
alias ll="eza -lGh -F --icons --no-quotes --git"
alias llm="eza -lGh -F --icons --no-quotes --git --sort=modified --reverse"
alias la="eza -a -F --icons --no-quotes"
alias lla="eza -lGha -F --icons --no-quotes --git"

alias mkdir="mkdir -p"
# alias vim="nvim" # nvim starup is slow and I'm not really using the fanciness

# platform-specific aliases
switch (uname)
  case Darwin
    alias c="code ."
    alias o="open ."
    alias edot="code ~/.dotfiles"

    function oapp;open -a $argv;end
    complete -c oapp -a (basename -s .app /Applications{,/Utilities}/*.app|awk '{printf "\"%s\" ", $0 }')
end

