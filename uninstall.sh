#!/usr/bin/env bash

set -e

BASE_DIR="$(dirname "$0")"
SCRIPTS_DIR="${BASE_DIR}/scripts"

echo "Sourcing all scripts from ${SCRIPTS_DIR}..."
for script in "${SCRIPTS_DIR}"/*.sh; do
    [ -f "$script" ] && echo "Loading $(basename "$script")..." && source "$script"
done
echo "All scripts loaded."

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

echo "Detected distribution: $ID"

# ---------------- FUNCTIONS ---------------- #


main() {
    stop_and_disable_services
    remove_docker_packages "$ID"
    remove_docker_data
    echo "✅ Docker has been uninstalled successfully."

    activate_DNSStubListener
    echo "✅ DNSStubListener restore default complete!"
}

# ---------------- EXECUTION ---------------- #

main