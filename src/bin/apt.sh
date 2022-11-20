#!/bin/sh -e

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

# You will need to disable shellcheck SC2086 when using this variable becurse
# we rely on word splitting for it to function as a list of arguments
APT_GET_INSTALL='apt-get install -y --no-install-recommends'

notify() {
    message="${1}"
    # Print the message in bold with an empty newline on each side
    printf '\n\e[1m%s\e[0m\n\n' "${message}"
}

# We unminimize the system by hand because the stock `unminimize` command seems
# to be broken at the time of writing (2022-11-14). For more information, see:
# https://bugs.launchpad.net/cloud-images/+kbug/1996489

# Crate a temporary output file for `dpkg` that will be cleaned up when the
# script exits
tmp_output="$(mktemp)"
clean() { rm -rf "${tmp_output}"; }
trap clean EXIT

# NOTE: Unlike the stock `unminimize` command, the `custom_umminmize` function
# will reinstall the same packages every time you run it. We don't have any
# checks in place to prevent this this because we assume the script is going to
# be run once, during the image build.

# Print a list of installed packages that may claim to own files in the
# provided directory
list_pkgs() {
    dirname="${1}"
    output_file="${2}"
    dpkg -S "${dirname}" |
        sed 's|, |\n|g;s|: [^:]*$||' >>"${output_file}"
}

# Custom replacement for the stock `unmininize` command
custom_umminmize() {
    # Remove the temporary `man` script
    BIN_PATH="/usr/bin/man"
    rm -f "${BIN_PATH}"
    # Move the real `man` binary back into place
    mv "${BIN_PATH}.REAL" "${BIN_PATH}"
    # re-install the `man` package
    ${APT_GET_INSTALL} --reinstall man
    # Run `dpkg` three times, once for each mininmized directory, and save the
    # output in a temporary file
    list_pkgs "/usr/share/man/" "${tmp_output}"
    list_pkgs "/usr/share/doc/" "${tmp_output}"
    list_pkgs "/usr/share/locale/" "${tmp_output}"
    # Read in the temporary file, sort the contents, remove duplicates, and
    # pass the package list to `apt-get`
    # shellcheck disable=SC2086
    sort --version-sort <"${tmp_output}" |
        uniq |
        xargs ${APT_GET_INSTALL} --reinstall
}

gh_login() {
    if test -z "${GITHUB_TOKEN}"; then
        echo "ERROR: GITHUB_TOKEN must be set" >&2
        exit 1
    fi
    token="$(echo "${GITHUB_TOKEN}")"
    unset GITHUB_TOKEN
    # Authenticate the CLI tool with GitHub
    echo "${token}" | gh auth login --with-token
    gh auth status
}

# Depends the `gh` tool (installed later with apt-get)
# cspell:ignore docwhat
install_chronic() {
    notify "Installing chronic..."
    BIN_DIR="/usr/local/bin"
    CHRONIC_REPO="docwhat/chronic"
    CHRONIC_BIN="chronic_freebsd_amd64"
    # Download the latest release of the `chronic` program
    (
        cd /tmp
        gh release download -R "${CHRONIC_REPO}" -p "${CHRONIC_BIN}"
        gh release download -R "${CHRONIC_REPO}" -p 'checksums.txt'
        sha256sum -c --ignore-missing checksums.txt
        chmod 755 "${CHRONIC_BIN}"
        sudo mv -f "${CHRONIC_BIN}" "${BIN_DIR}"/chronic
    )
}

# Execute in a subshell so we can filter the output
(
    notify "Updating package lists..."
    apt-get update

    notify "Upgrading packages..."
    apt-get upgrade -y

    notify "Unminimizing the system..."
    custom_umminmize

    notify "Installing additional packages..."
    ${APT_GET_INSTALL} build-essential gcc gh

    gh_login
    install_chronic
) 2>&1 |
    grep -vE '^\(Reading database'
