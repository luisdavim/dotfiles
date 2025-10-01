#!/usr/bin/env bash

dotfiles_dir="$(dirname "$0")"

# shellcheck source=./lib.sh
source "${dotfiles_dir}/lib.sh"

if [[ $OSTYPE != *"android"* ]]; then
  echo 'Doesnt look like you are on Android'
  echo '  please try the install.sh script'
  exit 1
fi

INSTALLDIR=$(pwd)

installGYP() {
  mkdir ~/.gyp && echo "{'variables':{'android_ndk_path':''}}" > ~/.gyp/include.gypi
}

installPackages() {
  installGYP

  apt update && apt upgrade
  grep -Ev '\s*#' files/pkgs/pkg.lst | tr '\n' ' ' | xargs apt install -y

  ./install.sh gopkgs
  pip install -U pip
  pip install -U pipx
  pip install -U neovim
  installAwsCli
}

installAwsCli() {
  # curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
  # unzip awscliv2.zip
  # ./aws/install -i ~/.local/aws-cli -b ~/.local/bin --update
  # rm -rf aws
  # rm awscliv2.zip

  export CARGO_BUILD_TARGET=aarch64-linux-android

  # if [ ! -d "${PREFIX}/share/awscli" ]; then
  #   git clone -b v2 https://github.com/aws/aws-cli.git "${PREFIX}/share/awscli"
  # fi
  # cd "${PREFIX}/share/awscli" || return
  # git checkout .
  # git pull
  # pip install -e .

  pipx install git+https://github.com/aws/aws-cli.git@v2

  # pip install -U awscliv2

  cd "${INSTALLDIR}" || exit
}

installDotFiles() {
  if ! [ -x "$(command -v git)" ]; then
    echo 'installing git!' >&2
    apt install git
  fi

  mkdir -p "${HOME}/.termux/"
  cd "${INSTALLDIR}" || exit

  cp -r files/termux/* "${HOME}/.termux/"

  cp files/shell/bash/bash_aliases_completion "${PREFIX}/etc/bash_completion.d/"
  curl -sfLo knife_autocomplete https://raw.githubusercontent.com/wk8/knife-bash-autocomplete/master/knife_autocomplete.sh
  mv knife_autocomplete "${PREFIX}/etc/bash_completion.d/"
  curl -sfLo kitchen-completion https://raw.githubusercontent.com/MarkBorcherding/test-kitchen-bash-completion/master/kitchen-completion.bash
  mv kitchen-completion "${PREFIX}/etc/bash_completion.d/"

  # termux-fix-shebang /data/data/com.termux/files/usr/etc/bash_completion.d/*
  # grep -lir --exclude-dir=.git '#!' ${HOME}/.bash/ | xargs -n 1 termux-fix-shebang

  cd "${INSTALLDIR}" || exit
}

installThemes() {
  git_clone_or_update https://github.com/adi1090x/termux-style.git "${PREFIX}/share/termux-style"
  if [ ! -s "${PREFIX}/bin/termux-style" ]; then
    ln -s "${PREFIX}/share/termux-style/tstyle" "${PREFIX}/bin/termux-style"
  fi
}

osConfigs() {
  if [ ! -d "${HOME}/storage" ]; then
    termux-setup-storage
  fi
  termux-fix-shebang /data/data/com.termux/files/usr/bin/*
}

installAll() {
  installPackages
  installDotFiles
  installThemes
  osConfigs
}

case "$1" in
  "packages" | "pkgs")
    installPackages
    ;;
  "awscli")
    installAwsCli
    ;;
  "dotfiles")
    installDotFiles
    ;;
  *)
    installAll
    ;;
esac
