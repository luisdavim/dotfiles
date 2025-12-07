# Dotfiles

Personal dotfiles and workstation bootstrap scripts.

This repository contains my personal shell, editor and window manager configuration, helper scripts and an installer that can bootstrap a macOS, Ubuntu (Linux) or Android (Termux) environment.

If you're using this repository as a reference or to bootstrap a new machine, please read the Quick Start and the Safety & Customization sections before running any scripts.

## Highlights

This repo includes (but is not limited to):

- Bash and Zsh configuration (aliases, prompts, environment)
- Custom bash-git-prompt theme (includes kube-ps1 integration)
- tmux configuration (gpakosz/.tmux + custom theme)
- Vim / Neovim configuration and plugin install helpers
- Atom and VSCode configuration + package lists
- i3 and compton configuration and i3blocks scripts
- Hammerspoon configuration
- Useful scripts and kubectl plugins
- Installer script to install dotfiles, packages and fonts
- Backup script to export dotfiles, package lists and repos

## Quick Start

1. Clone the repo:

```sh
git clone https://github.com/luisdavim/dotfiles.git
cd dotfiles
```

2. Inspect configuration before installing:

```sh
less config.sh
```

3. Bootstrap a new workstation (interactive installer):

```sh
./install.sh all
```

Or run a specific installer task:

```sh
./install.sh dotfiles      # install dotfiles only (.vimrc, .bashrc, etc.)
./install.sh fonts         # install powerline-patched fonts
./install.sh vimplugins    # install vim/neovim plugins
./install.sh atompackages  # install Atom packages and config
./install.sh packages      # install packages from files/pkgs/apt.lst (or brew/cask on macOS)
./install.sh i3            # configure i3 (if applicable)
```

On Termux (Android):

```sh
termux-fix-shebang install.sh
./install.sh
```

## Requirements

- bash or zsh
- git
- For macOS: Homebrew (if using the brew/cask paths)
- For Ubuntu: apt
- For Termux: Termux environment

The install script may require sudo for some package operations.

## Safety & Customization (IMPORTANT)

Before running the installer you should review and (if needed) edit config.sh to reflect your preferences and environment. The installer will create symlinks and may install packages on your system.

- Open config.sh and change variables such as DOTFILES_DIR, INSTALL_PACKAGES and any username or platform-specific flags.
- Back up any existing configuration files you care about (e.g., ~/.bashrc, ~/.vimrc) before installing.

## Backup & Restore

A backup script is included to export or restore:

- List of apt or brew repositories
- Installed packages
- Atom packages and configuration
- Dotfiles managed by the installer

Usage examples:

```sh
./backup.sh dotfiles   # backup dotfiles managed by install.sh
./backup.sh atom       # backup atom configuration and package list
./backup.sh repos      # backup deb package repos
```

Restore follows similar commands; read the backup.sh header for details.

## Repository layout

Top-level files:

```
.
├── README.md
├── install.sh
├── backup.sh
├── config.sh
└── files
    ├── bash
    │   └── README.md
    ├── hammerspoon
    │   └── README.md
    └── i3
        └── README.md
```

See the sub-README files under files/ for component-specific documentation.

## Troubleshooting

- If install.sh fails on package installation, re-run with logs enabled or run the failing command manually to inspect errors.
- On macOS, ensure Homebrew is installed and up to date.
- On Termux, use termux-fix-shebang before running the installer to correct script shebangs.
- If a prompt or plugin installation doesn't behave as expected, check the corresponding dotfile (e.g., .vimrc, .tmux.conf) and the component README.

## Contributing

This repository is my personal configuration. If you want to adapt parts for your use, feel free to open issues or PRs suggesting improvements. If you submit a PR:

- Keep changes focused and documented.
- Explain why the change is useful and platform considerations.
- Do not include credentials or machine-specific data.

## License & Credits

- See LICENSE (if included) for license details.
- This setup installs and integrates several external projects:
  - https://github.com/magicmonty/bash-git-prompt
  - https://github.com/jonmosco/kube-ps1
  - https://github.com/gpakosz/.tmux
  - Other small scripts and plugins referenced in files/

## Contact

If you have questions about these dotfiles, you can open an issue on the repository.

---

Enjoy — and remember to review config.sh before running any automated scripts.
