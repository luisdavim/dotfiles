#!/usr/bin/env bash

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
INSTALLDIR=$(pwd)
dotfiles_dir="$(dirname "$0")"

CMD="${1:-all}"
shift
ARGS=("${@}")

NVIM_FLAVOUR="${NVIM_FLAVOUR:-coc}"

# shellcheck source=./files/scripts/hubinstall
source "${dotfiles_dir}/files/scripts/hubinstall"
# shellcheck source=./files/scripts/hashinstall
source "${dotfiles_dir}/files/scripts/hashinstall"
# shellcheck source=./files/scripts/gobinaries
source "${dotfiles_dir}/files/scripts/gobinaries"
# shellcheck source=./lib.sh
source "${dotfiles_dir}/lib.sh"

installEls() {
  installFromRawGithub 'AnthonyDiGirolamo/els'
}

installAwless() {
  pipeBashFromRawGithub 'wallix/awless/master' 'getawless.sh'
  mv awless ~/.local/bin/
}

installUdocker() {
  mkdir -p ~/.local
  pushd ~/.local
  python3 -m venv udockervenv
  source udockervenv/bin/activate
  pip install udocker
  # udocker install
  udockervenv/bin/udocker install
  popd
  if [[ $OSTYPE != *"android"* ]]; then
    # https://github.com/indigo-dc/udocker/issues/424
    # Force use Termux provided proot
    mkdir -p "${HOME}/.udocker/lib"
    cat <<EOF >"${HOME}/.udocker/udocker.conf"
[DEFAULT]
use_proot_executable = ${PREFIX}/bin/proot
proot_link2symlink = True
verbose_level = 3
EOF
    # Create dummy VERSION to suppress redundant download of Android-incompatible udockertools
    # https://github.com/indigo-dc/udocker/issues/376#issuecomment-1300626183
    echo "9.9.9" >"${HOME}/.udocker/lib/VERSION"
  fi
}

installFastPath() {
  # https://github.com/mfornasa/docker-fastpath
  mkdir -p ~/.local/bin/
  version='linux'
  arch='-amb64'
  if [[ $OSTYPE == "darwin"* ]]; then
    version='osx'
    arch=''
  fi
  curl https://docker-fastpath.s3-eu-west-1.amazonaws.com/releases/${version}/docker-fastpath-${version}"${arch}"-latest.zip >fastpath.zip
  unzip fastpath.zip
  chmod +x fastpath && mv fastpath ~/.local/bin/
}

installFission() {
  # http://fission.io/
  mkdir -p ~/.local/bin/
  version='linux'
  if [[ $OSTYPE == "darwin"* ]]; then
    version='mac'
  fi
  curl http://fission.io/$version/fission >fission && chmod +x fission && mv fission ~/.local/bin/
}

installMinikube() {
  mkdir -p ~/.local/bin/
  curl -Lo "minikube https://storage.googleapis.com/minikube/releases/latest/minikube-${OS}-amd64"
  chmod +x minikube
  mv minikube ~/.local/bin/
}

installKrew() {
  if ! [ -x "$(command -v kubectl-krew)" ]; then
    mkdir -p "${HOME}/.krew/bin"
    cd "$(mktemp -d)" &&
      # OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      # ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    cd "${INSTALLDIR}" || exit
  fi

  # install krew packages
  kubectl-krew update
  installPkgList "kubectl-krew install" files/pkgs/krew.lst
}

