#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

target=$1

function reset_koko() {
    echo ">> Reset Jms_koko"
    docker stop jms_koko
    docker rm jms_koko
    docker run --name jms_koko -d -p $ssh_port:2222 -p 127.0.0.1:5000:5000 -e CORE_HOST=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_koko:$Version
}

function reset_guacamole() {
    echo ">> Reset Jms_guacamole"
    docker stop jms_guacamole
    docker rm jms_guacamole
    docker run --name jms_guacamole -d -p 127.0.0.1:8081:8080 -e JUMPSERVER_SERVER=http://$Server_IP:8080 -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN --restart=always jumpserver/jms_guacamole:$Version
}

function main() {
    case "${target}" in
        koko)
            reset_koko
            ;;
        guacamole)
            reset_guacamole
            ;;
        *)
            echo -e "jmsctl: invalid COMMAND '$target'\n"
            echo -e "Usage: jmsctl reset COMMAND\n"
            echo -e "Commands:"
            echo -e "  koko         重置 koko"
            echo -e "  guacamole    重置 guacamole"
    esac
}

main
