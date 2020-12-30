function rtab
  set dir $PWD

  # replace $HOME with ~
  set dir (string replace -r "^$HOME" \~ $dir)

  set fullPath ""
  set result ""
  set tree (string split '/' $dir)
  if test $tree[1] = "~"
    set tree $tree[2..-1]
    set result "~"
    set fullPath "~"
  end
  for dir in $tree;
    if test -z $dir
      continue
    end
    if test (count $tree) -eq 1;
      set result $result/$dir
      set tree $tree[2..-1]
      break
    end

    set part ""
    for c in (string split '' $dir);
      set part $part$c
      set options (string split ' ' (eval echo "$fullPath/$part*/"))

      if test (count $options) -eq 1;
        break
      end
    end
    set tree $tree[2..-1]
    set fullPath $fullPath/$dir
    set result $result/$part
  end

  echo $result
end
