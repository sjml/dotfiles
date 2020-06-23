My dotfiles, to get a computer running the way I like it. 

## Installation
To get the whole repo: 
```shell-script
git clone https://github.com/sjml/dotfiles ~/.dotfiles
```

To bootstrap onto a fresh *nix computer (that may not have git, like Macs out of the box): 
```shell-script
curl -fsSL https://raw.githubusercontent.com/sjml/dotfiles/main/bootstrap.sh | bash
```

Or on Windows, from an Administrator PowerShell:
```powershell
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sjml/dotfiles/main/bootstrap.ps1'))
```

## What it does
Running `provision-mac.sh` on a clean user account will:
  * Take everything in this directory that ends with `.symlink` and make a
    symbolic link to it in the home directory, minus the `.symlink` and
    prepended with a `.`
  * Symlink files in `osx-launchagents` to ~/Library/LaunchAgents
  * Install [homebrew](http://brew.sh) with analytics turned off
  * Attempt to change the default shell to zsh
  * Install all the packages and GUI apps listed in the `install_lists/Brewfile`
  * Install Inconsolata and Hack fonts
  * Attempt to install Mac App Store stuff from the mas section of the Brewfile
  * Make a `~/Projects` directory and symlink the dotfiles there
  * Install a set of vim bundles, managed by [Vundle](https://github.com/VundleVim/Vundle.vim)
  * Install latest versions of Python 2 and 3 (3 as default) via [pyenv](https://github.com/pyenv/pyenv)
  * Install all packages listed in `install_lists/python{2|3}-dev-packages.txt`
  * Install the latest version of Ruby via [rbenv](https://github.com/rbenv/rbenv)
  * Install the latest version of Node.js via [nodenv](https://github.com/nodenv/nodenv)
  * Install all Node-based programs listed in `install_lists/node-packages.txt`
  * Install the latest version of Rust via [rustup](https://www.rustup.rs/)
  * Set up appearance of Terminal.app
  * Various and sundry macOS GUI settings (Finder behaviors, Trackpad settings, etc.)
  * Set up the Dock

The `provision-linux.sh` is much simpler because I don't have root on most Linux
machines I use, and tend to not have them quite as customized. All it does:
  * Attempt to change the default shell to zsh
  * Symlink the designated dotfiles
  * Symlink this to ~/Projects/dotfiles
  * Install the vim bundles
  * Install pip, but not the Python packages

The Windows version (`provision-windows.ps1`) is pretty experimental, but it attempts to:
  * Install [Chocolatey](http://chocolatey.org/)
  * Install all the packages listed in `install_lists/chocolatey-packages.config`
  * Install all packages listed in `install_lists/python3-dev-packages.txt`
  * Install all Node-based programs listed in `install_lists/node-packages.txt`
  * Enable the Windows Subsystem for Linux
  * Set a number of sensible Windows options 
  * Remove installation cruft

## Custom ZSH prompt

My tweaked setup for ZSH includes a prompt that does some fun things. 

![Basic](http://shaneliesegang.com/prompt-shots/suggestions.png)

It's a double-tall prompt (controversial, but I like being able to easily skim for inputs). It shows your current working directory, username, machine name, and time. It does simple syntax coloring and suggestions based on previous inputs. 
***
![Suggestions](http://shaneliesegang.com/prompt-shots/brew-cleanup.png) 

This is particular handy for commands that are kinda wonky but you may execute periodically. 
***
![Path Shortening](http://shaneliesegang.com/prompt-shots/path-shortening.png)

It does clever shortening to get as much relevant information into the heads-up display as possible. Each path component is shortened as much as it can be without becoming ambiguous.
***
![Root Warning](http://shaneliesegang.com/prompt-shots/root-prompt.png)

It dramatically changes when you're working with root privileges so you're less likely to accidentally screw something up. 
***
![Virtual Environment](http://shaneliesegang.com/prompt-shots/virtualenv.png)

A cute little snake appears when you've activated a Python virtual environment. 
***
![Git Statuses](http://shaneliesegang.com/prompt-shots/git-statuses.png)

The indicator at the right changes when you're in a git repo, showing if there are uncommitted or unpushed changes. (Mercurial code is there but disabled because it's slow. 😫)
***
![Status Messages](http://shaneliesegang.com/prompt-shots/messages.png)

The prompt can also expand to give status messages about detached tmux sessions, long execution times, and error codes. 
***
