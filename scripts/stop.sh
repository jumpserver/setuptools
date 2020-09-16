#!/usr/bin/env bash
#

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
}

function main() {
    stop_koko
    stop_guacamole
    stop_core
    echo ""
}

main
