#!/bin/bash
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


# Ensure the Ids file exists
if [ ! -f "Ids" ]; then
    echo "Error: File 'Ids' not found."
    exit 1
fi

# Loop through each ID in the file
while IFS= read -r i; do
    # Get network information
    network_info=$(openstack network show "$i" 2>/dev/null)

    # Check if there was an error getting network information
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve information for network with ID $i"
        continue
    fi

    # Extract port_security_enabled and network name
    port_security_enable=$(echo "$network_info" | awk -F "|" '/port_security_enabled/ {print $3}' | tr -d '[:space:]')
    network_name=$(echo "$network_info" | awk -F "|" '/name/ {print $3}' | tr -d '[:space:]')

    # Check port_security status
    case $port_security_enable in
        "True" )
            echo "On network: $network_name (ID: $i), port_security is enabled."
            ;;
        "False" )
            echo "On network: $network_name (ID: $i), port_security is disabled."
            echo "Network: $network_name (ID: $i)" >> disabled.txt
            ;;
        * )
            echo "Error: Network with ID $i does not exist or information couldn't be retrieved."
            ;;
    esac
done < "Ids"