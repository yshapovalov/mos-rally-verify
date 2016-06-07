#!/bin/bash -xe
sed -i 's|#swift_operator_role = Member|swift_operator_role = SwiftOperator|g' /etc/rally/rally.conf
source /home/rally/openrc
rally-manage db recreate
rally deployment create --fromenv --name=tempest 
rally verify install --version 55511d98f1f525edec476fe638ac13366ba5b03b
rally verify genconfig
