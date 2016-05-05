#!/bin/bash -xe

function prepare {
    cp /root/openrc /home
    V2_FIX=$(cat /home/openrc |grep v2.0| wc -l)
    if [ ${V2_FIX} == '0' ]; then
        sed -i 's|:5000|:5000/v2.0|g' /home/openrc
    else
        echo "openrc file already fixed"
    fi
    
    IS_TLS=$(source /root/openrc; openstack endpoint show identity 2>/dev/null | awk '/https/')
    if [ "${IS_TLS}" ]; then
        cp /var/lib/astute/haproxy/public_haproxy.pem /home 
        echo "export OS_CACERT='/home/rally/public_haproxy.pem'" >> /home/openrc
    fi

    echo "sed -i 's|#swift_operator_role = Member|swift_operator_role = SwiftOperator|g' /etc/rally/rally.conf
          source /home/rally/openrc
	  git clone https://github.com/openstack/tempest.git /home/rally/tempest
          cd /home/rally/tempest
          git checkout 63cb9a3718f394c9da8e0cc04b170ca2a8196ec2
	  rally-manage db recreate
	  rally deployment create --fromenv --name=tempest
	  rally verify install --source /home/rally/tempest
	  rally verify genconfig" >> /home/install-tempest
    chmod +x /home/install-tempest
}

function install_docker_and_run {
    apt-get install -y docker.io
    apt-get install -y cgroup-bin
    docker pull rallyforge/rally:0.4.0
    image_id=$(docker images | grep 0.4.0| awk '{print $3}')
    docker run --net host -v /home/:/home/rally -tid -u root $image_id
    docker_id=$(docker ps | grep $image_id | awk '{print $1}'| head -1)
}

function configure_tempest {
    docker exec -ti $docker_id bash -c "./install-tempest"
    docker exec -ti $docker_id bash -c "apt-get install -y vim"
    tconf=$(find /home -name tempest.conf)
    sed -i '79i max_template_size = 5440000' $tconf
    sed -i '80i max_resources_per_stack = 20000' $tconf
    sed -i '81i max_json_body_size = 10880000' $tconf
    echo '[volume]' >> $tconf
    echo 'build_timeout = 300' >> $tconf
    docker exec -ti $docker_id bash -c "rally verify showconfig"
    docker exec -ti $docker_id bash
}

prepare
install_docker_and_run
configure_tempest
