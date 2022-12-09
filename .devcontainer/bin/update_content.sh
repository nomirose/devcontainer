#!/bin/sh -e

# If a Trunk configuration directory exists, upgrade Trunk (functionally
# initializing the tool for the first time in this workspace)
if test -d ./.trunk; then
    trunk upgrade
fi
