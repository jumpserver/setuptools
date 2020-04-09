#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")

function prepare_install() {
    yum install -y yum-utils device-mapper-persistent-data lvm2
}

function install_docker() {
    echo ">> Install Docker"
    prepare_install
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    rpm --import https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
    yum install -y docker-ce
}

function config_docker {
    mkdir -p /etc/docker/
    cp $BASE_DIR/docker/daemon.json /etc/docker/daemon.json
}

function start_docker {
    systemctl start docker
    systemctl enable docker
}

function main {
    which docker >/dev/null 2>&1
    if [ $? -ne 0 ];then
        install_docker
    fi
    if [ ! -f "/etc/docker/daemon.json" ]; then
        config_docker
    fi
    if [ ! "$(systemctl status docker | grep Active | grep running)" ]; then
        start_docker
    fi
}

main
