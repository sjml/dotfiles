My dotfiles, to get a Mac or Linux computer running the way I like it. 

## Installation
To get the whole repo: 
```shell-script
git clone --recursive https://github.com/sjml/dotfiles ~/.dotfiles
```

To bootstrap onto a fresh computer (that may not have git, like Macs out of the box): 
```shell-script
curl -fsSL https://raw.githubusercontent.com/sjml/dotfiles/master/bootstrap.sh | bash
```

## What it does
Running `provision-mac.sh` on a clean user account will:
  * Take everything in this directory that ends with .symlink and make a
    symbolic link to it in the home directory, minus the `.symlink` and
    prepended with a `.`
  * Install [homebrew](http://brew.sh)
  * Attempt to change the default shell to zsh
  * Make a `~/Projects` directory and symlink the dotfiles there
  * Install all the packages listed in the Brewfile
  * Install all GUI applications listed in the Cask section of the Brewfile
  * Install Inconsolata and Hack fonts
  * Attempt to install Mac App Store stuff from the mas section of the Brewfile
  * Install a set of vim bundles, managed by [Vundle](https://github.com/VundleVim/Vundle.vim)
  * Install pip
  * Install all packages listed in `python-packages.txt`
  * Install the zsh-compatible version of nvm
  * Use that nvm to install Node.js, yarn, and a few node utilities
  * Set up appearance of Terminal.app
  * Set up the Dock

The `provision-linux.sh` is much simpler because I don't have root on most Linux
machines I use, and tend to not have them quite as customized. All it does:
  * Attempt to change the default shell to zsh
  * Symlink the designated dotfiles
  * Install the vim bundles
  * Install pip, but not the Python packages
  * Install zsh-nvm, Node.js, and yarn, but nothing else

