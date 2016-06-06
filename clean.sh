#!/bin/bash -xe
image_id=$(docker images | grep latest| awk '{print $3}')
docker_list=$(docker ps -a| grep $image_id |awk '{print$1}')
docker rm -f $docker_list
rm -rf /home/tempest /home/.rally
rm /home/install-tempest /home/openrc /home/.rally.sqlite
