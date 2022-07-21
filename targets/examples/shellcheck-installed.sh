#!/usr/bin/env bash

# shellcheck disable=2034
dependencies=(
    lib/apt-updated
)

reached_if() {
    command_is_installed shellcheck
}

apply() {
    apt_install shellcheck
}
