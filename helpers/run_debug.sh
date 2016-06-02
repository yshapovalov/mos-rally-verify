#!/bin/bash -xe
id=$(rally deployment list |grep tempest |awk {'print$2'})
tempest_dir="/home/rally/.rally/tempest/for-deployment-$id"
source $tempest_dir/.venv/bin/activate
export TEMPEST_CONFIG_DIR=$tempest_dir
cd $tempest_dir
source /home/rally/openrc
python -m testtools.run  $1
