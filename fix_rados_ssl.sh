#!/bin/bash -xe
echo Fix RadosGW publicurl
        swift_id=$(ssh node-${CONTROLLER_ID} ". openrc; openstack endpoint list |grep object-store | awk '{print\$2}'")
        echo $swift_id
        adminurl=$(ssh node-${CONTROLLER_ID} ". openrc; openstack endpoint show $swift_id |grep adminurl | awk '{print\$4}'")
        echo $adminurl
        internalurl=$(ssh node-${CONTROLLER_ID} ". openrc; openstack endpoint show $swift_id |grep internalurl | awk '{print\$4}'")
        echo $internalurl
        publicurl="https://public.fuel.local:8080/swift/v1"
        echo $publicurl
        region=$(ssh node-${CONTROLLER_ID} ". openrc; openstack endpoint show $swift_id |grep region | awk '{print\$4}'")
        echo $region
        ssh node-${CONTROLLER_ID} ". openrc; openstack endpoint delete $swift_id"
        ssh node-${CONTROLLER_ID} ". openrc; openstack endpoint create swift --publicurl $publicurl --adminurl $adminurl --internalurl $internalurl --region $region"
