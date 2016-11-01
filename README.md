My dotfiles, to get a computer running the way I like it. Customized zsh prompt
and all. :)

To get it: `git clone --recursive https://github.com/sjml/dotfiles ~/.dotfiles`

Running `provision-mac.sh` on a clean user account will:
  * Install homebrew
  * Take everything in this directory that ends with .symlink and make a
    symbolic link to it in the home directory, minus the `.symlink` and
    prepended with a `.`
  * Add Inconsolata to user fonts
  * Install all the packages listed in the Brewfile
    * command line utilities, programming languages, devtools, etc.
  * Install all GUI applications listed in the Cask section of the Brewfile
    * Dropbox, 1Password, web browsers, text editors, gamedev tools,
      virtualization, Steam, VLC, various utilities, quicklook plugins, etc.
  * Attempt to install Mac App Store stuff from the mas section of the Brewfile
    * Xcode, devtools, Tweetbot, Pixelmator, Affinity Designer, iWork
  * TODO: Set preferences for Finder, Safari, and various OS X system things
  * Install pip
  * Install all packages listed in python-packages.txt
  * Install the zsh-compatible version of nvm
  * Use that nvm to install Node.js, yarn, and a few node packages
  * Download data for the Python natural language processing libraries
  * Attempt to change the default shell to zsh

The `provision-linux.sh` is much simpler because I don't have root on most Linux
machines I use, and tend to not have them quite as customized. All it does:
  * Symlink the designated dotfiles
  * Throw Inconsolata into a user folder
  * Install pip, but not the Python packages
  * Install zsh-nvm, Node.js, and yarn, but nothing else
  * Attempt to change the default shell to zsh
