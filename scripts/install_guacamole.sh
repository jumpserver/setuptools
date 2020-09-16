#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

if [ -f "$PROJECT_DIR/$Version/guacamole.tar" ]; then
    docker load < $PROJECT_DIR/$Version/guacamole.tar
fi

function remove_guacamole() {
    docker stop jms_guacamole >/dev/null 2>&1
    docker rm jms_guacamole >/dev/null 2>&1
}

function start_guacamole() {
    echo ">> Install Jms_guacamole"
    docker run --name jms_guacamole -d -p 127.0.0.1:8081:8080 -e JUMPSERVER_SERVER=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_guacamole:$Version
}

function check_guacamole() {
    if [ ! "$(docker inspect jms_guacamole | grep BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN)" ] || [ ! "$(docker inspect jms_guacamole | grep JUMPSERVER_SERVER=http://$Server_IP:8080)" ]; then
        remove_guacamole
        start_guacamole
    else
        docker start jms_guacamole
    fi
}

function main() {
    if [ ! "$(docker ps | grep jms_guacamole:$Version)" ]; then
        if [ ! "$(docker ps -a | grep jms_guacamole:$Version)" ]; then
            start_guacamole
        else
            check_guacamole
        fi
    else
        check_guacamole
    fi
}

main
