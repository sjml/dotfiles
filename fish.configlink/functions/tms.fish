# Create a named tmux session

function tms
  if test -n $argv[1]
    tmux new-session -s $argv[1]
  else
    tmux
  end
end
