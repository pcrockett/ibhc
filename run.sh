#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(dirname "$(readlink -f "${0}")")"
readonly REPO_DIR
readonly STATE_DIR="${REPO_DIR}/.state"
readonly TARGET_STATE_DIR="${STATE_DIR}/targets"
# shellcheck disable=2034
readonly REPO_CONFIG_DIR="${REPO_DIR}/config"
readonly VERBOSE=${VERBOSE:-false}

log_verbose() {
    if [ "${VERBOSE}" == "true" ]; then
        echo "${*}"
    fi
}

# get array of scripts in the `lib.d` directory IN SORT ORDER:
readarray -d '' lib_scripts_sorted < <(
    find "${REPO_DIR}/lib.d" -maxdepth 1 -mindepth 1 -type f -name "*.sh" -print0 \
        | sort --zero-terminated
)

# Allow scripts to assume their current directory is the repo directory
pushd "${REPO_DIR}" &> /dev/null

on_exit() {
    popd &> /dev/null
}
trap 'on_exit' EXIT

if [ "${DO_NOT_RUN:-}" != "" ]; then
    echo "DO_NOT_RUN env variable is set. Aborting."
    exit 1
fi

for script_path in "${lib_scripts_sorted[@]}"
do
    # shellcheck disable=1090
    source "${script_path}"
done

__fail_target() {
    local target_name="${1}"
    local exit_code="${2}"
    echo "${target_name} [FAIL] (${exit_code})"
    exit "${exit_code}"
}

__run_target() {
    local name="${1}"
    if [ -f "${TARGET_STATE_DIR}/${name}" ]; then
        return 0 # Already ran this target
    fi

    # Define path constant that can be used in targets
    local THIS_TARGET_PATH="${REPO_DIR}/targets/${name}.sh"
    readonly THIS_TARGET_PATH
    if [ ! -f "${THIS_TARGET_PATH}" ]; then
        echo "Unrecognized target: ${name}"
        return 1
    fi

    local target_marker_file="${TARGET_STATE_DIR}/${name}"
    # Targets may have a "/" in their name, so we might need to create an extra subdirectory for those:
    mkdir --parent "$(dirname "${target_marker_file}")"
    touch "${target_marker_file}"

    unset -f dependencies
    unset -f reached_if
    unset -f apply

    # shellcheck disable=1090
    source "${THIS_TARGET_PATH}"

    if command -v reached_if &> /dev/null; then
        # Intentionally running in subshell:
        if (set -Eeuo pipefail; reached_if &> /dev/null); then
            log_verbose "${name} [already satisfied]"
            return 0
        fi
    fi
    echo "${name} [running...]"

    # shellcheck disable=2154
    for dep in "${dependencies[@]}"
    do
        (
            set -Eeuo pipefail
            __run_target "${dep}"
        )
    done

    if command -v apply &> /dev/null; then
        (
            set -Eeuo pipefail
            trap '__fail_target "${name}" ${?}' ERR
            apply
        )
    fi

    echo "${name} [done]"
}

rm --recursive --force "${TARGET_STATE_DIR}"

targets_to_run=("${@}")
if [ "${#targets_to_run[@]}" -eq 0 ]; then
    targets_to_run=(default)
fi

for target in "${targets_to_run[@]}"
do
    (
        # Running in a subshell is important because __run_target will source
        # the target right away.
        set -Eeuo pipefail
        __run_target "${target}"
    )
done
