local pyPath="$(python -m site --user-base)/bin"
local rbPath="$(ruby -rubygems -e 'puts Gem.user_dir')/bin"

export GOPATH="$HOME/go"
export PATH="$HOME/bin:$pyPath:$rbPath:$GOPATH/bin:/usr/local/bin:/usr/local/sbin:$PATH"
