#!/bin/sh -ex

# Run after the devcontainer has successfully started
# =============================================================================

direnv allow .

yarn install

direnv exec . cspell link add @cspell/dict-git

direnv exec . trunk upgrade
direnv exec . trunk git-hooks sync
