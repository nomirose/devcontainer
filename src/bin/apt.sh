#!/bin/sh -ex

# ANSI colors
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

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

# Unminimize
# -----------------------------------------------------------------------------

# TODO: FIGURE OUT WHAT TO DO WITH THIS SECTION NOW WE HAVE MOVED TO A DEBIAN
# BASE IMAGE

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
# list_pkgs() {
#     dirname="${1}"
#     output_file="${2}"
#     dpkg -S "${dirname}" |
#         sed 's|, |\n|g;s|: [^:]*$||' >>"${output_file}"
# }

# Custom replacement for the stock `unmininize` command
# custom_umminmize() {
#     # Remove the temporary `man` script
#     BIN_PATH="/usr/bin/man"
#     rm -f "${BIN_PATH}"
#     # Move the real `man` binary back into place
#     mv "${BIN_PATH}.REAL" "${BIN_PATH}"
#     # re-install the `man` package
#     ${APT_GET_INSTALL} --reinstall man
#     # Run `dpkg` three times, once for each mininmized directory, and save the
#     # output in a temporary file
#     list_pkgs "/usr/share/man/" "${tmp_output}"
#     list_pkgs "/usr/share/doc/" "${tmp_output}"
#     list_pkgs "/usr/share/locale/" "${tmp_output}"
#     # Read in the temporary file, sort the contents, remove duplicates, and
#     # pass the package list to `apt-get`
#     # shellcheck disable=SC2086
#     sort --version-sort <"${tmp_output}" |
#         uniq |
#         xargs ${APT_GET_INSTALL} --reinstall
# }

# Execute in a subshell so we can filter the output
set_up_apt () {
    notify "Updating package lists..."
    apt-get update

    notify "Upgrading packages..."
    apt-get upgrade -y

    # notify "Unminimizing the system..."
    # custom_umminmize

    notify "Installing additional packages..."
    ${APT_GET_INSTALL} \
        build-essential \
        gcc \
        nodejs \
        yarn \
        cronic
}

# TODO: HANDLE PIPE FAILURES
set_up_apt 2>&1 | grep -vE '^\(Reading database'
