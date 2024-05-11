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

# Create an aggregate and extract its ID
agg_id=$(openstack aggregate create --zone nova $1 | grep -w id | cut -d "|" -f 3 | sed 's/ //g')

# Export project and host lists
openstack project list | cut -d "|" -f 2,3 | sed '$d' | sed '1,3d' | sed 's/ //g' > projects
openstack host list | grep compute | cut -d "|" -f 2 | sed 's/ //g' > hosts

# Initialize a file to track used random numbers
rand_file="used_random_numbers.txt"
touch $rand_file

for i in $(cat projects)
do
    echo $i -----
    project_name=$(echo $i | cut -d "|" -f 2 | sed 's/ //g')
    project_id=$(echo $i | cut -d "|" -f 1 | sed 's/ //g')

    # Generate a unique random number
    while true; do
        randnumber=$(shuf -i 10000-99999 -n 1)
        if ! grep -q $randnumber $rand_file; then
            echo $randnumber >> $rand_file
            break
        fi
    done

    # Set the aggregate property using the unique random number
    openstack aggregate set --zone nova --property filter_tenant_id$randnumber=$project_id $agg_id
done

# Add each host to the aggregate
for host_name in $(cat hosts)
do
    echo $host_name ++++
    openstack aggregate add host $agg_id $host_name
done