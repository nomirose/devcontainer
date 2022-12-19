#!/bin/sh -ex

tmp_dir="$(mktemp -d)"
clean() { rm -rf "${tmp_dir}"; }
trap clean EXIT

# Custom sources
# -----------------------------------------------------------------------------

cd "${tmp_dir}"

NODESOURCE_URL=https://deb.nodesource.com/setup_19.x
NODESOURCE_SCRIPT=nodesource_setup.sh

# Set up APT for latest Node.js
wget -q "${NODESOURCE_URL}" -O "${NODESOURCE_SCRIPT}"
chmod 755 "${NODESOURCE_SCRIPT}"
"./${NODESOURCE_SCRIPT}"

YARN_DEB_REPO=https://dl.yarnpkg.com/debian
YARN_PUBKEY_URL="${YARN_DEB_REPO}/pubkey.gpg"
YARN_PUBKEY=pubkey.gpg
YARN_KEY_PATH="/usr/share/keyrings/yarnkey.gpg"
YARN_LIST=/etc/apt/sources.list.d/yarn.list

# Set up APT for latest Yarn
wget -q "${YARN_PUBKEY_URL}" -O "${YARN_PUBKEY}"
rm -f "${YARN_KEY_PATH}"
gpg --dearmor --output "${YARN_KEY_PATH}" "${YARN_PUBKEY}"
cat >"${YARN_LIST}" <<EOF
deb [signed-by=${YARN_KEY_PATH}] ${YARN_DEB_REPO} stable main
EOF

# APT setup
# -----------------------------------------------------------------------------

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

apt-get -q update -y

apt-get -q upgrade -y

apt-get -q install -y --no-install-recommends \
    acl \
    build-essential \
    cronic \
    gcc \
    nodejs \
    yarn

rm -rf /var/lib/apt/lists/*
