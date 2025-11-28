docker_installation() {
    local OS_ID=$1
    case "$OS_ID" in
        ubuntu | debian)
            echo "Installing Docker for Debian/Ubuntu..."
            install_package

            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL "https://download.docker.com/linux/${OS_ID}/gpg" |
                gpg --dearmor -o /etc/apt/keyrings/docker.gpg

            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/${OS_ID} \
$(lsb_release -cs) stable" |
                tee /etc/apt/sources.list.d/docker.list > /dev/null
                apt-get update -y
                apt-get install -y docker-ce docker-ce-cli containerd.io \
                    docker-buildx-plugin docker-compose-plugin
            ;;
        *)
            echo "Your OS (${OS_ID}) is not supported by this script."
            exit 1
            ;;
    esac
}

remove_docker_packages() {
    local OS_ID=$1
    wait_for_apt_lock
    case "$OS_ID" in
        ubuntu | debian)
            echo "Removing Docker packages for Debian/Ubuntu..."
            apt-get purge -y docker-ce docker-ce-cli containerd.io \
                docker-buildx-plugin docker-compose-plugin
            apt-get autoremove -y --purge
            ;;
        fedora | centos | rhel)
            echo "Removing Docker packages for Fedora/CentOS/RHEL..."
            dnf remove -y docker-ce docker-ce-cli containerd.io \
                docker-buildx-plugin docker-compose-plugin || true
            ;;
        *)
            echo "Your OS ($OS_ID) is not supported by this script."
            exit 1
            ;;
    esac
}

stop_and_disable_services() {
    echo "Stopping Docker services..."
    systemctl disable --now docker || true
    systemctl disable --now containerd || true
}

remove_docker_data() {
    echo "Removing Docker data directories (WARNING: this deletes containers, images, and volumes)"
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -rf /etc/apt/keyrings/docker.gpg
}
wait_for_apt_lock() {
    echo "Checking for active apt/dpkg locks..."
    while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 ||
          sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1 ||
          sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "🔒 Another package manager is running. Waiting 5 seconds..."
        sleep 5
    done
    echo "✅ No locks detected. Continuing..."
}