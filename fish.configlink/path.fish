## This should probably hook into fish_user_paths, but how that slots into the
##  ordering of the full path seemed a little mysterious and this is "ain't broke"
##  territory.

## Because of how path additions work, this file is in reverse order of importance

set --local -a myPath

## Various paths to add if certain things are installed
set -a addIfExists
# Poetry (and maybe other things?)
set -p addIfExists $HOME/.local/bin
# Rust
set -p addIfExists $HOME/.cargo/bin
# itch.io
set -p addIfExists $HOME/Library/Application\ Support/itch/bin
# Postgres using the app
set -p addIfExists /Applications/Postgres.app/Contents/Versions/12/bin/

for maybePath in $addIfExists
  if test -d $maybePath
    set -p myPath $maybePath
  end
end

# Go
if test -f /usr/local/bin/go; or test -f /opt/homebrew/bin/go;
  set -x GOPATH "$HOME/go"
  set -p myPath "$GOPATH/bin"
end

## Installed stuff (mostly from Homebrew)
set -a myPath /opt/homebrew/bin
set -a myPath /opt/homebrew/sbin
set -a myPath /usr/local/bin
set -a myPath /usr/local/sbin
set PATH $myPath $PATH
set -e myPath
set -a myPath

# set --local haveASDF 0
# set --local havePyenv 0
# if test -f /usr/local/opt/asdf/asdf.fish;
#   source /usr/local/opt/asdf/asdf.fish
#   set haveASDF 1
# else if test -f /opt/homebrew/opt/asdf/libexec/asdf.fish
#   set -x ASDF_DIR /opt/homebrew/opt/asdf/libexec
#   source /opt/homebrew/opt/asdf/libexec/asdf.fish
#   set haveASDF 1
# else if test -f $HOME/.asdf/asdf.fish
#   source $HOME/.asdf/asdf.fish
#   set haveASDF 1
# else if test -f $HOME/.pyenv/bin/pyenv
#   set PATH $HOME/.pyenv/bin $PATH
#   set havePyenv 1
# end

# if test $haveASDF -eq 1
#   for asdf_plugin in (asdf plugin list)
#     # fish can't really do backgrounding for this kind of thing :-/
#     bash -c "asdf reshim $asdf_plugin &"
#   end
# else if test $havePyenv -eq 1
#   status is-interactive; and pyenv init --path | source
#   pyenv init - | source
# end

## Any custom programs come first
set PATH $HOME/bin $HOME/local/bin $PATH
