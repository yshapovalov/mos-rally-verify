#!/bin/bash -xe

function prepare {
    cp /root/openrc /home
    cp ./run_debug.sh /home
    cp ./install_tempest.sh /home
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
}

function install_docker_and_run {
    apt-get install -y docker.io
    apt-get install -y cgroup-bin
    docker pull rallyforge/rally:latest
    image_id=$(docker images | grep latest| awk '{print $3}')
    docker run --net host -v /home/:/home/rally -tid -u root $image_id
    docker_id=$(docker ps | grep $image_id | awk '{print $1}'| head -1)
}

function configure_tempest {
    source /home/openrc
    docker exec -ti $docker_id bash -c "./install_tempest.sh"
    docker exec -ti $docker_id bash -c "apt-get install -y vim"
    tconf=$(find /home -name tempest.conf)
    storage_protocol="iSCSI"
    check_ceph=$(cat /etc/cinder/cinder.conf |grep RBD-backend | wc -l)
    if [ ${check_ceph} == '1' ]; then
        storage_protocol="ceph"
    fi

    if [ $(grep  "\[orchestration\]" $tconf) ]; then
        N=$(grep -n "\[orchestration\]" $tconf | cut -d':' -f1)
        N=$(($N+1))
        sed -e $N"s/^/max_json_body_size = 10880000\n/" -i $tconf
        sed -e $N"s/^/max_resources_per_stack = 20000\n/" -i $tconf
        sed -e $N"s/^/max_template_size = 5440000\n/" -i $tconf
    fi
    
    node_compute_count=$(nova hypervisor-list |grep test.domain.local |wc -l)
    if [ "$node_compute_count" -gt 1]; then
        sed -i 's|#live_migration = False|live_migration = True|g' $tconf
    fi

    if [ $(grep  "\[compute\]" $tconf) ]
    then
        N=$(grep -n "\[compute\]" $tconf | cut -d':' -f1)
        N=$(($N+1))
        sed -e $N"s/^/volume_device_name = vdc\n/" -i $tconf
    fi

    echo "[volume]" >> $tconf
    echo "build_timeout = 300" >> $tconf
    echo "storage_protocol = $storage_protocol" >> $tconf
    
    docker exec -ti $docker_id bash -c "rally verify showconfig"
    docker exec -ti $docker_id bash
}

prepare
install_docker_and_run
configure_tempest
