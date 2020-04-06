#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function start_koko() {
    if [ ! "$(docker ps -a | grep jms_koko | grep $Version)" ]; then
        if [ "$(docker ps | grep jms_koko)" ]; then
            docker stop jms_koko
            docker rm jms_koko
        fi
        docker run --name jms_koko -d -p $ssh_port:2222 -p 127.0.0.1:5000:5000 -e CORE_HOST=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_koko:$Version
        else
            docker restart jms_koko
    fi
}

function main() {
    start_koko
}

main
