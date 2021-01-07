## This should probably hook into fish_user_paths, but how that slots into the
##  ordering of the full path seemed a little mysterious and this is "ain't broke"
##  territory.

## Because of how path additions work, this file is in reverse order of importance

set --local -a myPath

## Various paths to add if certain things are installed
set -a addIfExists
# Poetry
set -p addIfExists $HOME/.poetry/bin
# Rust
set -p addIfExists $HOME/.cargo/bin
# itch.io
set -p addIfExists $HOME/Library/Application\ Support/itch/bin
# Postgres using the app
set -p addIfExists /Applications/Postgres.app/Contents/Versions/12/bin/
# pyenv installed outside Homebrew
set -p addIfExists $HOME/.pyenv/bin

for maybePath in $addIfExists
  if test -d $maybePath
    set -p myPath $maybePath
  end
end

# Go
if test -f /usr/local/bin/go
  set -x GOPATH "$HOME/go"
  set -p myPath "$GOPATH/bin"
end

## Installed stuff (mostly from Homebrew)
set -a myPath /usr/local/bin
set -a myPath /usr/local/sbin
set PATH $myPath $PATH
set -e myPath
set -a myPath

## Ruby, checking for rbenv first
if test -f /usr/local/bin/rbenv
  status --is-interactive; and source (/usr/local/bin/rbenv init --no-rehash -|psub)
  /usr/local/bin/rbenv rehash 2> /dev/null &
else if test -f $HOME/.rbenv/bin/rbenv
  status --is-interactive; and source ($HOME/.rbenv/bin/rbenv init --no-rehash -|psub)
  $HOME/.rbenv/bin/rbenv rehash 2> /dev/null &
else if type -q ruby
  # this causes problems on systems that have old Ruby versions,
  #   and honestly, if I'm forced to use the system Ruby I
  #   probably am not caring about having its gem binaries
  #   in my path.
  # set -p myPath (ruby -r rubygems -e 'puts Gem.user_dir')/bin
end

## Node.js, checking for nodenv first
if test -f /usr/local/bin/nodenv
  status --is-interactive; and source (/usr/local/bin/nodenv init --no-rehash -|psub)
  /usr/local/bin/nodenv rehash 2> /dev/null &
else if test -f $HOME/.nodenv/bin/nodenv
  status --is-interactive; and source ($HOME/.nodenv/bin/nodenv init --no-rehash -|psub)
  $HOME/.nodenv/bin/nodenv rehash 2> /dev/null &
else if type -q npm
  set -p myPath (npm bin -g)
end


##TODO: this could be smarter about how pyenv and conda potentially coexist

## Check for conda first
if test -f /usr/local/bin/conda
  status --is-interactive; and source (/usr/local/bin/conda shell.fish hook|psub)
else if test -f $HOME/.pyenv/versions/miniconda3-latest/bin/conda
  status --is-interactive; and source ($HOME/.pyenv/versions/miniconda3-latest/bin/conda shell.fish hook|psub)
else if test -f $HOME/.pyenv/shims/conda
  status --is-interactive; and source (HOME/.pyenv/bin/conda shell.fish hook|psub)
end

## Python, checking for pyenv first
if test -f /usr/local/bin/pyenv
  status --is-interactive; and source (/usr/local/bin/pyenv init --no-rehash -|psub)
  /usr/local/bin/pyenv rehash 2> /dev/null &
else if test -f $HOME/.pyenv/bin/pyenv
  status --is-interactive; and source ($HOME/.pyenv/bin/pyenv init --no-rehash -|psub)
  $HOME/.pyenv/bin/pyenv rehash 2> /dev/null &
else if type -q python
  set -p myPath (python -m site --user-base)/bin
end

set PATH $myPath $PATH
set -e myPath
set -a myPath

## Any custom programs come first
set PATH $HOME/bin $PATH
