#!/bin/sh -e

GH_RAW_URL=https://raw.githubusercontent.com
INSTALL_SCRIPT=install.sh
INSTALL_URL="${GH_RAW_URL}/Homebrew/install/HEAD/${INSTALL_SCRIPT}"

# Signal to the Homebrew installer that we can run as root
touch /.dockerenv

tmp_dir="$(mktemp -d)"
clean() { rm -rf "${tmp_dir}"; }
trap clean EXIT

cd "${tmp_dir}"
wget -q "${INSTALL_URL}" -O "${INSTALL_SCRIPT}"
chmod 755 "${INSTALL_SCRIPT}"
NONINTERACTIVE=false "./${INSTALL_SCRIPT}"

brew install \
    direnv \
    gcc \
    gh \
    git \
    ltex-ls \
    shfmt \
    vale
