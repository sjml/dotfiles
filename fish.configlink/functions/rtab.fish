# Inspired by https://github.com/derf/zsh/blob/master/etc/functions/rtab

# Shortens a path so that each element shows just enough to disambiguate it.
# (^$HOME is replaced with ~ and the last element of the path is always fully expanded.)
#
# So /Users/shane/Documents/papers/final -> ~/Doc/p/final

function shorten_path -a full_directory replace_tilde expand_final
  set fullPath ""
  set result ""
  set tree (string split --no-empty '/' $full_directory)

  for dir in $tree;
    if test $expand_final -eq 1; and test (count $tree) -eq 1;
      set result $result/$dir
      set fullPath $fullPath/$dir
      set tree $tree[2..-1]
      break
    end

    # build up the string for the directory until there
    #   is only one possible completion
    set part ""
    for c in (string split '' $dir);
      set part $part$c

      set -e options
      for p in $fullPath/$part*;
        set -a options $p
      end
      if test (count $options) -eq 1;
        break
      end
    end

    set result $result/$part
    set fullPath $fullPath/$dir
    set tree $tree[2..-1]
  end

  # if we did this replacement earlier, fish would run into problems trying to
  #   do the glob completion above
  if test $replace_tilde -eq 1; and string match -r "^$HOME" $fullPath > /dev/null;
    set short_home (shorten_path $HOME 0 0)
    set result (string replace $short_home "~" $result)
  end

  echo $result
end

function rtab
  if test $PWD = $HOME
    shorten_path $PWD 1 0
  else
    shorten_path $PWD 1 1
  end
end
