#!/bin/sh -ex

HOMEBREW='https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'

set +x
/bin/bash -c "$(curl -fsSL ${HOMEBREW})"
set -x
