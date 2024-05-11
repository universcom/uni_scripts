#!/bin/bash

# OpenStack credentials and environment setup
export OS_AUTH_URL="?"
export OS_PROJECT_ID=a"?"
export OS_PROJECT_NAME="?"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_ID="default"
export OS_USERNAME="?"
export OS_PASSWORD="?"
export OS_REGION_NAME="?"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

# Log file from the previous script
LOG_FILE="log"

# Function to remove metadata from a flavor
remove_flavor_metadata() {
    local flavor_id=$1
    local key=$2

    # Remove metadata and log the action
    if openstack flavor unset --property $key $flavor_id; then
        echo "Metadata $key removed successfully from flavor $flavor_id."
    else
        echo "Failed to remove metadata $key from flavor $flavor_id."
    fi
}

# Read the log file and remove metadata
while IFS= read -r line; do
    flavor_id=$(echo $line | awk '{print $1}')
    key=$(echo $line | cut -d '=' -f 1 | awk '{print $2}')

    remove_flavor_metadata $flavor_id $key
done < "$LOG_FILE"