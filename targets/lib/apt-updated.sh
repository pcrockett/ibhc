#!/usr/bin/env bash

# If you have multiple "install" targets, set this target as a dependency for them all. That way, `apt-get update` will
# only execute one time even though you're installing multiple packages individually.

# shellcheck disable=2034
dependencies=()

apply() {
    sudo apt-get update
}
