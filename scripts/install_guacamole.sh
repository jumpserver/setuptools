#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function remove_guacamole() {
    docker stop jms_guacamole >/dev/null 2>&1
    docker rm jms_guacamole >/dev/null 2>&1
}

function start_guacamole() {
    echo ">> Install Jms_guacamole"
    docker run --name jms_guacamole -d -p 127.0.0.1:8081:8080 -e JUMPSERVER_SERVER=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_guacamole:$Version
    sleep 5s
}

function check_guacamole() {
    if [ "$(docker exec jms_guacamole env | grep BOOTSTRAP_TOKEN | cut -d = -f2)" != "$BOOTSTRAP_TOKEN" ]; then
        remove_guacamole
        start_guacamole
    fi
    if [ ! "$(docker exec jms_guacamole env | grep $Server_IP )" ]; then
        remove_guacamole
        start_guacamole
    fi
}

function main() {
    if [ ! "$(docker ps | grep jms_guacamole:$Version)" ]; then
        remove_guacamole
        start_guacamole
    else
        check_guacamole
    fi
}

main
