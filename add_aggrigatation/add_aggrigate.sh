#!/bin/bash
declare -a projetc_info
projetc_info=(`openstack project list | cut -d "|" -f 2,3 | sed 's/ //g' | sed '$d' | sed '1,3d'`)
for i in "${projetc_info[@]}" 
do
  projetc_name=`echo $i | cut -d "|" -f 2 | sed 's/ //g'`
  project_id=`echo $i | cut -d "|" -f 1 | sed 's/ //g'`
  agg_id=`openstack aggregate create --zone nova --property filter_tenant_id=$project_id $projetc_name | grep -w id | cut -d "|" -f 3 | sed 's/ //g'`
  for host_id in $(cat hostIdList)
    openstack aggregate add host $agg_id $host_id
done