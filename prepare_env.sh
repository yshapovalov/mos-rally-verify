#!/bin/bash -xe
CACERT_FILE_PATH="/var/lib/astute/haproxy/public_haproxy.pem"
IS_TLS=$(source openrc; keystone catalog --service identity 2>/dev/null | awk '/https/')
if [ "${IS_TLS}" ]; then
    cp ${CACERT_FILE_PATH} /root
    echo "export OS_CACERT='${CACERT_FILE_PATH}'" >> /root/openrc
fi

echo "sed -i 's|#swift_operator_role = Member|swift_operator_role = SwiftOperator|g' /etc/rally/rally.conf
      source /root/openrc
      git clone https://github.com/openstack/tempest.git /root/tempest
      rally-manage db recreate
      rally deployment create --fromenv --name=tempest
      rally verify install --source /root/tempest
      rally verify genconfig
      rally verify showconfig" > /root/install_tempest.sh

chmod +x /root/install_tempest.sh

apt-get install -y docker.io
docker pull rallyforge/rally:0.4.0
image_id=$(docker images | grep 0.4.0| awk '{print $3}')
docker run --net host -v /var/lib/rally-container-home-dir/:/home/rally -tid -u root $image_id
docker_id=$(docker ps | grep $image_id | awk '{print $1}')
docker exec -ti $docker_id bash
