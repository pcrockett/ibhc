#!/usr/bin/env bash

flatpak_is_installed() {
    flatpak info "${1}" &> /dev/null
}

flathub_install() {
    flatpak install --assumeyes --noninteractive --app "${1}" flathub
}
