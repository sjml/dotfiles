# Run tmux attach, putting in a session name if provided

function tma
  if test -n $argv[1]
    tmux attach-session -t $argv[1]
  else
    tmux attach-session
  end
end
