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

user_prompt() {
    local prompt="${1}"
    local var_name="${2}"

    # shellcheck disable=SC2229
    read -r -p "${prompt}" "${var_name}"
}

secret_prompt() {
    local prompt="${1}"
    local var_name="${2}"

    # shellcheck disable=SC2229
    read -r -s -p "${prompt}" "${var_name}"
    echo

    if [ "${!var_name}" == "" ]; then
        panic "Nothing was entered!"
    fi
}

dump_as_root() {
    local file_path="${1}"
    sudo dd "of=${file_path}" status=none

    # Just in case root's umask isn't correct
    sudo chmod go-rwx "${file_path}"
}

append_as_root() {
    local file_path="${1}"
    sudo tee --append "${file_path}" > /dev/null
}
