# Use the latest Debian release
FROM mcr.microsoft.com/vscode/devcontainers/base:bullseye as base

ENV BREW_BIN='/home/linuxbrew/.linuxbrew/bin'
ENV SYS_PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
ENV PATH="${BREW_BIN}:${SYS_PATH}"

COPY . /tmp
WORKDIR /tmp
RUN /tmp/bin/node.sh
RUN /tmp/bin/apt.sh
RUN /tmp/bin/system.sh
RUN /tmp/bin/homebrew.sh
