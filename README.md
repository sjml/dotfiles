My dotfiles, to get a computer running the way I like it. Customized zsh prompt
and all. :)

To get the whole repo: 
```shell-script
git clone --recursive https://github.com/sjml/dotfiles ~/.dotfiles
```

To bootstrap onto a fresh computer (that may not have git, like Macs out of the box): 
```shell-script
curl -fsSL https://raw.githubusercontent.com/sjml/dotfiles/master/bootstrap.sh | bash
```

Running `provision-mac.sh` on a clean user account will:
  * Attempt to change the default shell to zsh
  * Take everything in this directory that ends with .symlink and make a
    symbolic link to it in the home directory, minus the `.symlink` and
    prepended with a `.`
  * Install [homebrew](http://brew.sh)
  * Make a `~/Projects` directory and symlink the dotfiles there
  * Add Inconsolata to user fonts
  * Install all the packages listed in the Brewfile
    * command line utilities, programming languages, devtools, etc.
  * Install all GUI applications listed in the Cask section of the Brewfile
    * Dropbox, 1Password, web browsers, text editors, gamedev tools,
      virtualization, Steam, VLC, various utilities, quicklook plugins, etc.
  * Attempt to install Mac App Store stuff from the mas section of the Brewfile
    * Xcode, devtools, Tweetbot, Pixelmator, Affinity Designer, iWork
  * TODO: Set preferences for Finder, Safari, and various OS X system things
  * Install a set of Vim bundles, managed by Vundle
  * Install pip
  * Install all packages listed in `python-packages.txt`
  * Install the zsh-compatible version of nvm
  * Use that nvm to install Node.js, yarn, and a few node utilities
  * Download data for the Python natural language processing libraries

The `provision-linux.sh` is much simpler because I don't have root on most Linux
machines I use, and tend to not have them quite as customized. All it does:
  * Attempt to change the default shell to zsh
  * Symlink the designated dotfiles
  * Throw Inconsolata into a user folder
  * Install the vim bundles
  * Install pip, but not the Python packages
  * Install zsh-nvm, Node.js, and yarn, but nothing else
