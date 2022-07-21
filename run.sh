#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="$(dirname "$(readlink -f "${0}")")"
readonly REPO_DIR
readonly STATE_DIR="${REPO_DIR}/.state"
readonly TARGET_STATE_DIR="${STATE_DIR}/targets"

# get array of scripts in the `lib.d` directory IN SORT ORDER:
readarray -d '' lib_scripts_sorted < <(
    find "${REPO_DIR}/lib.d" -maxdepth 1 -mindepth 1 -type f -name "*.sh" -print0 \
        | sort --zero-terminated
)

for script_path in "${lib_scripts_sorted[@]}"
do
    # shellcheck disable=1090
    source "${script_path}"
done

__run_target() {
    local name="${1}"
    if [ -f "${TARGET_STATE_DIR}/${name}" ]; then
        return 0 # Already ran this target
    fi

    local path="${REPO_DIR}/targets/${name}.sh"
    if [ ! -f "${path}" ]; then
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
    source "${path}"

    if command -v reached_if &> /dev/null; then
        # Intentionally running in subshell:
        if (set -Eeuo pipefail; reached_if &> /dev/null); then
            echo "${name} [already satisfied]"
            return 0
        fi
    fi

    # shellcheck disable=2154
    for dep in "${dependencies[@]}"
    do
        (
            set -Eeuo pipefail
            __run_target "${dep}"
        )
    done

    if command -v apply &> /dev/null; then
        echo "Target ${name}..."
        # Intentionally running in subshell:
        if (set -Eeuo pipefail; apply); then
            echo "${name} [done]"
        else
            echo "${name} [FAIL] (${?})"
            return 1
        fi
    else
        echo "${name} [done]"
    fi

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