installKubeScripts() {
  git_clone_or_update https://github.com/arunvelsriram/kube-fzf.git "${HOME}/.kube-fzf"
  git_clone_or_update https://github.com/kubermatic/fubectl.git "${HOME}/.fubectl"
  git_clone_or_update https://github.com/heptiolabs/ktx "${HOME}/.ktx"
  # git_clone_or_update https://github.com/alexppg/kbenv.git ${HOME}/.kbenv
  # git_clone_or_update https://github.com/alexppg/helmenv.git ${HOME}/.helmenv

  installKrew

  installFromRawGithub 'johanhaleby/kubetail'
  installFromRawGithub 'ctron/kill-kube-ns'
  # installFromRawGithub 'ahmetb/kubectx'
  # installFromRawGithub 'ahmetb/kubectx' 'kubens'

  # installFromGithub 'abiosoft/colima' '-' "${2}"
  installFromGithub 'flavio/kuberlr' "${1}" "${2}"
  installFromGithub 'doitintl/kube-no-trouble' "${1}" "${2}" "kubent"
  # installFromGithub 'Praqma/helmsman' "${1}" "${2}"
  installFromGithub 'kubeshark/kubeshark' "${1}" "${2}"
  installFromGithub 'shyiko/kubesec' "${1}" "${2}"
  installFromGithub 'kubermatic/kubeone' "${1}" "${2}"
  installFromGithub 'kubernetes-sigs/kustomize' "${1}" "${2}"
  installFromGithub 'kubernetes-sigs/kubebuilder' "${1}" "${2}"
  # installFromGithub 'operator-framework/operator-sdk' "${1}" "${2}"
  installFromGithub 'nutellinoit/kubenvz' "${1}" "${2}"
  installFromGithub 'jaredallard/localizer' "${1}" "${2}"

  installFromGithub 'loft-sh/loft' "${1}" "${2}"
  installFromGithub 'loft-sh/vcluster' "${1}" "${2}"
  installFromGithub 'loft-sh/devspace' "${1}" "${2}"
  devspace add plugin https://github.com/loft-sh/devspace-plugin-loft || devspace update plugin loft

  if [ -f "${HOME}/.local/bin/kuberlr" ] && [ ! -s "${HOME}/.local/bin/kubectl" ]; then
    ln -s "${HOME}/.local/bin/kuberlr" "${HOME}/.local/bin/kubectl"
  fi

  curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh
  mv crossplane "${HOME}/.local/bin/"
  mv kubectl-crossplane "${HOME}/.local/bin/"

  installHelmPlugins
}

installDCOScli() {
  mkdir -p ~/.local/bin/
  curl -Lo dcos "https://downloads.dcos.io/binaries/cli/${OS}/x86-64/latest/dcos"
  chmod +x dcos
  mv dcos ~/.local/bin/
}

installGoss() {
  mkdir -p ~/.local/bin/
  curl -fsSL https://goss.rocks/install | GOSS_DST=~/.local/bin sh
}

installDepcon() {
  installFromGithub 'ContainX/depcon' "${1}" "${2}"
}

installAsdfPlugins() {
  cp files/asdfrc "${HOME}/.asdfrc"
  installPkgList "asdf plugin add" files/pkgs/asdf.lst
}

