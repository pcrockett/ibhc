#!/usr/bin/env bash

# Simple pretty-printing functions

log_info() {
    echo "${@}"
}

log_success() {
    local message="${1}"
    local green="\033[32;1m"
    local reset_color="\033[0m"
    echo -e -n "${green}"
    echo "${message}"
    echo -e -n "${reset_color}"
}

log_error() {
    local message="${1}"
    local red="\033[91;1m"
    local reset_color="\033[0m"
    echo -e -n "${red}"
    echo "ERROR: ${message}"
    echo -e -n "${reset_color}"
}
