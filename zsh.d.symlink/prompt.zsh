# this prompt was made by shamelessly stealing the parts
#  I liked from liquidprompt https://github.com/nojhan/liquidprompt/

zmodload zsh/datetime

autoload colors
colors

ZLE_RPROMPT_INDENT=0
setopt prompt_subst
local -i retCode # return code from previous command


# TODO: color all this

function _sjml_escape() {
  local arg="${1//\\/\\\\}"
  echo $arg
}

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
    output="$output*"
  elif [[ -n $has_commit  ]]; then
    output="$output ($has_commit)"
  fi 

  echo $output
}

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

function _sjml_errcode_data () {
  if (( $retCode != 0 )) then
    echo "Error code: $retCode"
  fi
}

#local _sjml_command_start_time
#local _sjml_command_end_time
function _sjml_start_timer() {
  _sjml_command_start_time=$EPOCHREALTIME
}
function _sjml_end_timer() {
  _sjml_command_end_time=$EPOCHREALTIME
}

add-zsh-hook preexec _sjml_start_timer

function _sjml_runtime_data () {
  local dt
  (( dt = _sjml_command_end_time - _sjml_command_start_time ))
  if (( $dt > 3.0 )) then
    echo "Execution took $(printf '%.4f' dt) seconds."
  fi
}

local topLine=""
local -a alerts
local alertString=""

local topLt="╭"
local botLt="╰"
local topRt="╮"
local botRt="╯"
local sep="─"

function _sjml_buildPromptVars() {
  retCode=$?
  _sjml_end_timer

  alerts=()
  alertString=""

  local topLtDataF="$topLt$sep($(rtab))"
  local topRtDataF="(%n@%m)$sep$topRt"
  
  local ltData=${(%):-$topLtDataF}
  local rtData=${(%):-$topRtDataF}
  local ltDataSize=${#ltData}
  local rtDataSize=${#rtData}
  
  local paddingSize=$(( COLUMNS - rtDataSize )) #  ltDataSize - rtDataSize + colCorrect))
  eval "topLine=\${(r:$paddingSize::${sep}:)ltData}$rtData"
 
  alerts+=$(_sjml_tmux_data)
  alerts+=$(_sjml_errcode_data)
  alerts+=$(_sjml_runtime_data)

  local i
  for (( i=1; i <= $#alerts; i++ )) do
    if [[ -n $alerts[i] ]]; then
      alertString="$alertString│ ${(r:$(( COLUMNS - 3 )):: :)alerts[i]}|"
    fi
  done

  local vcsData
  vcsData=$(_sjml_git_data)
  if [[ -z $vcsData ]]; then
    vcsData=$(_sjml_hg_data)
  fi
  if [[ -n $vcsData ]]; then
    RPROMPT=$vcsData$botRt
  else
    RPROMPT=$botRt
  fi
}


PROMPT='$topLine$alertString$botLt$sep %%> '


add-zsh-hook precmd _sjml_buildPromptVars

