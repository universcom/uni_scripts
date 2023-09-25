#! /bin/bash
# convert qcow2 images to raw image and add it to openstack glance

mkdir -p /images/raw
echo -e "\e[31mprimary images root folder is: /images/"
echo -e "primary images raw root folder is: /images/raw/\e[39m"
if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ] ; then
echo -e "\e[31mexample: REPLACE IMAGE-QCOW2-NAME IMAGE-RAW-NAME"
echo -e "./convert-glance-add.sh IMAGE-QCOW2-NAME IMAGE-RAW-NAME GLANCE_IMAGE_NAME \e[39m"
else
echo -e "\e[31m\e[5mConverting...\e[25m"
qemu-img convert -p -f qcow2 -O raw /images/$1 /images/raw/$2
source /root/admin-openrc.sh
echo -e "\e[31m\e[5mImage Creating... \e[25m\e[39m"
glance image-create --name "$3" --file /images/raw/$2   --disk-format raw --container-format bare --visibility public --progress
fi
