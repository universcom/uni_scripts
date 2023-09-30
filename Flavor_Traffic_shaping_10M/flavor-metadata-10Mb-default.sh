#!/bin/bash
# add default metadata to a specified flavor. 
nova flavor-key $1 set quota:vif_outbound_burst=10240
nova flavor-key $1 set quota:vif_inbound_burst=10240
nova flavor-key $1 set quota:vif_outbound_average=10240
nova flavor-key $1 set quota:vif_inbound_average=10240
nova flavor-key $1 set quota:vif_outbound_peak=10240
nova flavor-key $1 set quota:vif_inbound_peak=10240