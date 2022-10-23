#!/usr/bin/env bash

# Debian- and Ubuntu-specific tools

apt_install() {
    sudo apt-get install --yes "${@}"
}
