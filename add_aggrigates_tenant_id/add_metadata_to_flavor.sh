#!/bin/bash

# OpenStack credentials and environment setup
export OS_AUTH_URL="?"
export OS_PROJECT_ID="?"
export OS_PROJECT_NAME="?"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_ID="default"
export OS_USERNAME="?"
export OS_PASSWORD="?"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

# File containing the flavor IDs
FLAVOR_ID_FILE="flavorID"
LOG_FILE="log"

# Metadata to add
key="aggregate_instance_extra_specs:Ratio_8"
value="true"

# Function to add metadata to a flavor
add_flavor_metadata() {
    local flavor_id=$1
    local key=$2
    local value=$3

    # Add metadata and log the action
    if openstack flavor set --property $key=$value $flavor_id; then
        echo "$flavor_id $key=$value" >> "$LOG_FILE"
        echo "Metadata added successfully to flavor $flavor_id."
    else
        echo "Failed to add metadata to flavor $flavor_id."
    fi
}

# Main loop to update flavors from file
while IFS= read -r flavor_id; do
    add_flavor_metadata $flavor_id $key $value
done < "$FLAVOR_ID_FILE"