#!/usr/bin/env bash

# shellcheck disable=2034
dependencies=(
    direnv-installed
)

__direnv_eval_command="eval \"\$(direnv hook bash)\""

reached_if() {
    grep --line-regexp --fixed-strings "${__direnv_eval_command}" ~/.bashrc
}

apply() {
    echo "${__direnv_eval_command}" >> ~/.bashrc
}
