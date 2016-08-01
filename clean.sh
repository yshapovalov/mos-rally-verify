#!/bin/bash -xe
image_id=$(docker images | grep 0.5.0 | awk '{print $3}')
docker_list=$(docker ps -a| grep $image_id |awk '{print$1}')
docker rm -f $docker_list
rm -rf /home/.rally
rm /home/install_tempest.sh /home/openrc /home/.rally.sqlite /home/run_debug.sh
rm /home/public_haproxy.pem
