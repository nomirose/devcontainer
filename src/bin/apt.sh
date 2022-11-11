#!/bin/sh -ex

DEBIAN_FRONTEND=noninteractive
export DEBIAN_FRONTEND

apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends build-essential
