#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function stop_koko() {
    echo -ne "Koko    Stop \t........................ "
    docker stop jms_koko >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function stop_guacamole() {
    echo -ne "Guaca.  Stop \t........................ "
    docker stop jms_guacamole >/dev/null 2>&1
    if [ $? -ne 0 ];then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function stop_core() {
    echo -ne "Core    Stop \t........................ "
    systemctl stop jms_core
    if [ $? -ne 0 ];then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
    if [ "$(ps aux | grep -v grep | grep py3)" ]; then
        ps aux | grep py3 | grep -v grep | awk '{print $2}' | xargs kill -9
    fi
    rm -f $install_dir/jumpserver/tmp/*.pid
}

function main() {
    stop_koko
    stop_guacamole
    stop_core
    echo ""
}

main
