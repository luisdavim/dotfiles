#!/usr/bin/env -S bash -xeuo pipefail

set -xeuo pipefail

pkg install patchelf which time ldd tree

pkg -y glibc-runner --assume-installed bash,patchelf,resolv-conf

grun --help

curl -fsSL https://deno.land/install.sh | time sh

curl -fsSL https://bun.sh/install | time bash

INSTALL_PATH="${HOME}/.local"
export DENO_INSTALL="${INSTALL_PATH}/.deno"
export BUN_INSTALL="${INSTALL_PATH}/.bun"
export PATH="${PATH}:${DENO_INSTALL}/bin:${BUN_INSTALL}/bin"

patchelf --print-interpreter --print-needed "$(which deno)"

patchelf --print-interpreter --print-needed "$(which bun)"

patchelf --set-rpath "${PREFIX}/glibc/lib" --set-interpreter "${PREFIX}/glibc/lib/ld-linux-aarch64.so.1" "$(which deno)"

patchelf --set-rpath "${PREFIX}/glibc/lib" --set-interpreter "${PREFIX}/glibc/lib/ld-linux-aarch64.so.1" "$(which bun)"

ldd "$(which deno)"

ldd "$(which bun)"

for i in deno bun; do
  cat - << EOF > "${INSTALL_PATH}/.${i}/bin/${i}.glibc.sh"
#!/usr/bin/env sh

_oldpwd="\${PWD}"
_dir="\$(dirname "\${0}")"
cd "\${_dir}"

if ! [ -h "${i}" ] ; then
  >&2 mv -fv "${i}" "${i}.orig"
  >&2 ln -sfv "${i}.glibc.sh" "${i}"
fi
cd "\${_oldpwd}"
LD_PRELOAD= exec "\${_dir}/${i}.orig" "\${@}"
# Or
#exec grun "\${_dir}/${i}.orig" "\${@}"

EOF

  chmod -c u+x "${INSTALL_PATH}/.${i}/bin/${i}.glibc.sh"
done

deno.glibc.sh --version

bun.glibc.sh --version

tree -a "${DENO_INSTALL}/" "${BUN_INSTALL}/"

cat -n "${DENO_INSTALL}/bin/deno.glibc.sh"

cat -n "${BUN_INSTALL}/bin/bun.glibc.sh"

deno <<< "console.log('Hello world')"

file="$(mktemp -p ~/.cache --suffix .js hello-XXX)"

echo "console.log('Hello world')" > "${file}"

bun run "${file}"
