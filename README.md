# Dotfiles

## What's included

- a bash and zsh configuration
- a set of shell aliases
- some kubectl plugins
- some useful scripts
- installs https://github.com/magicmonty/bash-git-prompt.git
- installs https://github.com/jonmosco/kube-ps1
- a custom theme for bash-git-prompt that includes kube-ps1
- installs https://github.com/gpakosz/.tmux
- a custom theme for tmux
- vim/neovim configuration
- Atom configuration including list of installed packages
- VSCode configuration including list of installed packages
- i3 and compton configuration files
- i3blocks scripts
- iTerm profile
- Hammerspoon configuration scripts

## The install script

The install script supports macOS, Linux (Ubuntu) and Android ([Termux](https://termux.com)) and will install my custom dotfiles but also some extra packages and fonts, you can select what to install by passing an argument to the install script:

```sh
./install all # to bootstrap a new workstation
./install dotfiles # will install the dotfiles only (.vimrc .bashrc etc...)
./install fonts # will install some powerline patched fonts
./install vimplugins # will install the vim plugins from the vimrc
./install atompackages # will install the atom plugins and configuration
./install packages # will install the packages listed in files/pkgs/apt.lst (or brew.lst and cask.lst if running on macOS)
./install i3 # will install and configure i3
```

To install on android use:

```sh
termux-fix-shebang install.sh; ./install.sh
```

**NOTE:** Before running the install script you **should** take a **look at** the **config.sh** file and edit it to your preferences

## The backup script

The backup script can backup and restore your:

- List of deb repos
- Installed packages
- Atom packages
- Dotfiles

Usage examples:

```sh
./backup.sh dotfiles # Will backup your dotfiles, the ones managed by the install.sh script
./backup.sh atom # Will backup your atom configuration files and installed package list
./backup.sh repos # Will backup your deb package repos
```

## For more information check out the other README files and the code

```console
.
├── README.md
└── files
    ├── bash
    │   └── README.md
    ├── hammerspoon
    │   └── README.md
    └── i3
        └── README.md
```
