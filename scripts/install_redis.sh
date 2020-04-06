#!/usr/bin/env bash
#

function install_redis() {
    yum install -y redis
}

function start_redis {
    echo ">> Install Nginx"
    systemctl start redis
    systemctl enable redis
}

function main {
    if [ ! "$(rpm -qa | grep redis)" ]; then
        install_redis
    fi
    if [ ! "$(systemctl status redis | grep running)" ]; then
        start_redis
    fi
}

main
