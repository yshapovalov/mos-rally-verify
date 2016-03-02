#!/bin/bash -xe
CONTROLLER_ID="$(fuel node | grep controller| awk '{print$1}'| head -1)"
echo $CONTROLLER_ID
CONTAINER_MOUNT_HOME_DIR="${CONTAINER_MOUNT_HOME_DIR:-/var/lib/rally-container-home-dir}"
CONTROLLER_PROXY_PORT="8888"
KEYSTONE_API_VERSION="v2.0"
CACERT_FILE_PATH="/var/lib/astute/haproxy/public_haproxy.pem"
APACHE_API_PROXY_CONF_PATH="/etc/apache2/sites-enabled/25-apache_api_proxy.conf"

if [ ! -d ${CONTAINER_MOUNT_HOME_DIR} ]; then
    mkdir ${CONTAINER_MOUNT_HOME_DIR}
fi

CONTROLLER_IP="$(fuel node "$@" | awk '/controller/{print $10}' | head -1)"
CONTROLLER_PROXY_URL="http://${CONTROLLER_IP}:${CONTROLLER_PROXY_PORT}"
CONTROLLER_PROXY_URL_TLS="https://${CONTROLLER_IP}:${CONTROLLER_PROXY_PORT}"
scp node-${CONTROLLER_ID}:/root/openrc ${CONTAINER_MOUNT_HOME_DIR}/

echo "export HTTP_PROXY='$CONTROLLER_PROXY_URL'" >> ${CONTAINER_MOUNT_HOME_DIR}/openrc
echo "export HTTPS_PROXY='$CONTROLLER_PROXY_URL'" >> ${CONTAINER_MOUNT_HOME_DIR}/openrc

ALLOW_CONNECT="$(ssh node-${CONTROLLER_ID} "cat ${APACHE_API_PROXY_CONF_PATH} | grep AllowCONNECT")"
if [ ! "$(echo ${ALLOW_CONNECT} | grep -o 35357)" ]; then
    ssh node-${CONTROLLER_ID} "sed -i 's/9696/9696 35357/' ${APACHE_API_PROXY_CONF_PATH} && service apache2 restart"
fi

IS_TLS="$(ssh node-${CONTROLLER_ID} ". openrc; keystone catalog --service identity 2>/dev/null | awk '/https/'")"
if [ "${IS_TLS}" ]; then
    scp node-${CONTROLLER_ID}:${CACERT_FILE_PATH} ${CONTAINER_MOUNT_HOME_DIR}/
    chown 65500 ${CONTAINER_MOUNT_HOME_DIR}/$(basename ${CACERT_FILE_PATH})
    echo "export OS_CACERT='/home/rally/$(basename ${CACERT_FILE_PATH})'" >> ${CONTAINER_MOUNT_HOME_DIR}/openrc
fi

echo "sed -i 's|#swift_operator_role = Member|swift_operator_role=SwiftOperator|g' /etc/rally/rally.conf
      source /home/rally/openrc
      git clone https://github.com/openstack/tempest.git /home/rally/tempest
      rally-manage db recreate
      rally deployment create --fromenv --name=tempest
      rally verify install --source /home/rally/tempest
      rally verify genconfig
      rally verify showconfig" > ${CONTAINER_MOUNT_HOME_DIR}/install_tempest.sh

chmod +x ${CONTAINER_MOUNT_HOME_DIR}/install_tempest.sh

docker pull rallyforge/rally:latest
docker run --net host -v /var/lib/rally-container-home-dir/:/home/rally -ti -u root rallyforge/rally 

