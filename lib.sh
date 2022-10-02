#!/usr/bin/env bash

dotfiles_dir="$(dirname "$0")"

isFunction() { declare -F -- "$@" >/dev/null; }

path() {
  mkdir -p "$(dirname "$1")"
  echo "$(
    cd "$(dirname "$1")" || exit
    pwd
  )/$(basename "$1")"
}

link() {
  create_link "$dotfiles_dir/$1" "${HOME}/$1"
}

create_link() {
  real_file="$(path "$1")"
  link_file="$(path "$2")"

  rm -rf "$link_file"
  ln -s "$real_file" "$link_file"

  echo "$real_file <-> $link_file"
}

gem_install_or_update() {
  if gem list "$1" --installed >/dev/null; then
    gem update "${@}"
  else
    gem install "${@}"
    # rbenv rehash
  fi
}

git_clone_or_update() {
  if ! [ -x "$(command -v git)" ]; then
    echo 'You need to install git!' >&2
    exit 1
  fi

  echo ">>> $(basename "$2")"
  if [ ! -d "${2}" ]; then
    git clone "${1}" "${2}"
  else
    cd "${2}" || exit
    git pull
    cd "${INSTALLDIR}" || exit
  fi
}

installPkgList() {
  while IFS='' read -r PKG; do
    [[ -z ${PKG} ]] && continue
    [[ ${PKG} =~ ^#.*$ ]] && continue
    [[ ${PKG} =~ ^\\s*$ ]] && continue
    echo ">>> ${PKG}"
    eval "${1} ${PKG}"
  done <"${2}"
  cd "${INSTALLDIR}" || exit
}

