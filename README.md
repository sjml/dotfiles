My dotfiles, to get a computer running the way I like it. 

## Installation
To bootstrap onto a fresh *nix computer (that may not have git, like Macs out of the box): 
```shell-script
curl -fsSL https://raw.githubusercontent.com/sjml/dotfiles/main/bootstrap.sh | bash
```

Or on Windows, from an Administrator PowerShell:
```powershell
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/sjml/dotfiles/main/bootstrap.ps1'))
```

## What it does
Running `provision-mac.sh` on a fresh Mac will:
  * Take everything in this directory that ends with `.symlink` and make a
    symbolic link to it in the current user's home directory, minus the 
    `.symlink` and prepended with a `.`
    * Similarly, anything with `.configlink` gets linked into `.config`
      without a prepended `.`
    * `.homelink` gets the same treatment, but into `~`
  * Symlink files in `osx-launchagents` to `~/Library/LaunchAgents`
  * Install [homebrew](http://brew.sh) with analytics turned off
  * Install all the packages and GUI apps listed in the `install_lists/Brewfile`
  * Change the default shell to [fish](https://fishshell.com/)
  * Set Homebrew's version of OpenJDK to be used instead of system's
  * Sets up the directory to be a proper git repository if it was pulled during a bootstrap
  * Make a `~/Projects` directory and symlink the dotfiles there
  * Install a set of vim bundles, managed by [Vundle](https://github.com/VundleVim/Vundle.vim)
  * Install latest versions of Python 2 and 3 (3 as default), Ruby, and Node.js via [asdf](https://asdf-vm.com/)
  * Install Python packages listed in `install_lists/python{2|3}-dev-packages.txt`
  * Install Node-based programs listed in `install_lists/node-packages.txt`
  * Install the latest version of Rust via [rustup](https://www.rustup.rs/)
  * Set up appearance of Terminal.app
  * Set default browser to Firefox
  * Various and sundry macOS GUI settings (Finder behaviors, Trackpad settings, etc.)
  * Set up the Dock

The `provision-linux.sh` is much simpler because I don't have root on most Linux
machines I use, and tend to not have them quite as customized. All it does:
  * Symlink the designated dotfiles
  * Symlink this to ~/Projects/dotfiles
  * Install the vim bundles
  * Install pyenv, but nothing else

The Windows version (`provision-windows.ps1`) is pretty sparse. Used to use
[Chocolatey](http://chocolatey.org/), but want to shift it to use [WinGet](https://github.com/microsoft/winget-cli) before I set up another Windows machine. 

