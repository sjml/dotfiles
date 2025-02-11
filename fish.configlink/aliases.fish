
alias ls="eza -F --icons --no-quotes"
alias ll="eza -lh -F --icons --no-quotes --git"
alias llm="eza -lh -F --icons --no-quotes --git --sort=modified --reverse"
alias la="eza -a -F --icons --no-quotes"
alias lla="eza -lha -F --icons --no-quotes --git"

alias mkdir="mkdir -p"
# alias vim="nvim" # nvim starup is slow and I'm not really using the fanciness

alias ghwatch='gh run watch --exit-status $(gh run list -L 1 --json databaseId | jq ".[].databaseId")'


# platform-specific aliases
switch (uname)
  case Darwin
    function c;if test (count $argv) -eq 0;code .;else;code $argv;end;end
    function o;if test (count $argv) -eq 0;open .;else;open $argv;end;end
    alias edot="code ~/.dotfiles"

    function oapp;open -a $argv;end
    complete -c oapp -a (basename -s .app /Applications{,/Utilities}/*.app|awk '{printf "\"%s\" ", $0 }')

    alias clear="printf '\33c\e[3J'"

		alias python=python3
end

