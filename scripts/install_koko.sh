#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function remove_koko() {
    docker stop jms_koko
    docker rm jms_koko
}

function start_koko() {
    echo ">> Install Jms_koko"
    docker run --name jms_koko -d -p $ssh_port:2222 -p 127.0.0.1:5000:5000 -e CORE_HOST=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_koko:$Version
}

function check_koko() {
    if [ "$(docker exec jms_koko env | grep BOOTSTRAP_TOKEN | cut -d = -f2)" != "$BOOTSTRAP_TOKEN" ]; then
        remove_koko
        start_koko
    fi
    if [ ! "$(docker exec jms_koko env | grep $Server_IP )" ]; then
        remove_koko
        start_koko
    fi
}

function main() {
    if [ ! "$(docker ps | grep jms_koko:$Version)" ]; then
        remove_koko
        start_koko
    else
        check_koko
    fi
}

main
