#!/bin/sh -e

HOMEBREW='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'

# Signal to the Homebrew installer that we can run as root
touch /.dockerenv

set +x
/bin/bash -c "$(curl -fsSL ${HOMEBREW})"
set -x

brew install \
    direnv \
    gcc \
    gh \
    git \
    ltex-ls \
    shfmt \
    vale