installCargo() {
  if ! [ -x "$(command -v cargo)" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    [ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"
    rustup component add rls rust-analysis rust-src
  fi

  installPkgList "cargo install --force" files/pkgs/cargo.lst
}

installGems() {
  installPkgList gem_install_or_update files/pkgs/gem.lst
}

installChefGems() {
  export CHEF_LICENSE=accept-silent
  installPkgList "chef gem install" files/pkgs/chef_gem.lst
}

installPips() {
  installPkgList "pip install -U" files/pkgs/pip.lst
}

installNpms() {
  installPkgList "npm install -g" files/pkgs/npm.lst
}

installGoPkgs() {
  # goinstall "${PKG}"
  installPkgList "go install" <(sed 's|$|@latest|g' files/pkgs/go.lst)
  cleanGoPkgs
}

installGhExtensions() {
  installPkgList "gh extension install" files/pkgs/gh.lst
  installPkgList "gh extension upgrade" files/pkgs/gh.lst
}

cleanGoPkgs() {
  go clean -modcache
  rm -rf "${HOME}/.glide/"*
  rm -rf "${GOPATH/:*/}/src/"*
  rm -rf "${GOPATH/:*/}/pkg/"*
  rm -rf "${GOPATH/:*/}/.cache"
  rm -rf "${HOME}/.cache/go-build/"
}

installHelmPlugins() {
  if ! [ -x "$(command -v helm)" ]; then
    if [[ $OSTYPE == *"android"* ]]; then
      cd "${INSTALLDIR}" || exit
      cleanGoPkgs
      echo ">>> helm"
      go get -d -u k8s.io/helm/cmd/helm
      cd "${GOPATH/:*/}/src/k8s.io/helm/" || exit
      make bootstrap build
      mv bin/* "${GOPATH/:*/}/bin/"
      echo ">>> Cleanup go sources"
      cd "${INSTALLDIR}" || exit
      cleanGoPkgs
    elif [[ $OSTYPE != "darwin"* ]]; then
      sudo apt-get install helm
    else
      brew install kubernetes-helm
    fi
  fi

  if [ -x "$(command -v helmenv)" ]; then
    # Install the latest helm version
    latest=$(helmenv list remote | sort --version-sort | tail -1)
    helmenv install "${latest}"
    helmenv use "${latest}"
  fi

  if [ "$(helm version --short 2>/dev/null | grep -Eo 'Client')" == "Client" ]; then
    helm init --client-only
  fi

  installPkgList "helm plugin install" files/pkgs/helm.lst
}

installTestssl() {
  git_clone_or_update https://github.com/drwetter/testssl.sh.git "${HOME}"/.testssl
  if [ ! -s "${HOME}/.local/bin/testssl" ]; then
    ln -s "${HOME}/.testssl/testssl.sh" "${HOME}"/.local/bin/testssl
  fi
}

installScripts() {
  mkdir -p ~/.local/bin/
  cp -r files/scripts/* "${HOME}/.local/bin/"
  installFromGithub 'AkihiroSuda/sshocker'
  installFromRawGithub 'huyng/bashmarks' 'bashmarks.sh'
  installFromRawGithub 'ahmetb/goclone'
  # installFromRawGithub 'mykeels/slack-theme-cli' 'slack-theme'
  # installFromRawGithub 'smitt04/slack-dark-theme' 'darkSlack.sh'
  installFromGithub 'dotenv-linter/dotenv-linter'
  # if [[ $OSTYPE == *"android"* ]]; then
  #   termux-fix-shebang "${HOME}/.local/bin/"*
  # fi
  installTestssl
  git_clone_or_update https://github.com/wookayin/kitty-tmux.git "${HOME}/.kitty-tmux"

  if [[ $OSTYPE != *"android"* ]]; then
    if [[ $OSTYPE == "darwin"* ]]; then
      installKubeScripts 'darwin' '64'
    else
      installKubeScripts 'linux' '64'
    fi
  fi
}

installChefVM() {
  git_clone_or_update https://github.com/trobrock/chefvm.git "${HOME}/.chefvm"
  ~/.chefvm/bin/chefvm init
}

installAtomPackages() {
  mkdir -p ~/.atom/
  cd "${INSTALLDIR}" || exit
  # Backup package list with:
  #   apm list --installed --bare | cut -d'@' -f1 | grep -vE '^$' > atom-packages.lst
  cp files/atom/* "${HOME}/.atom/"
  # apm install --packages-file files/pkgs/atom-packages.lst
  installPkgList "apm install" files/pkgs/atom-packages.lst
}

installVscodeConfig() {
  settings="$HOME/.config/Code/User"
  if [[ $OSTYPE == "darwin"* ]]; then
    settings="$HOME/Library/Application Support/Code/User"
  fi
  mkdir -p "$settings"
  cp -r files/vscode/* "$settings/"
}

installVscodePackages() {
  installVscodeConfig

  installPkgList "code --install-extension" files/pkgs/vscode-packages.lst
}

installTmuxConf() {
  cp files/shell/tmux.conf.local "${HOME}/.tmux.conf.local"
  git_clone_or_update https://github.com/gpakosz/.tmux.git "${HOME}/.tmux"
  if [ ! -s "${HOME}/.tmux.conf" ]; then
    ln -s "${HOME}/.tmux/.tmux.conf" "${HOME}/.tmux.conf"
  fi
}

installHelix() {
  if [ ! -x "$(command -v hx)" ]; then
    return
  fi
  mkdir -p "${HOME}/.config/helix/"
  cp -r files/config/helix/* "${HOME}/.config/helix/"
  hx -g fetch
  hx -g build
}

installVimPlugins() {
  if [ -x "$(command -v pip)" ]; then
    pip install -U neovim # --break-system-packages
  fi

  if [[ $OSTYPE == *"android"* ]]; then
    curl -o "${HOME}/.local/bin/install-in-mason" "https://raw.githubusercontent.com/Amirulmuuminin/setup-mason-for-termux/main/install-in-mason"
    chmod +x "${HOME}/.local/bin/install-in-mason"
    termux-fix-shebang "${HOME}"/.local/share/nvim/mason/bin/*
  fi

  mkdir -p "${HOME}/.vim/config/"
  mkdir -p "${HOME}/.vim/ftdetect/"
  mkdir -p "${HOME}/.vim/ftplugin/"
  mkdir -p "${HOME}/.vim/autoload/"
  mkdir -p "${HOME}/.vim/bundle/"
  mkdir -p "${HOME}/.config/nvim/"

  cd "${INSTALLDIR}" || exit

  cp files/vim/vimrc "${HOME}/.vimrc"
  cp files/vim/vimrc.local "${HOME}/.vimrc.local"
  cp files/vim/coc-settings.json "${HOME}/.vim/"
  cp -r files/vim/config/* "${HOME}/.vim/config/"
  cp -r files/vim/ft* "${HOME}/.vim/"

  cp files/config/nvim/init.lua "${HOME}/.config/nvim/"

  # Using vim-plug
  if [[ "${NVIM_FLAVOUR}" == "coc" ]]; then
    cp files/vim/init.lua "${HOME}/.config/nvim/"
    if [ ! -s ~/.config/nvim/coc-settings.json ]; then
      ln -s "${HOME}"/.vim/autoload/ "${HOME}/.config/nvim/autoload"
      ln -s "${HOME}"/.vim/ftdetect/ "${HOME}/.config/nvim/ftdetect"
      ln -s "${HOME}"/.vim/ftplugin/ "${HOME}/.config/nvim/ftplugin"
      ln -s "${HOME}"/.vim/coc-settings.json "${HOME}/.config/nvim/coc-settings.json"
    fi
    if [ ! -f ~/.vim/autoload/plug.vim ]; then
      curl -sLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    vim +PlugInstall +qall
    nvim +PlugInstall +qall
    # nvim +'TSInstall all' +qall
  fi

  # Install lazyman
  git_clone_or_update https://github.com/doctorfree/nvim-lazyman "${HOME}/.config/nvim-Lazyman"
  # ${HOME}/.config/nvim-Lazyman/lazyman.sh
}

installKakPlugins() {
  mkdir -p "${HOME}/.config/kak/plugins/"
  mkdir -p "${HOME}/.config/kak-lsp/"

  git_clone_or_update https://github.com/andreyorst/plug.kak.git "${HOME}/.config/kak/plugins/plug.kak"

  cd "${INSTALLDIR}" || exit

  cp files/kak/kakrc "${HOME}/.config/kak/kakrc"
  cp files/kak/*.kak "${HOME}/.config/kak/"
  cp -r files/kak/snippets "${HOME}/.config/kak/"
  cp files/kak/kak-lsp.toml "${HOME}/.config/kak-lsp/kak-lsp.toml"

  if [[ $OSTYPE == "darwin"* ]]; then
    if [ ! -s "${HOME}/Library/Preferences/kak-lsp" ]; then
      ln -s "${HOME}/.config/kak-lsp" "${HOME}/Library/Preferences/kak-lsp"
    fi
  fi

}

installGitConf() {
  source config.sh
  #read -p "Please enter your name (for gitconfig):" NAME
  #read -p "Please enter your email address (for gitconfig):" EMAIL

  # cp files/git/gitconfig ${HOME}/.gitconfig
  sedcmd=''
  for var in NAME EMAIL; do
    printf -v sc 's|${%s}|%s|;' ${var} "${!var//\//\\/}"
    sedcmd+="${sc}"
  done
  cat files/git/gitconfig | sed -e "${sedcmd}" >"${HOME}/.gitconfig"
  cp files/git/gitexcludes "${HOME}/.gitexcludes"
  if [ -x "$(command -v gh)" ]; then
    installGhExtensions
  fi
}

installShellConf() {
  cp files/shell/variables "${HOME}/.variables"
  cp files/shell/profile "${HOME}/.profile"
  cp -r files/shell/aliases.d/* "${HOME}/.aliases.d"
  #cp files/shell/aliases ${HOME}/.aliases

  if [ -z "${SHELLVARS}" ]; then
    SHELLVARS=$(comm -3 <(compgen -v | sort) <(compgen -e | sort) | grep -v '^_')
    source config.sh
    CONF=$(comm -3 <(compgen -v | sort) <(compgen -e | sort) | grep -v '^_')
    CONF=$(comm -3 <(echo "${CONF}" | tr ' ' '\n' | sort -u) <(echo "${SHELLVARS}" | tr ' ' '\n' | sort -u) | grep -v 'SHELLVARS')
  fi

  sedcmd=''
  for var in $(echo "${CONF}"); do
    printf -v sc 's|${%s}|%s|;' "${var}" "${!var//\//\\/}"
    sedcmd+="${sc}"
  done
  cat files/shell/aliases | sed -e "${sedcmd}" >"${HOME}"/.aliases

  git_clone_or_update https://github.com/ahmetb/kubectl-aliases.git "${HOME}/.kubectl_aliases"
  git_clone_or_update https://github.com/zer0beat/terraform-aliases.git "${HOME}/.terraform_aliases"

  # installFishConf
  installBashConf
  installZshConf
  installTmuxConf
  installGitConf

  source "${HOME}/.profile"
}

installBashConf() {
  mkdir -p "${HOME}"/.bash/

  cd "${INSTALLDIR}" || exit

  cp files/shell/bash/git_prompt.sh "${HOME}/.bash/"
  cp files/shell/bash/git-prompt-colors.sh "${HOME}/.git-prompt-colors.sh"
  cp files/shell/bash/shell_prompt.sh "${HOME}/.bash/"
  cp files/shell/bash/bashrc "${HOME}/.bashrc"
  cp files/shell/bash/bash_profile "${HOME}/.bash_profile"

  git_clone_or_update https://github.com/cykerway/complete-alias.git "${HOME}/.bash/complete-alias"
  git_clone_or_update https://github.com/magicmonty/bash-git-prompt.git "${HOME}/.bash/bash-git-prompt"
  git_clone_or_update https://github.com/jonmosco/kube-ps1.git "${HOME}/.bash/kube-ps1"
  git_clone_or_update https://github.com/milkbikis/powerline-shell "${HOME}/.bash/powerline-shell"

  source "${HOME}/.bash_profile"
}

installFishConf() {
  if [[ $OSTYPE != "darwin"* ]]; then
    sudo apt-add-repository ppa:fish-shell/release-2
    sudo apt-get update
    sudo apt-get install fish
  else
    brew install fish
  fi
  curl -sfL https://git.io/fundle-install | fish
  curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs git.io/fisher
  curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
  fisher add fzf edc/bass omf/thefuck omf/wttr omf/vundle ansible-completion docker-completion
  fisher add teapot

  installPkgList "omf install" files/pkgs/omf.lst
}

installZshConf() {
  ZSH=${ZSH:-${HOME}/.oh-my-zsh}
  ZSH_CUSTOM=${ZSH_CUSTOM:-${ZSH}/custom}

  echo ">>> oh-my-zsh"
  if [ ! -d "${HOME}"/.oh-my-zsh ]; then
    curl fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
  else
    cd "${HOME}"/.oh-my-zsh || exit
    git pull
    cd "${INSTALLDIR}" || exit
  fi

  git_clone_or_update https://github.com/denysdovhan/spaceship-prompt.git "${ZSH_CUSTOM}/themes/spaceship-prompt"
  if [ ! -s "${ZSH_CUSTOM}/themes/spaceship.zsh-theme" ]; then
    ln -s "${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM}/themes/spaceship.zsh-theme"
  fi
  git_clone_or_update https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
  git_clone_or_update https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  git_clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  git_clone_or_update https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM}/plugins/zsh-completions"
  git_clone_or_update https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM}/plugins/zsh-history-substring-search"
  git_clone_or_update https://github.com/hlissner/zsh-autopair.git "${ZSH_CUSTOM}/plugins/zsh-autopair"
  git_clone_or_update https://github.com/Aloxaf/fzf-tab.git "${ZSH_CUSTOM}/plugins/fzf-tab"
  git_clone_or_update https://github.com/tom-doerr/zsh_codex.git "${ZSH_CUSTOM}/plugins/zsh_codex"

  cp files/shell/zsh/zshrc "${HOME}/.zshrc"
  cp files/shell/zsh/zshHighlightStyle "${HOME}/.zshrcHighlightStyle"
  cp files/shell/zsh/p10k.zsh "${HOME}/.p10k.zsh"
}

createSkeleton() {
  dirs=$(cat config.sh | awk -F\' '{print $2}' | grep 'HOME')
  for d in $(envsubst <<<"${dirs}"); do
    mkdir -p "${d}"
  done

  for dir in $(ls -1d files/config/*/); do mkdir -p "${HOME}/.config/${dir##*/}"; done

  [ -d "${HOME}/workingCopies/code" ] || ln -s "${HOME}/workingCopies/src" "${HOME}/workingCopies/code"

  mkdir -p "${HOME}/.local/bin/"
  mkdir -p "${HOME}/.local/share/bash-completion"
  [ -d "${HOME}"/.bin ] || ln -s "${HOME}/.local/bin" "${HOME}/.bin"

  mkdir -p "${HOME}/.aliases.d"
  mkdir -p "${HOME}/.ptpython"
  mkdir -p "${HOME}/.atom"
  mkdir -p "${HOME}/.kube/config.d"
}

