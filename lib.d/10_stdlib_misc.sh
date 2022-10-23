#!/usr/bin/env bash

command_is_installed() {
    local name="${1}"
    command -v "${name}" &> /dev/null
}

curl_download() {
    local url="${1}"
    curl --proto '=https' --tlsv1.2 \
        --silent \
        --show-error \
        --fail \
        --location "${url}"
}
