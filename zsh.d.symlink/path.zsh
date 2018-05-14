
local -a myPath=()

## Any custom programs come first
myPath+=($HOME/bin)

## Python, checking for pyenv first
if [[ -a /usr/local/bin/pyenv ]]; then
  eval "$(/usr/local/bin/pyenv init -)"
  eval "$(/usr/local/bin/pyenv virtualenv-init -)"
elif type python > /dev/null 2>&1; then
  myPath+=("$(python -m site --user-base)/bin")
fi

## Ruby
if type ruby > /dev/null 2>&1; then
  myPath+=("$(ruby -rubygems -e 'puts Gem.user_dir')/bin")
fi

## Go
if type go > /dev/null 2>&1; then
  export GOPATH="$HOME/go"
  myPath+=("$GOPATH/bin")
fi

## Various paths to add if certain things are installed
local -a addIfExists=(
  # Rust
  $HOME/.cargo/bin

  # itch.io
  # $HOME/Library/Application\ Support/itch/bin
)
for maybePath in "${addIfExists[@]}"; do
  if [[ -d $maybePath ]]; then
    myPath+=("$maybePath")
  fi
done

## Installed stuff (mostly from Homebrew)
# myPath+=(/usr/local/bin)
myPath+=(/usr/local/sbin)

path=($myPath $path)