instrallRangerPlugins() {
  rm -f "${HOME}/.config/ranger/"*.{sh,py}
  ranger --copy-config=all
  mkdir -p "${HOME}/.ranger_plugins/"
  git_clone_or_update https://github.com/alexanderjeurissen/ranger_devicons.git "${HOME}/.ranger_plugins/ranger_devicons"
}

installDotFiles() {
  createSkeleton
  installShellConf
  installScripts

  # Set alacritty themes with:
  # alacritty-colorscheme -C ~/.alacritty-theme/themes -a tomorrow_night_bright.yaml -V
  # a matching vim theme will also be created in ~/.vimrc_background
  git_clone_or_update https://github.com/eendroroy/alacritty-theme.git "${HOME}/.alacritty-theme"

  # kitty themes
  git_clone_or_update https://github.com/dexpota/kitty-themes.git "${HOME}/.kitty-themes"
  git_clone_or_update git@github.com:lemnos/theme.sh.git "${HOME}/.theme.sh"

  for dir in $(ls -1d files/config/*/); do
    cp -r files/config/"${dir##*/}"/* "${HOME}/.config/${dir##*/}/"
  done

  cp files/asdfrc "${HOME}/.asdfrc"
  cp files/config/kubie.yaml "${HOME}/.kube/kubie.yaml"
  cp files/config/starship.toml "${HOME}/.config/starship.toml"
  cp files/shell/screenrc "${HOME}/.screenrc"
  cp files/atom/* "${HOME}/.atom/"
  cp files/ptpython.py "${HOME}/.ptpython/config.py"
  cp files/pipecolor.toml "${HOME}/.pipecolor.toml"

  installOSSpecific dotfiles

  installVscodeConfig
  installVimPlugins
  installHelix
  instrallRangerPlugins

  if [ -x "$(command -v bat)" ]; then
    mkdir -p "${HOME}/.config/bat/themes"
    git_clone_or_update https://github.com/theymaybecoders/sublime-tomorrow-theme.git "${HOME}/.config/bat/themes/sublime-tomorrow-theme"
    git_clone_or_update https://github.com/enkia/enki-theme.git "${HOME}/.config/bat/themes/enki-theme"
    bat cache --build
  fi

  if [ -x "$(command -v mdatp)" ]; then
    for F in $(cat files/mdatp.lst | envsubst); do mdatp exclusion folder add --path "${F}"; done
  fi
}

installWebApps() {
  npm install -g nativefier
  nativefier --name 'Whatsapp Web' 'https://web.whatsapp.com/'
  nativefier --name 'Evernote Web' 'https://www.evernote.com/Home.action?login=true&prompt=none&authuser=0#n=66f8e46f-8a98-4294-b42f-8abf8cb9774a&s=s14&ses=4&sh=2&sds=5&'
}

installPackages() {
  installGems
  installPips
  installNpms
  installGoPkgs
  installCargo
  installChefGems
  installChefVM
  installVagrantPlugins
  # installAtomPackages
  installVscodePackages
  installGoss
  installEls
  installFromRawGithub 'mattolenik/hclq'
}

installOSSpecific() {
  if [[ $OSTYPE == "darwin"* ]]; then
    ./osx.sh "${@}"
  elif [[ $OSTYPE == *"android"* ]]; then
    ./android.sh "${@}"
  else
    ./linux.sh "${@}"
  fi
}

installAll() {
  if [[ $OSTYPE != *"android"* ]]; then
    installPackages
  fi
  # installWebApps
  installDotFiles
}

if isFunction "${CMD}"; then
  $CMD "${ARGS[@]}"
  exit $?
elif isFunction "install${CMD}"; then
  "install${CMD}" "${ARGS[@]}"
  exit $?
fi

case "$CMD" in
"gems" | "gem")
  installGems
  ;;
"chef_gems" | "chefgems")
  installChefGems
  ;;
"pip" | "pips")
  installPips
  ;;
"npm" | "npms")
  installNpms
  ;;
"go" | "gopkgs")
  installGoPkgs
  ;;
"dotfiles")
  installDotFiles
  installOSSpecific "dotfiles"
  ;;
"scripts")
  installScripts
  ;;
"vimplugins" | "vim")
  installVimPlugins
  ;;
"KakPlugins" | "kak")
  installKakPlugins
  ;;
"atompackages" | "apkgs" | "atom" | "apm")
  installAtomPackages
  ;;
"vscodepackages" | "vscode" | "vspkgs")
  installVscodePackages
  ;;
"vagrant" | "VagrantPlugins")
  installVagrantPlugins
  ;;
"helm" | "helmplugins")
  installHelmPlugins
  ;;
*)
  installOSSpecific "${CMD}" "${ARGS[@]}"
  if [[ -z "${CMD}" || ${CMD} == "all" ]]; then
    installAll
  fi
  ;;
esac
