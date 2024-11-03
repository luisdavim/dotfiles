#!/usr/bin/env bash

installPackages() {
  sudo pacman -Syu
  if [[ "$(uname -r)" == *"android"* ]]; then
    sudo pacman -Rscu xorg
    sudo echo "LC_ALL=en_US.UTF-8" >>/etc/environment
    sudo echo "en_US.UTF-8 UTF-8" >>/etc/locale.gen
    sudo echo "LANG=en_US.UTF-8" >/etc/locale.conf
    sudo locale-gen en_US.UTF-8
  fi
  cat files/pkgs/pacman.lst | grep -v '^$\|^\s*\#' | tr '\n' ' ' | xargs sudo pacman -S
}

case "$1" in
"packages" | "pkgs")
  installPackages
  ;;
*)
  installPackages
  ;;
esac
