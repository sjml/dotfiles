
local -a myPath=()
myPath+=($HOME/bin)

if [[ -a $HOME/.pyenv/bin/pyenv ]]; then
  myPath+=($HOME/.pyenv/bin)
  eval "$($HOME/.pyenv/bin/pyenv init -)"
  eval "$($HOME/.pyenv/bin/pyenv virtualenv-init -)"
elif type python > /dev/null; then
  myPath+=("$(python -m site --user-base)/bin")
fi

if type ruby > /dev/null; then
  myPath+=("$(ruby -rubygems -e 'puts Gem.user_dir')/bin")
fi

if type go > /dev/null; then
  export GOPATH="$HOME/go"
  myPath+=("$GOPATH/bin")
fi

if [[ -a $HOME/.cargo/bin ]]; then
  myPath+=("$HOME/.cargo/bin")
fi

if [[ -d $HOME/Library/Application\ Support/itch/bin ]]; then
  myPath+=($HOME/Library/Application\ Support/itch/bin)
fi

myPath+=(/usr/local/bin)
myPath+=(/usr/local/sbin)

path=($myPath $path)
