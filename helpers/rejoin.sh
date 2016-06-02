#!/bin/bash
image_id=$(docker images | grep 0.4.0| awk '{print $3}')
docker_last=$(docker ps | grep $image_id | awk '{print $1}' | head -1)
docker exec -ti $docker_last bash
