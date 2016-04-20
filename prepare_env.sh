#!/bin/bash -xe
cp /root/openrc /home
IS_TLS=$(source /root/openrc; keystone catalog --service identity 2>/dev/null | awk '/https/')

if [ "${IS_TLS}" ]; then
    cp /var/lib/astute/haproxy/public_haproxy.pem /home 
    echo "export OS_CACERT='/home/rally/public_haproxy.pem'" >> /home/openrc
fi

echo "sed -i 's|#swift_operator_role = Member|swift_operator_role = SwiftOperator|g' /etc/rally/rally.conf
      source /home/rally/openrc
      git clone https://github.com/openstack/tempest.git /home/rally/tempest
      rally-manage db recreate
      rally deployment create --fromenv --name=tempest
      rally verify install --source /home/rally/tempest
      rally verify genconfig" >> /home/install-tempest

chmod +x /home/install-tempest

apt-get install -y docker.io
docker pull rallyforge/rally:0.4.0
image_id=$(docker images | grep 0.4.0| awk '{print $3}')
docker run --net host -v /home/:/home/rally -tid -u root $image_id
docker_id=$(docker ps | grep $image_id | awk '{print $1}')

docker exec -ti $docker_id bash -c "./install-tempest"
docker exec -ti $docker_id bash -c "tconf = $(find / -name tempest.conf)
docker exec -ti $docker_id  bash -c "sed -i '79i max_template_size = 5440000' $tconf"
docker exec -ti $docker_id  bash -c "sed -i '80i max_resources_per_stack = 20000' $tconf"
docker exec -ti $docker_id  bash -c "sed -i '81i max_json_body_size = 10880000' $tconf"
docker exec -ti $docker_id  bash -c "echo '[volume]' >> $tconf"
docker exec -ti $docker_id  bash -c "echo 'build_timeout = 300' >> $tconf"
docker exec -ti $docker_id  bash -c "echo 'test'"
docker exec -ti $docker_id  bash -c "rally verify showconfig"
docker exec -ti $docker_id  bash
