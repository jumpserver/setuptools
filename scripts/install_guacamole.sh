#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function start_guacamole() {
    echo ">> Install Jms_guacamole"
    if [ ! "$(docker ps -a | grep jms_guacamole | grep $Version)" ]; then
        if [ "$(docker ps -a | grep jms_guacamole)" ]; then
            docker stop jms_guacamole
            docker rm jms_guacamole
        fi
        docker run --name jms_guacamole -d -p 127.0.0.1:8081:8080 -e JUMPSERVER_SERVER=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_guacamole:$Version
    fi
}

function main() {
    if [ ! "$(docker ps | grep jms_guacamole:$Version)" ]; then
        start_guacamole
    else
        if [ "$(docker exec jms_guacamole env | grep BOOTSTRAP_TOKEN | cut -d = -f2)" != "$BOOTSTRAP_TOKEN" ]; then
            docker stop jms_guacamole
            docker rm jms_guacamole
            start_guacamole
        fi
    fi
}

main
