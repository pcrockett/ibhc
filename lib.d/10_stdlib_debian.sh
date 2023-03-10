#!/usr/bin/env bash

# Debian- and Ubuntu-specific tools

apt_install() {
    sudo apt-get install --yes "${@}"
}

package_is_installed() {
    local pkg_name="${1}"
    local desired_version="${2:-}"

    if [ "${desired_version}" == "" ]; then
        dpkg --status "${pkg_name}" &> /dev/null
    else
        dpkg --status "${pkg_name}" \
            | grep --line-regexp --fixed-strings "Version: ${desired_version}" &> /dev/null
    fi
}

install_deb() {
    local deb_file_path="${1}"
    sudo dpkg --install "${deb_file_path}"
}