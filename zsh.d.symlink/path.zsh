local pyPath=""
if [[ $OSTYPE == darwin* ]]; then
  pyPath="$HOME/Library/Python/2.7/bin"
  export GOPATH="$HOME/Projects/go"
else
  # doesn't handle windows, but none of this stuff does :)
  pyPath="$HOME/.local/bin"
  export GOPATH="$HOME/.local/go"
fi

export PATH="$HOME/bin:$pyPath:$GOPATH/bin:/usr/local/bin:/usr/local/sbin:$PATH"
