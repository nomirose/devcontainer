#!/bin/bash -e

# Set up APT for latest Node.js
curl -fsSL https://deb.nodesource.com/setup_19.x | bash -

# Set up APT for latest Yarn
YARN_KEY=/usr/share/keyrings/yarnkey.gpg
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg |
    gpg --dearmor |
    tee "${YARN_KEY}" >/dev/null
echo "deb [signed-by=${YARN_KEY}] https://dl.yarnpkg.com/debian stable main" |
    tee /etc/apt/sources.list.d/yarn.list
