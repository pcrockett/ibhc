#!/usr/bin/env bash

# Systemd-related tools

service_exists() {
    local service_name="${1}"
    systemctl list-unit-files --full --type=service | grep --fixed-strings "${service_name}.service" &> /dev/null
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
