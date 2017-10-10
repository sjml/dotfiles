
local -a myPath=()
myPath+=($HOME/bin)

if type python > /dev/null; then
  myPath+=("$(python -m site --user-base)/bin")
fi
if type ruby > /dev/null; then
  myPath+=("$(ruby -rubygems -e 'puts Gem.user_dir')/bin")
fi
if type go > /dev/null; then
  export GOPATH="$HOME/go"
  myPath+=("$GOPATH/bin")
fi
if [[ -d $HOME/Library/Application\ Support/itch/bin ]]; then
  myPath+=($HOME/Library/Application\ Support/itch/bin)
fi

myPath+=(/usr/local/bin)
myPath+=(/usr/local/sbin)

path=($myPath $path)
