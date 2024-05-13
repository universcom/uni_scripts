#!/bin/bash

# Step 1: Install HAProxy
install_haproxy() {
    echo "Installing HAProxy..."
    if command -v apt-get > /dev/null; then
        sudo apt-get update
        sudo apt-get install -y haproxy
    elif command -v yum > /dev/null; then
        sudo yum install -y haproxy
    else
        echo "Unsupported package manager. Install HAProxy manually."
        exit 1
    fi
}

# Step 2: Create Directory Structure
create_directories() {
    echo "Creating directory structure..."
    sudo mkdir -p /etc/haproxy/base /etc/haproxy/frontends /etc/haproxy/backends
}

# Step 3: Setup Service to Update HAProxy Configuration
setup_service() {
    echo "Setting up update service..."
    local service_path="/etc/systemd/system/update-haproxy.service"
    sudo bash -c "cat > $service_path" << EOF
[Unit]
Description=Update HAProxy Configuration Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-haproxy-config.sh

[Install]
WantedBy=multi-user.target
EOF

    # Create the script that the service will execute
    local script_path="/usr/local/bin/update-haproxy-config.sh"
    sudo bash -c "cat > $script_path" << EOF
#!/bin/bash
cat /etc/haproxy/base/haproxy.cfg.base /etc/haproxy/frontends/*.cfg /etc/haproxy/backends/*.cfg > /etc/haproxy/haproxy.cfg
systemctl reload haproxy
EOF

    # Make the script executable
    sudo chmod +x $script_path

    # Reload systemctl daemon to recognize new service
    sudo systemctl daemon-reload

    # Enable the service to run on boot
    sudo systemctl enable update-haproxy.service
}

# Main execution flow
install_haproxy
create_directories
setup_service

echo "Installation and setup completed successfully!"