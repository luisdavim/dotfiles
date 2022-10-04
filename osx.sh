#!/usr/bin/env bash

dotfiles_dir="$(dirname "$0")"
source "${dotfiles_dir}/lib.sh"

export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

if [[ $OSTYPE != "darwin"* ]]; then
  echo 'Doesnt look like you are on OS X'
  echo '  please try the install.sh script'
  exit 1
fi

INSTALLDIR=$(pwd)

fancy_echo() {
  local fmt="$1"
  shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "${@}"
}

brew_install_or_upgrade() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      brew upgrade "${@}"
    fi
  else
    brew install "${@}"
  fi
}

cask_install() {
  if cask_is_installed "$1"; then
    fancy_echo "$1 is already installed!"
  else
    fancy_echo "Installing $1 ..."
    brew install --cask "${@}" --appdir=/Applications
  fi
}

brew_is_installed() {
  local name
  name="$(brew_expand_alias "$1")"

  brew list -1 | grep -Fqx "$name"
}

cask_is_installed() {
  local name
  name="$(cask_expand_alias "$1")"

  brew list --cask -1 | grep -Fqx "$name"
}

brew_is_upgradable() {
  local name
  name="$(brew_expand_alias "$1")"

  ! brew outdated --quiet "$name" >/dev/null
}

brew_tap() {
  fancy_echo "Adding Tap: $1 ..."
  brew tap "$1" || brew tap "$1" --repair 2>/dev/null
}

brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/.*\//, ""); gsub(/==>/, ""); gsub(/:/, ""); print $1}'
}

cask_expand_alias() {
  brew info --cask "$1" 2>/dev/null | head -1 | awk '{gsub(/.*\//, ""); gsub(/==>/, ""); gsub(/:/, ""); print $1}'
}

brew_launchctl_restart() {
  local name
  name="$(brew_expand_alias "$1")"
  local domain="homebrew.mxcl.$name"
  local plist="$domain.plist"

  mkdir -p "${HOME}/Library/LaunchAgents"
  ln -sfv "/usr/local/opt/$name/$plist" "${HOME}/Library/LaunchAgents"

  if launchctl list | grep -Fq "$domain"; then
    launchctl unload "${HOME}/Library/LaunchAgents/$plist" >/dev/null
  fi
  launchctl load "${HOME}/Library/LaunchAgents/$plist" >/dev/null
}

osConfigs() {
  # Enable Key Repeat
  defaults write -g ApplePressAndHoldEnabled -bool false
  # Set keyboard repeate speed
  defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
  defaults write -g KeyRepeat -int 1         # normal minimum is 2 (30 ms)

  # Font rendering (requires restart)
  defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

  # Dock
  # Add a Stack with Recent Applications
  # defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
  # Enable icon bounce
  # defaults write com.apple.dock no-bouncing -bool true
  # Set dock size and magnification
  defaults write com.apple.dock tilesize -int 48
  defaults write com.apple.dock largesize -int 57
  defaults write com.apple.dock magnification -bool true
  # Enable auto hiding
  defaults write com.apple.dock autohide -bool true
  # Move to the left
  defaults write com.apple.dock orientation left
  killall Dock

  # Reduce Transparency
  # defaults write com.apple.universalaccess reduceTransparency -bool true

  # Enable Develop Menu and Web Inspector in Safari
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true &&
    defaults write com.apple.Safari IncludeDevelopMenu -bool true &&
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true &&
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true &&
    defaults write -g WebKitDeveloperExtras -bool true

  # Enable Developer Mode using XCode
  sudo /usr/sbin/DevToolsSecurity -enable

  echo 'You may need to restart for some changes to take effect!'
}

