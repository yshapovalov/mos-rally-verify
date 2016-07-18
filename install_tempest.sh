#!/bin/bash -xe
sed -i 's|#swift_operator_role = Member|swift_operator_role = SwiftOperator|g' /etc/rally/rally.conf
source /home/rally/openrc
rally-manage db recreate
rally deployment create --fromenv --name=tempest 
rally verify install --version 63cb9a3718f394c9da8e0cc04b170ca2a8196ec2
rally verify genconfig
