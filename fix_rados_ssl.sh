#!/bin/bash -xe
echo Fix RadosGW publicurl
source /root/openrc
swift_id=$(openstack endpoint list |grep object-store | awk '{print\$2}')
echo $swift_id
adminurl=$(openstack endpoint show $swift_id |grep adminurl | awk '{print\$4}')
echo $adminurl
internalurl=$(openstack endpoint show $swift_id |grep internalurl | awk '{print\$4}')
echo $internalurl
publicurl="https://public.fuel.local:8080/swift/v1"
echo $publicurl
region=$(openrc; openstack endpoint show $swift_id |grep region | awk '{print\$4}')
echo $region
openstack endpoint delete $swift_id
openstack endpoint create swift --publicurl $publicurl --adminurl $adminurl --internalurl $internalurl --region $region
