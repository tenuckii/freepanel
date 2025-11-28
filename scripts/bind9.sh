#!/bin/bash

CONF_FILE="/etc/systemd/resolved.conf"
BACKUP_FILE="/etc/systemd/resolved.conf.bak"

deactivate_DNSStubListener(){
    echo "Backing up ${CONF_FILE} to ${BACKUP_FILE}..."
    sudo cp "${CONF_FILE}" "${BACKUP_FILE}"

    echo "Updating DNSStubListener setting..."
    if grep -q "^#\?DNSStubListener=" "${CONF_FILE}"; then
        sudo sed -i 's/^#\?DNSStubListener=.*/DNSStubListener=no/' "${CONF_FILE}"
    else
        echo "DNSStubListener=no" | sudo tee -a "${CONF_FILE}" > /dev/null
    fi
    restart_service
}

activate_DNSStubListener(){
    echo "Restoring original from ${BACKUP_FILE} to ${CONF_FILE}..."
    sudo cp "${BACKUP_FILE}" "${CONF_FILE}"
    restart_service
}

restart_service(){
    echo "Restarting systemd-resolved service..."
    sudo systemctl restart systemd-resolved

    echo "Checking service status..."
    sudo systemctl status systemd-resolved --no-pager

    echo "Done. DNSStubListener has been changed."
}
