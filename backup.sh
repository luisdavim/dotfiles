#!/usr/bin/env bash

function backupDotFiles() {
  mkdir -p files
  cp "${HOME}/.bash/git_prompt.sh" files/shell/bash/git_prompt.sh
  cp "${HOME}/.bash/shell_prompt.sh" files/shell/bash/shell_prompt.sh
  cp "${HOME}/.bashrc" files/shell/bash/bashrc
  cp "${HOME}/.bash_profile" files/shell/bash/bash_profile
  cp "${HOME}/.variables" files/shell/variables
  cp "${HOME}/.aliases" files/shell/aliases
  cp -r "${HOME}/.aliases.d"/* files/shell/aliases.d/
  cp "${HOME}/.zshrc" files/shell/zsh/zshrc
  cp "${HOME}/.p10k.zsh" files/shell/zsh/p10k.zsh
  cp /etc/bash_completion.d/bash_aliases_completion files/shell/bash/bash_aliases_completion
  cp "${HOME}/.profile" files/shell/profile
  cp "${HOME}/.git-prompt-colors.sh" files/shell/bash/git-prompt-colors.sh
  cp "${HOME}/.tmux.conf.local" files/shell/tmux.conf.local
  cp "${HOME}/.screenrc" files/shell/screenrc
  cp "${HOME}/.vimrc" files/vim/vimrc
  cp "${HOME}/.vimrc.local" files/vim/vimrc.local
  cp "${HOME}/.vim/coc-settings.json" files/vim/
  cp -r "${HOME}/.vim/ft"* files/vim/
  cp "${HOME}/.atom/"*.cson files/atom/
  cp "${HOME}/.atom/"*.coffee files/atom/
  cp "${HOME}/.atom/"*.less files/atom/
  cp "${HOME}/.atom/"*.json files/atom/
  cp "${HOME}/.config/tilda/config_0" files/config/tilda/config_0
  cp "${HOME}/.config/terminator/config" files/config/terminator/config
  cp "${HOME}/.config/alacritty/alacritty.yml" files/config/alacritty.yml
  cp "${HOME}/.config/starship.toml" files/config/starship.toml
  cp -r "${HOME}/.config/pistol" files/config/
  cp -r "${HOME}/.config/kitty/"* files/config/kitty/
  cp -r "${HOME}/.config/lf/"* files/config/lf/
  cp -r "${HOME}/.config/i3/"* files/config/i3/
  cp -r "${HOME}/.hammerspoon/"* files/hammerspoon/
  cp "${HOME}/.slate" files/slate/slate
  cp "${HOME}/.slate.js" files/slate/slate.js
  cp "${HOME}/.chunkwmrc" files/chunkwm/chunkwmrc
  cp "${HOME}/.yabairc" files/yabai/yabairc
  cp "${HOME}/.skhdrc" files/yabai/skhdrc
  cp "${HOME}/.ptpython/config.py" files/ptpython.py
  cp "${HOME}/.pipecolor.toml" files/pipecolor.toml
}

function backupTermux() {
  pkg list-installed | cut -d '/' -f1 | grep -v '\.\.\.' | sort -u >files/pkgs/pkg.lst
  cp -r "${HOME}/.termux/"*.* files/termux/
  cp -r "${HOME}/.termux/".* files/termux/
}

function backupIterm() {
  defaults read com.googlecode.iterm2 >files/iterm/com.googlecode.iterm2.plist
}

function restoreIterm() {
  cp files/iterm/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
  plutil -convert binary1 ~/Library/Preferences/com.googlecode.iterm2.plist
  defaults read com.googlecode.iterm2
}

function exportItermColors() {
  cdir=$(pwd)
  mkdir -p files/iterm
  cd files/iterm || exit
  # rm -f *
  /usr/libexec/PlistBuddy -c "print :'Custom Color Presets'" \
    ~/Library/Preferences/com.googlecode.iterm2.plist | grep '^    \w' |
    ruby -e 'puts STDIN.read.gsub(/\s=\sDict\s{/,"").gsub(/^\s+/,"")' >list.txt
  while read -r THEME; do
    echo "exporting ${THEME}"
    /usr/libexec/PlistBuddy -c "print :'Custom Color Presets':'$THEME'" \
      ~/Library/Preferences/com.googlecode.iterm2.plist |
      ruby -e "puts STDIN.read.strip.gsub(/Dict {/, '{')
        .gsub(/([A-Z][a-z0-9\\s]+)\\s=\\s/i, %Q{'\\\\1' = })
        .gsub(/(\\d(?:\.\\d+)?)$/, %Q{'\\\\1';})
        .gsub(/}\\n/, %Q(};\n))" >"$THEME.itermcolors"
  done <list.txt
  rm list.txt
  cd "${cdir}" || exit
}

function importItermColors() {
  cdir=$(pwd)
  cd files/iterm || exit
  for f in *.itermcolors; do
    THEME=$(basename "${f%.*}")
    echo "importing ${THEME}"
    defaults write -app iTerm 'Custom Color Presets' -dict-add "$THEME" "$(cat "${f}")"
  done
  cd "${cdir}" || exit
}

function backupAtomPackages() {
  apm list --installed --bare | cut -d'@' -f1 | grep -vE '^$' >files/pkgs/atom-packages.lst
  cp "${HOME}"/.atom/*.cson files/atom/
  cp "${HOME}"/.atom/*.coffee files/atom/
  cp "${HOME}"/.atom/*.less files/atom/
  cp "${HOME}"/.atom/*.json files/atom/
}

function backupVscode() {
  code --list-extensions >files/pkgs/vscode-packages.lst
  settings="${HOME}/.config/Code/User"
  if [[ ${OSTYPE} == "darwin"* ]]; then
    settings="${HOME}/Library/Application Support/Code/User"
  fi
  cp -r "${settings}"/* files/vscode/
}

function backupPPAs() {
  # Get list of PPAs
  for APT in $(find /etc/apt/ -name \*.list); do
    grep -Po "(?<=^deb\s).*?(?=#|$)" "$APT" | while read ENTRY; do
      HOST=$(echo "$ENTRY" | cut -d/ -f3)
      USER=$(echo "$ENTRY" | cut -d/ -f4)
      PPA=$(echo "$ENTRY" | cut -d/ -f5)
      if [ "ppa.launchpad.net" = "$HOST" ]; then
        echo "ppa:$USER/$PPA" >>files/pkgs/ppa.lst
      else
        echo "\"${ENTRY}\"" >>files/pkgs/apt-repo.lst
      fi
    done
  done
}

function backupPacman() {
  pacman -Qqe >files/pkgs/pacman.lst
}

function backupPackages() {
  # Get list of installed packages
  apt-mark showauto >files/pkgs/pkgs_auto.lst
  apt-mark showmanual >files/pkgs/pkgs_manual.lst
}

function backupAll() {
  backupDotFiles
  backupAtomPackages
  backupVscode
  if [[ $OSTYPE != "darwin"* ]]; then
    backupPPAs
  fi
}

function restorePackages() {
  sudo apt-get update
  cat files/pkgs/pkgs_manual.lst | tr '\n' ' ' | xargs sudo apt-get install -y
  sudo apt-mark auto $(cat files/pkgs/pkgs_auto.lst | tr '\n' ' ')
  sudo apt-mark manual $(cat files/pkgs/pkgs_manual.lst | tr '\n' ' ')
}

function backupHomeDir() {
  if [ ! -d "$1" ]; then
    echo "$1 is not a valid directory"
  fi
  FOLDER=$(echo "$1" | sed 's/\/$//g')
  sudo rsync -aP --exclude-from=files/rsync-homedir-excludes.txt "${HOME}/" "${FOLDER}/"
}

function restoreRepos() {
  LISTS=('files/pkgs/ppa.lst' 'files/pkgs/apt-repo.lst')
  for LST in "${LISTS[@]}"; do
    while read -r REPO; do
      [[ ${REPO} =~ ^#.*$ ]] && continue
      [[ ${REPO} =~ ^\\s*$ ]] && continue
      sudo apt-add-repository "${REPO}"
    done <"files/pkgs/${LST}"
  done
  sudo apt update
}

function restoreDotfiles() {
  bash install.sh dotfiles
}

function restoreAll() {
  restoreRepos
  restorePackages
}

case "$1" in
"dotfiles")
  backupDotFiles
  ;;
"atompackages" | "apkgs" | "atom")
  backupAtomPackages
  ;;
"vscode")
  backupVscode
  ;;
"ppas" | "repos")
  backupPPAs
  ;;
"pacman")
  backupPacman
  ;;
"termux")
  backupTermux
  ;;
"homedir" | "home")
  backupHomeDir "$2"
  ;;
"iterm" | "iterm2")
  backupIterm
  ;;
"itermColors" | "iterm2Colors")
  exportItermColors
  ;;
"restore")
  restoreAll
  ;;
*)
  backupAll
  ;;
esac
