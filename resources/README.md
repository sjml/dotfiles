This directory contains binary resources that I take with me everywhere.

## pandas
I've been using this image as my user icon since college. No reason to change
it yet. This is effectively as much a part of my dotfiles as my `$EDITOR`
definition.

## ssh_config.base
The file that gets appended to the end of my `~/.ssh/config` after a new key is
added to it, so that servers without a corresponding key just ask for a password.

## MLA Template
Overall I like [MLA style format](https://style.mla.org/mla-format/), but they say
the bibliography should also be double-spaced, which I think is just indulgent. So
the `MLA_9_Tight_Bibliography.csl` file is a [Citation Style Language](https://citationstyles.org/)
specification, forked from the [official Zotero one](http://www.zotero.org/styles/modern-language-association), 
with a less expansive bibliography style.

## Fira Mod
[Fira Code](https://github.com/tonsky/FiraCode) is nice, but I'm not a fan of programming
ligatures. Most applications let you turn them off, but macOS's Terminal.app, inexplicably,
does not. So this is a version of the font with the all contextual alternate characters
removed. It's generated from [a minimal fork of the original repo](https://github.com/sjml/FiraCode). (I could have also just changed to a different terminal emulator, but one change 
at a time.) 

There's also a [Nerd Font](https://www.nerdfonts.com/) patched version of Fira Mod here,
for people who like that sort of thing (still no ligatures).

(I am also aware of the ligature-less nature of [the original Fira Mono](http://mozilla.github.io/Fira/), 
but want to retain the otherwise-nice box-drawing characters and other things from Fira Code.)

## Terminal.app Profile
`SJML.terminal` sets up the macOS Terminal.app to my liking, and uses Fira Mode from 
this directory.

## Office Templates
Templates for MS Office. Set the location in Word's Preferences -> File Locations -> User 
Templates.

## Xcode Templates
Templates for Xcode. `ln -s ~/.dotfiles/resources/Xcode\ Templates ~/Library/Developer/Xcode/Templates/Custom`
