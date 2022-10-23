#!/usr/bin/env bash

# Tools for detecting changes in files

get_hash() {
    IFS=" " read -r -a sha_sum_output <<< "$(sha256sum -)"
    # For an explanation of the above line, see
    #
    # https://github.com/koalaman/shellcheck/wiki/SC2207
    #
    # We only want the hash of the file without the filename, so we're
    # splitting output on space and taking the first word.
    #
    # In this case, the "file" is stdin (hence the "-").

    echo "${sha_sum_output[0]}"
}

get_file_hash() {
    local path="${1}"
    test -f "${path}" || return 0 # Return nothing
    get_hash < "${path}"
}

__ibhc_file_hashes_dir="${STATE_DIR}/file-hashes"
mkdir --parent "${__ibhc_file_hashes_dir}"

file_is_unchanged() {
    local path
    path="$(readlink -f "${1}")"

    test -f "${path}" || return 1 # Yup, it's dirty... it doesn't even exist.

    IFS=" " read -r -a path_hash <<< "$(echo "${path}" | sha256sum)"
    local state_file_path="${__ibhc_file_hashes_dir}/${path_hash[0]}"
    test -f "${state_file_path}" || return 1 # Nope, never computed its hash before

    local current_hash
    current_hash="$(cat "${state_file_path}")"

    local file_hash
    file_hash="$(get_file_hash "${path}")"
    test "${current_hash}" = "${file_hash}"
}

set_file_unchanged() {
    local path
    path="$(readlink -f "${1}")" # May not exist

    IFS=" " read -r -a path_hash <<< "$(echo "${path}" | sha256sum)"
    local state_file_path="${__ibhc_file_hashes_dir}/${path_hash[0]}"

    get_file_hash "${path}" > "${state_file_path}"
}

set_file_dirty() {
    local path
    path="$(readlink -f "${1}")" # May not exist

    IFS=" " read -r -a path_hash <<< "$(echo "${path}" | sha256sum)"
    local state_file_path="${__ibhc_file_hashes_dir}/${path_hash[0]}"
    rm --force "${state_file_path}"
}
