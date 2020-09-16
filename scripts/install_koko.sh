#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

if [ -f "$PROJECT_DIR/$Version/koko.tar" ]; then
    docker load < $PROJECT_DIR/$Version/koko.tar
fi

function remove_koko() {
    docker stop jms_koko >/dev/null 2>&1
    docker rm jms_koko >/dev/null 2>&1
}

function start_koko() {
    echo ">> Install Jms_koko"
    docker run --name jms_koko -d -p $ssh_port:2222 -p 127.0.0.1:5000:5000 -e CORE_HOST=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always --privileged=true jumpserver/jms_koko:$Version
}

function check_koko() {
    if [ ! "$(docker inspect jms_koko | grep BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN)" ] || [ ! "$(docker inspect jms_koko | grep CORE_HOST=http://$Server_IP:8080)" ]; then
        remove_koko
        start_koko
    else
        docker start jms_koko
    fi
}

function main() {
    if [ ! "$(docker ps | grep jms_koko:$Version)" ]; then
        if [ ! "$(docker ps -a | grep jms_koko:$Version)" ]; then
            start_koko
        else
            check_koko
        fi
    else
        check_koko
    fi
}

main
