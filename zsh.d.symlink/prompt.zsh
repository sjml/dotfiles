# this prompt was made by shamelessly stealing the parts
#  I liked from liquidprompt https://github.com/nojhan/liquidprompt/

zmodload zsh/datetime
zmodload zsh/mathfunc

autoload colors
colors

ZLE_RPROMPT_INDENT=0
setopt prompt_subst
local -i retCode # return code from previous command


function _sjml_escape() {
  local arg="${1//\\/\\\\}"
  echo $arg
}

# not the most obvious place for this
#  function, but its need came from
#  seeing the prompt, so here it is.
function _sjml_kill_venv() {
  if [[ -n $VIRTUAL_ENV ]]; then
    deactivate
  fi
}
add-zsh-hook zshexit _sjml_kill_venv

# to save us invoking hg every time we build a prompt
function _sjml_upwards_find() {
  local dir
  dir=$PWD
  while [[ -n $dir ]]; do
    [[ -d $dir/$1 ]] && return 0
    dir=${dir%/*}
  done
  return 1
}

# TODO: colorize output
function _sjml_git_data() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
  local branch
  if branch=$(git symbolic-ref -q HEAD) then
    branch=$(_sjml_escape "${branch#refs/heads/}")
  else
    branch=$(git rev-parse --short -q HEAD)
  fi

  local untracked
  untracked=$(git status --porcelain 2>/dev/null)
  if [[ $untracked =~ '^\?\?' ]]; then
   # echo "untracked changes"
  else
   # echo "we cool"
  fi

  local remote
  remote=$(git config --get branch.${branch}.remote 2>/dev/null)
  local has_commit=""
  local commit_ahead
  local commit_behind
  if [[ -n $remote ]]; then
    local remote_branch
    remote_branch=$(git config --get branch.${branch}.merge)
    if [[ -n $remote_branch ]]; then
      remote_branch=${remote_branch/refs\/heads/refs\/remotes\/$remote}
      commit_ahead=$(git rev-list --count $remote_branch..HEAD 2>/dev/null)
      commit_behind=$(git rev-list --count HEAD..$remote_branch 2>/dev/null)
      if [[ $commit_ahead -ne "0" && $commit_behind -ne "0" ]]; then
        has_commit="+$commit_ahead/-$commit_behind"
      elif [[ $commit_ahead -ne "0" ]]; then
        has_commit="+$commit_ahead"
      elif [[ $commit_behind -ne "0" ]]; then
         has_commit="-$commit_behind"
      fi
    fi
  fi

  local unstaged
  local shortstat
  shortstat=$(git diff --shortstat HEAD 2>/dev/null)
  if [[ -n $shortstat ]]; then
    unstaged=true
  fi

  local output="± $branch"
  if [[ $unstaged || -n $untracked ]]; then
    output="%F{magenta}$output*%f"
  elif [[ -n $has_commit  ]]; then
    output="$output ($has_commit)"
  fi

  echo $output
}

# TODO: colorize output
function _sjml_hg_data() {
  _sjml_upwards_find .hg || return
  local branch
  branch=$(hg branch 2>/dev/null)

  local untracked
  untracked=$(hg status -u 2>/dev/null)
  if [[ $untracked =~ '^\?' ]]; then
    #echo "untracked changes"
  else
    #echo "we cool"
  fi

  local -i commits
  commits=$(hg log -q -r "draft()" 2>/dev/null | wc -l)

  if [[ -n $(hg status --quiet -n) ]]; then
    local has_lines
    has_lines=$(hg diff --stat 2>/dev/null | sed -n '$ s!^.*, \([0-9]*\) .*, \([0-9]*\).*$!+\1/-\2!p')
  fi

  local output="☿ $branch"
  if [[ -n $untracked ]]; then
    output="$output*"
  elif [[ -n $has_lines ]]; then
    output="$output ($has_lines)"
  fi

  echo $output
}

# TODO: colorize and unicode-ize output
function _sjml_tmux_data() {
  if [[ $TERM == "screen" ]]; then
    return
  fi
  local icon="[]" #"▢"
  local count=$(tmux list-sessions 2>/dev/null| grep -cv 'attached')
  if [[ count -ne 0 ]]; then
    # TODO: probably some clever way to avoid the (s)
    echo "$icon $count detached tmux session(s)"
  fi
}

# TODO: colorize output
function _sjml_errcode_data () {
  if (( $retCode != 0 )) then
    echo "Error code: $retCode"
  fi
}

local -F _sjml_command_start_time
local -F _sjml_command_end_time
local -F _sjml_command_dt
function _sjml_start_timer() {
  # a little hacky, but keeps from printing execution
  #  time after exiting tmux shells or vim. only works
  #  if command started with "tmux" or "vim" which I'm
  #  ok with, since it does the check post-alias
  #  expansion)
  if [[ $2 =~ '^tmux' || $2 =~ '^vim' ]]; then
    return
  fi
  _sjml_command_start_time=$EPOCHREALTIME
}
function _sjml_end_timer() {
  if (( _sjml_command_start_time > 0.0 )) then
    _sjml_command_end_time=$EPOCHREALTIME
    (( _sjml_command_dt = _sjml_command_end_time - _sjml_command_start_time ))
    _sjml_command_start_time=-1.0
  fi
}

add-zsh-hook preexec _sjml_start_timer

# TODO: colorize output
function _sjml_runtime_data () {
  if (( _sjml_command_dt > 3.0 )) then
    echo -n "Long execution: "
    (( dt >= 86400 )) && echo -n "$((int(_sjml_command_dt / 86400)))d"
    (( dt >= 3600 )) && echo -n "$((int(_sjml_command_dt % 86400 / 3600)))h"
    (( dt >= 60 )) && echo -n "$((int(_sjml_command_dt % 3600 / 60)))m"
    printf "%.2fs" $((fmod($_sjml_command_dt, 60.0)))
  fi
}

local topLine=""
local -a alerts
local alertString=""

local normColor="cyan"
local rootColor="red"
local outlineColor=$normColor
local topLt="╭"
local botLt="╰"
local topRt="╮"
local botRt="╯"
local sep="─"

# get visible length of string
#  (won't work if string contains
#  newline)
function _gvl() {
  local stripped=$(echo $1 | tr -d '[:cntrl:]' | sed -E 's/\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g')
  echo $#stripped
}

function _sjml_buildPromptVars() {
  retCode=$?
  _sjml_end_timer

  alerts=()
  alertString=""

  if [[ $UID == 0 || $EUID == 0 ]]; then
    outlineColor=$rootColor
  else
    outlineColor=$normColor
  fi

  # this solution to measuring out the top line doesn't scale as I add more
  #  things like the virtualenv indicator, but since I don't have ambitions
  #  of replacing liquidprompt's flexibility, I'm ok with it. (apologies to
  #  the future version of myself who will have to rewrite this to scale.)
  local scaffold="$topLt$sep()()$sep$topRt"
  if [[ -n $VIRTUAL_ENV ]]; then
    scaffold="$topLt$sep()[🐍]()$sep$topRt"
  fi
  local prettyPath=$(rtab)
  local hostName=${(%):-%m}
  local userColor="$fg[green]"
  if [[ $UID == 0 || $EUID == 0 ]]; then
    userColor="$fg[black]$bg[red]"
  fi
  local userData="$userColor$USER$reset_color@$fg[blue]$hostName$reset_color"

  if (( $#scaffold + $#prettyPath + $(_gvl $userData) > $COLUMNS )) then
    userData="$userColor@$reset_color$fg[blue]$hostName$reset_color"
  fi
  if (( $#scaffold + $#prettyPath + $(_gvl $userData) > $COLUMNS )) then
    userData="$userColor@$reset_color"
  fi
  if (( $#scaffold + $#prettyPath + $(_gvl $userData) > $COLUMNS )) then
    local diff=$(( ($#scaffold + $#prettyPath + $(_gvl $userData)) - $COLUMNS ))
    prettyPath="…$prettyPath[$diff-1,-1]"
  fi

  ## this was fun to make, but silly; seriously, a while loop whose exiting
  ##  depends on my having properly made a regex?! in the PROMPT?!
  #while (( $#scaffold + $#prettyPath + $#userData > $COLUMNS )) do
  #  if [[ $prettyPath = "…" ]]; then
  #    break
  #  fi
  #  prettyPath=$(echo $prettyPath | sed -E 's/^…?\/?[^\/]*/…/')
  #done

  local ltData="$fg[$outlineColor]$topLt$sep$reset_color($prettyPath)"
  if [[ -n $VIRTUAL_ENV ]]; then
    local venv="[$fg[green]🐍$reset_color]"
    ltData=$ltData$venv
  fi
  local rtData="($userData)$fg[$outlineColor]$sep$topRt$reset_color"

  local ltDataSize=$(_gvl $ltData)
  local rtDataSize=$(_gvl $rtData)

  local paddingSize=$(( COLUMNS - ltDataSize - rtDataSize ))
  local paddingString=%F{$outlineColor}$(printf "$sep%.0s" {1..$paddingSize})$reset_color
  topLine=$ltData$paddingString$rtData

  alerts+=$(_sjml_tmux_data)
  alerts+=$(_sjml_errcode_data)
  alerts+=$(_sjml_runtime_data)

  local i
  for (( i=1; i <= $#alerts; i++ )) do
    if [[ -n $alerts[i] ]]; then
      alertString="$alertString%F{$outlineColor}│$reset_color ${(r:$(( COLUMNS - 3 )):: :)alerts[i]}%F{$outlineColor}|$reset_color
"
    fi
  done

  local vcsData
  vcsData=$(_sjml_git_data)
  if [[ -z $vcsData ]]; then
    vcsData=$(_sjml_hg_data)
  fi
  if [[ -n $vcsData ]]; then
    RPROMPT=$vcsData
  else
    RPROMPT=$(date "+%d-%b-%Y %H:%M")
  fi
  RPROMPT=$RPROMPT%F{$outlineColor}$botRt%f
}


local newline=$'\n'
PROMPT='$topLine${newline}$alertString%F{$outlineColor}$botLt$sep%f %#> '


add-zsh-hook precmd _sjml_buildPromptVars
