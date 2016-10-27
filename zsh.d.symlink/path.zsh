local pyPath=""
if [[ $OSTYPE == darwin* ]]; then
  pyPath="$HOME/Library/Python/2.7/bin"
else
  # doesn't handle windows, but none of this stuff does :)
  pyPath="$HOME/.local/bin"
fi

export PATH="./bin:/usr/local/bin:/usr/local/sbin:$HOME/bin:$pyPath:$PATH"
