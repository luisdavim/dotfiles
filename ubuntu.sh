#!/usr/bin/env bash

installDocker() {
  # Don't run this as root as you'll not add your user to the docker group
  sudo apt update
  sudo apt install apt-transport-https ca-certificates software-properties-common curl
  # sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  # echo deb https://apt.dockerproject.org/repo ubuntu-$(lsb_release -c | awk '{print $2}') main | sudo tee /etc/apt/sources.list.d/docker.list
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt install -y "linux-image-extra-$(uname -r)"
  sudo apt purge lxc-docker docker-engine docker.io
  sudo rm -rf /etc/default/docker
  sudo apt install -y docker-ce
  sudo service docker start
  sudo usermod -aG docker "${USER}"
}

installGnomeTerminalProfiles() {
  # gconftool-2 --set /apps/gnome-terminal/profiles/Default/font --type string "Ubuntu Mono derivative Powerline 11"
  # gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_system_font --type=boolean false

  # Profiles from https://github.com/Mayccoll/Gogh
  export {PROFILE_NAME,PROFILE_SLUG}="TomorrowNightBright" && wget -O xt https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/tomorrow-night-bright.sh && chmod +x xt && ./xt && rm xt
  export {PROFILE_NAME,PROFILE_SLUG}="OneDark" && wget -O xt https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/one-dark.sh && chmod +x xt && ./xt && rm xt
  export {PROFILE_NAME,PROFILE_SLUG}="MonokaiDark" && wget -O xt https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/monokai-dark.sh && chmod +x xt && ./xt && rm xt
  export {PROFILE_NAME,PROFILE_SLUG}="SolarizedDark" && wget -O xt https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/solarized-dark.sh && chmod +x xt && ./xt && rm xt
  export {PROFILE_NAME,PROFILE_SLUG}="GruvboxDark" && wget -O xt https://raw.githubusercontent.com/Mayccoll/Gogh/master/themes/gruvbox-derk.sh && chmod +x xt && ./xt && rm xt
}

installi3wm() {
  if ! [ -x "$(command -v i3)" ]; then
    sudo apt install i3 i3blocks i3status i3lock compton conky-all alsa-utils mpd mpc ncmpcpp feh lxappearance rxvt-unicode-256color x11-xserver-utils gtk-chtheme qt4-qtconfig xcalib xprintidle npm python-pip arandr
    sudo pip install i3-cycle
    sudo npm i -g i3-alt-tab
  fi

  mkdir -p "${HOME}"/.config/i3
  cp -r files/config/i3/* "${HOME}/.config/i3/"

  # if [ -x "$(command -v nautilus)" ] && [ ! -x "$(command -v nautilus-i3)" ]; then
  #   sudo cp files/nautilus-i3 /usr/bin/
  # fi

  if [ ! -s "${HOME}/.i3" ]; then
    ln -s "${HOME}/.config/i3" "${HOME}/.i3"
  fi
}

installCerebro() {
  sudo npm install -g cerebro
  sudo npm install -g cerebro-linux-system
  sudo npm install -g cerebro-linux-commands
  sudo npm install -g cerebro-shell
  sudo npm install -g cerebro-fix-path
  sudo npm install -g cerebro-clipboard
  sudo npm install -g cerebro-kill
  sudo npm install -g cerebro-timezones
  sudo npm install -g cerebro-gif
  sudo npm install -g cerebro-imdb
  sudo npm install -g cerebro-ip
  sudo npm install -g cerebro-emoj
  sudo npm install -g cerebro-hash
  sudo npm install -g cerebro-stackoverflow
  sudo npm install -g cerebro-devdocs
}

addExtraRepos() {
  # Google
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
  echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
  # Spotify
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys BBEBDCB318AD50EC6865090613B00F1FD2C19886 0DF731E45CE24F27EEEB1450EFDC8610341D9410
  echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list
  # Skype
  wget -q -O - https://repo.skype.com/data/SKYPE-GPG-KEY | sudo apt-key add -
  echo 'deb [arch=amd64] https://repo.skype.com/deb stable main' | sudo tee /etc/apt/sources.list.d/skype-stable.list
  # Azure
  AZ_REPO=$(lsb_release -cs)
  sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

}

installPackages() {
  if ! [ -x "$(command -v git)" ]; then
    echo 'installing git!' >&2
    sudo apt install git
  fi
  if ! [ -x "$(command -v hh)" ]; then
    echo 'installing hh!' >&2
    sudo add-apt-repository ppa:ultradvorka/ppa && sudo apt update && sudo apt install hh
  fi

  addExtraRepos
  sudo apt update
  cat files/pkgs/apt-core.lst | grep -v '^$\|^\s*\#' | tr '\n' ' ' | xargs sudo apt install -y
  sudo apt-mark manual $(cat files/pkgs/apt-core.lst | grep -v '^$\|^\s*\#' | tr '\n' ' ')

  # You might need some extra PPAs for these
  cat files/pkgs/apt-extra.lst | grep -v '^$\|^\s*\#' | tr '\n' ' ' | xargs sudo apt install -y
  sudo apt-mark manual $(cat files/pkgs/apt-extra.lst | grep -v '^$\|^\s*\#' | tr '\n' ' ')

  if ! [ -x "$(command -v cerebro)" ]; then
    installCerebro
  fi
  if ! [ -x "$(command -v docker)" ]; then
    installDocker
  fi

  curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk

  sudo npm install -g coffeescrip
  # sudo npm install -g azure-cli
  installGnomeTerminalProfiles
}

case "$1" in
  "packages" | "pkgs")
    installPackages
    ;;
  "termProfiles" | "gnomeTermProfiles" | "termColors")
    installGnomeTerminalProfiles
    ;;
  "i3wm" | "i3")
    installi3wm
    ;;
  *)
    installPackages
    ;;
esac
