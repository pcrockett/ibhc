#!/usr/bin/env bash

# Systemd-related tools

service_exists() {
    local service_name="${1}"
    systemctl list-unit-files --full --type=service | grep --fixed-strings "${service_name}.service" &> /dev/null
}

user_service_exists() {
    local service_name="${1}"
    systemctl list-unit-files --user --full --type=service | grep --fixed-strings "${service_name}.service" > /dev/null
}

service_enabled() {
    local service_name="${1}"
    service_exists "${service_name}" && test "$(systemctl is-enabled "${service_name}")" == "enabled"
}

service_active() {
    local service_name="${1}"
    service_exists "${service_name}" && test "$(systemctl is-active "${service_name}")" == "active"
}

service_enabled_and_active() {
    local service_name="${1}"
    service_exists "${service_name}" \
        && test "$(systemctl is-enabled "${service_name}")" == "enabled" \
        && test "$(systemctl is-active "${service_name}")" == "active"
}

start_or_restart() {
    local service_name="${1}"
    if service_active "${service_name}"; then
        sudo systemctl restart "${service_name}"
    else
        sudo systemctl enable --now "${service_name}"
    fi
}

stop_and_disable() {
    local service_name="${1}"
    sudo systemctl disable --now "${service_name}"
}