installHomebrew() {
  if [ ! -x "$(command -v brew)" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/stephennancekivell/brew-update-notifier/master/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

installPackages() {
  if ! [ -x "$(command -v git)" ]; then
    echo 'You need to install git!' >&2
    xcode-select --install
    exit 1
  fi
  sudo spctl --master-disable
  installHomebrew

  # Add brew taps
  installPkgList "brew_tap" files/pkgs/tap.lst

  fancy_echo "Updating brew formulae ..."
  brew update

  # Install brew pkgs
  # installPkgList "brew_install_or_upgrade" files/pkgs/brew.lst
  grep -Ev '\s*#' files/pkgs/brew.lst | tr '\n' '\0' | xargs -0 -n1 brew install

  # Install cask pkgs
  brew_install_or_upgrade cask
  installPkgList "cask_install" files/pkgs/cask.lst

  echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
  echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells >/dev/null
  # Set bash as the login shell
  # chsh -s $(brew --prefix)/bin/bash

  # gettext is installed as a dependency but it's not linked
  brew link gettext --force

  fancy_echo "Cleaning old Homebrew formulae ..."
  brew cleanup
  # brew cask cleanup
}

installItermColors() {
  name="$*"
  url="https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/${name// /%20}.itermcolors"
  curl -fLo theme.itermcolors "${url}"
  echo "importing ${name} from ${url}"
  defaults write -app iTerm 'Custom Color Presets' -dict-add "${name// /_}" "$(cat theme.itermcolors)"
  rm theme.itermcolors
}

function installIterm() {
  cask_install "iterm2"
  cp files/iterm/com.googlecode.iterm2.plist "${HOME}"/Library/Preferences/com.googlecode.iterm2.plist
  plutil -convert binary1 "${HOME}"/Library/Preferences/com.googlecode.iterm2.plist
  defaults read com.googlecode.iterm2
}

installFonts() {
  mkdir -p "${HOME}"/Library/Fonts
  curl -fLo DroidSansMonoForPowerlinePlusNerdFileTypes.otf https://raw.githubusercontent.com/ryanoasis/nerd-fonts/1.0.0/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20for%20Powerline%20Nerd%20Font%20Complete.otf
  chmod 664 DroidSansMonoForPowerlinePlusNerdFileTypes.otf
  mv ./*.otf "${HOME}"/Library/Fonts
  curl -sfLO https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
  sudo mv PowerlineSymbols.otf "${HOME}"/Library/Fonts/
  git_clone_or_update https://github.com/pdf/ubuntu-mono-powerline-ttf.git "${HOME}/Library/Fonts/ubuntu-mono-powerline-ttf"
  cd "${INSTALLDIR}" || exit
}

installDotFiles() {
  if ! [ -x "$(command -v git)" ]; then
    echo 'You need to install git!' >&2
    xcode-select --install
    exit 1
  fi

  for dir in $(ls -1d files/config/*/); do
    cp -r files/config/"${dir##*/}"/* "${HOME}/Library/Application Support/${dir##*/}/"
  done

  mkdir -p "${HOME}"/.hammerspoon/
  mkdir -p "$HOME"/.hammerspoon/hs

  cd "${INSTALLDIR}" || exit

  cp files/slate/slate "${HOME}"/.slate
  cp files/slate/slate.js "${HOME}"/.slate.js
  # cp files/chunkwm/chunkwmrc ${HOME}/.chunkwmrc
  # cp files/chunkwm/skhdrc ${HOME}/.skhdrc
  cp files/yabai/yabairc "${HOME}"/.yabairc
  cp files/yabai/skhdrc "${HOME}"/.skhdrc

  git_clone_or_update https://github.com/dsanson/hs.tiling "$HOME/.hammerspoon/hs/tiling"

  cp -r files/hammerspoon/* "${HOME}"/.hammerspoon/

  git_clone_or_update https://github.com/lunixbochs/reslate.git "${HOME}/.reslate"

  for f in ~/.config/*; do
    if [ ! -s "${f}" ]; then
      ln -s "${f}" "${HOME}/Library/Preferences/${f##*/}"
    fi
  done

  mkdir -p /usr/local/etc/bash_completion.d
  cp files/shell/bash/bash_aliases_completion /usr/local/etc/bash_completion.d/
  curl -sfLo knife_autocomplete https://raw.githubusercontent.com/wk8/knife-bash-autocomplete/master/knife_autocomplete.sh
  sudo mv knife_autocomplete /usr/local/etc/bash_completion.d/
  curl -sfLo kitchen-completion https://raw.githubusercontent.com/MarkBorcherding/test-kitchen-bash-completion/master/kitchen-completion.bash
  sudo mv kitchen-completion /usr/local/etc/bash_completion.d/

  cd "${INSTALLDIR}" || exit
}

installAll() {
  installPackages
  installFonts
  installDotFiles
  # installIterm
  osConfigs
}

case "$1" in
"packages" | "pkgs")
  installPackages
  ;;
"dotfiles")
  installDotFiles
  ;;
"fonts")
  installFonts
  ;;
"itermcolors" | "termColors" | "termProfiles")
  installItermColors "${@:2}"
  ;;
*)
  installAll
  ;;
esac
