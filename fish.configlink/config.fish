set --local FISHDIR ~/.config/fish

source $FISHDIR/env.fish

## put any machine-specific environment variables in .local.fish
##   (NB that file is not in source control)
if test -e "$HOME/.local.fish";
  source $HOME/.local.fish
end

## load up aliases
source $FISHDIR/aliases.fish

## if we start a tmux session from a virtualenved environment
if test -n "$VIRTUAL_ENV"
  source "$VIRTUAL_ENV/bin/activate.fish"
end

## settings for the git status prompt
set __fish_git_prompt_show_informative_status true
set __fish_git_prompt_showcolorhints true
set __fish_git_prompt_char_dirtystate '*'
set __fish_git_prompt_color_cleanstate 777777
set __fish_git_prompt_showuntrackedfiles true
set __fish_git_prompt_showstashstate true

## turn off greeting
set fish_greeting
