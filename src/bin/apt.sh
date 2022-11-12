#!/bin/sh -e

notify() {
    message="${1}"
    printf '\n\e[1m%s\e[0m\n\n' "${message}"
}

# Execute in a subshell so we can filter the output
(
    DEBIAN_FRONTEND=noninteractive
    export DEBIAN_FRONTEND

    APT_GET_INSTALL='apt-get install -y --no-install-recommends'

    notify "Updating package list..."
    apt-get update

    notify "Upgrading packages..."
    apt-get upgrade -y

    # Replace the functionality of the default `unminimize` script (which seems
    # to break for the `doc` and `locale` directories)
    unminimize() {
        dirname="${1}"
        notify "Unminmizing packages from: ${dirname}"
        dpkg -S "${dirname}" |
            sed 's|, |\n|g;s|: [^:]*$||' |
            uniq |
            xargs ${APT_GET_INSTALL} --reinstall
    }

    unminimize /usr/share/man/
    unminimize /usr/share/doc/
    unminimize /usr/share/locale/

    rm -f /usr/bin/man
    ${APT_GET_INSTALL} --reinstall man

    notify "Installing additional packages..."
    ${APT_GET_INSTALL} build-essential
) 2>&1 |
    grep -vE '^\(Reading database'
