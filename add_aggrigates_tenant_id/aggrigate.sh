#!/bin/bash

export OS_AUTH_URL=http://public.cloud.damavand.cloud:5000
export OS_PROJECT_ID=a89bce63c357400ba7e40ce45e462ab4
export OS_PROJECT_NAME="admin"
export OS_USER_DOMAIN_NAME="Default"
export OS_PROJECT_DOMAIN_ID="default"
export OS_USERNAME="admin"
export OS_PASSWORD="?"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3



agg_id=$(openstack aggregate create --zone nova $1 | grep -w id | cut -d "|" -f 3 | sed 's/ //g')
openstack project list | cut -d "|" -f 2,3  | sed '$d' | sed '1,3d'| sed 's/ //g' > projects
openstack host list |grep compute |cut -d "|" -f 2 | sed 's/ //g' > hosts
for i in $(cat projects)
do
    echo $i -----
    projetc_name=`echo $i | cut -d "|" -f 2 | sed 's/ //g'`
    project_id=`echo $i | cut -d "|" -f 1 | sed 's/ //g'`
    randnumber=$((10000 + RANDOM % 100))
    openstack aggregate set --zone nova --property filter_tenant_id$randnumber=$project_id $agg_id
done

for host_name in $(cat hosts)
do
    echo $host_name ++++
    openstack aggregate add host $agg_id $host_name
done