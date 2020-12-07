
if [[ -r /etc/zprofile ]]; then
  source /etc/zprofile
elif [[ -r /etc/zsh/zprofile ]]; then
  source /etc/zsh/zprofile
else
  echo "Couldn't load a base zprofile..."
fi

local -a myPath=()

# Go
if type go > /dev/null 2>&1; then
  export GOPATH="$HOME/go"
  myPath+=("$GOPATH/bin")
fi

## Various paths to add if certain things are installed
local -a addIfExists=(
  # Poetry
  $HOME/.poetry/bin

  # Rust
  $HOME/.cargo/bin

  # itch.io
  $HOME/Library/Application\ Support/itch/bin

  # Postgres using the app
  /Applications/Postgres.app/Contents/Versions/12/bin/
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


myPath=()

## Ruby, checking for rbenv first
if [[ -a /usr/local/bin/rbenv ]]; then
  eval "$(/usr/local/bin/rbenv init --no-rehash -)"
  (/usr/local/bin/rbenv rehash &) 2> /dev/null
elif [[ -a $HOME/.rbenv/bin/rbenv ]]; then
  eval "$($HOME/.rbenv/bin/rbenv init --no-rehash -)"
  ($HOME/.rbenv/bin/rbenv rehash &) 2> /dev/null
  myPath+=($HOME/.rbenv/bin)
elif type ruby > /dev/null 2>&1; then
  # this causes problems on systems that have old Ruby's, and
  #   honestly, if I'm forced to use the system Ruby I probably
  #   am not caring about having its gem binaries in my path.
  # myPath+=("$(ruby -r rubygems -e 'puts Gem.user_dir')/bin")
fi

## Node.js, checking for nodenv first
if [[ -a /usr/local/bin/nodenv ]]; then
  eval "$(/usr/local/bin/nodenv init --no-rehash -)"
  (/usr/local/bin/nodenv rehash &) 2> /dev/null
elif [[ -a $HOME/.nodenv/bin/nodenv ]]; then
  eval "$($HOME/.nodenv/bin/nodenv init --no-rehash -)"
  ($HOME/.nodenv/bin/nodenv rehash &) 2> /dev/null
  myPath+=($HOME/.nodenv/bin)
elif type npm > /dev/null 2>&1; then
  myPath+=("$(npm bin -g)")
fi


##TODO: this could be smarter about how pyenv and conda potentially coexist

## Check for conda first
if [[ -a /usr/local/bin/conda ]]; then
  eval "$(/usr/local/bin/conda shell.zsh hook)"
elif [[ -a $HOME/.pyenv/versions/miniconda3-latest/bin/conda ]]; then
  eval "$($HOME/.pyenv/versions/miniconda3-latest/bin/conda shell.zsh hook)"
elif [[ -a $HOME/.pyenv/bin/conda ]]; then
  eval "$($HOME/.pyenv/bin/conda shell.zsh hook)"
fi

## Python, checking for pyenv first
if [[ -a /usr/local/bin/pyenv ]]; then
  eval "$(/usr/local/bin/pyenv init --no-rehash -)"
  (/usr/local/bin/pyenv rehash &) 2> /dev/null
elif [[ -a $HOME/.pyenv/bin/pyenv ]]; then
  eval "$($HOME/.pyenv/bin/pyenv init --no-rehash -)"
  ($HOME/.pyenv/bin/pyenv rehash &) 2> /dev/null
  myPath+=($HOME/.pyenv/bin)
elif type python > /dev/null 2>&1; then
  myPath+=("$(python -m site --user-base)/bin")
fi

path=($myPath $path)


## Any custom programs come first
path=($HOME/bin $path)
