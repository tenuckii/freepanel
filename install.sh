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

install_package() {
    case "$ID" in
        ubuntu | debian)
            apt-get update -y
            apt-get install -y ca-certificates curl gnupg lsb-release
            ;;
        *)
            echo "Your OS ($ID) is not supported by this script."
            exit 1
            ;;
    esac
}

main() {
    docker_installation "$ID"
    systemctl enable docker
    systemctl start docker
    echo "✅ Docker installation complete!"
    
    deactivate_DNSStubListener
    echo "✅ DNSStubListener deactivation complete!"

}

# ---------------- EXECUTION ---------------- #

main