# HAProxy Setup Script

This README provides detailed instructions for the setup and use of the HAProxy installation script on Linux systems. The script automates the installation of HAProxy, creates a directory structure for configuration files, and sets up a systemd service to manage HAProxy configuration updates.

## Prerequisites

You need a Linux system with root access. Ensure that either `apt-get` or `yum` is available, as the script supports Debian/Ubuntu and CentOS/Red Hat.

## Installation and Setup

### Save the Script

1. Copy the script into a file named `setup-haproxy.sh` on your Linux server.

### Make the Script Executable

2. Change the script's permissions to make it executable:
    ```bash
    chmod +x setup-haproxy.sh
    ```

### Run the Script

3. Execute the script with root privileges using `sudo`:
    ```bash
    sudo ./setup-haproxy.sh
    ```

This script performs several actions:
- **Installs HAProxy**: Detects the package manager and installs HAProxy.
- **Creates Directories**: Sets up directories under `/etc/haproxy/` for base configurations, frontends, and backends.
- **Sets Up a Systemd Service**: Creates a systemd service that updates the HAProxy configuration by combining files from the directories mentioned above into the main `haproxy.cfg`. This service does not run periodically by itself but can be triggered manually or by other system events.

## Directory Structure

The script creates the following directory structure:

```
/etc/haproxy/
├── base/
├── frontends/
└── backends/
```

- `/base/`: Place your base HAProxy configuration here.
- `/frontends/`: Place frontend-specific configurations here.
- `/backends/`: Place backend-specific configurations here.

## Systemd Service

The systemd service created by the script is named `update-haproxy.service`. To manually trigger the configuration update and HAProxy restart, use:
```bash
sudo systemctl start update-haproxy.service
```

### Customizing the Script

The script is designed for generic use but might require adjustments based on specific requirements:

- Linux Distribution Specifics: Adjust the package installation commands based on your Linux distribution.
- HAProxy Version: Ensure compatibility with specific HAProxy versions.
- Configuration Requirements: Modify directory paths or configuration parameters according to your setup needs.

```Feel free to modify the script to suit your environment.```

### How to Use This README

To effectively use this README.md:

1. **Create the README.md File**: Open a text editor, paste the content above, and save it as `README.md` in the same directory as your script.
2. **Include in Version Control**: Add the `README.md` to your version control system to ensure it accompanies the script in your repository. This helps other users with detailed instructions and a clear understanding of how to utilize the script properly.
