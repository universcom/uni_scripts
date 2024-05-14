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
    sudo mkdir -p /etc/haproxy/base /etc/haproxy/frontends /etc/haproxy/backends /etc/haproxy/errors
}

# Step 3: Setup Base Configuration for HAProxy
setup_base_config() {
    echo "Setting up base HAProxy configuration..."
    local base_config_path="/etc/haproxy/base/haproxy.cfg.base"
    sudo bash -c "cat > $base_config_path" << 'EOF'
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Secure SSL ciphers
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
EOF
}

# Step 4: Setup Service to Update HAProxy Configuration
setup_service() {
    echo "Setting up update service..."
    local service_path="/etc/systemd/system/update-haproxy.service"
    sudo bash -c "cat > $service_path" << 'EOF'
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
    sudo bash -c "cat > $script_path" << 'EOF'
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
setup_base_config
setup_service

echo "Installation and setup completed successfully!"