#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function success() {
    echo ""
    echo -e "JumpServer 启动成功! "
    echo -ne "Web 登陆信息: "
    echo -e "\033[32mhttp://$Server_IP:$http_port\033[0m"
    echo -ne "SSH 登录信息: "
    echo -e "\033[32mssh admin@$Server_IP -p$ssh_port\033[0m"
    echo -ne "初始用户名密码: "
    echo -e "\033[32madmin admin \033[0m\n"
    echo -e "\033[33m[如果你是云服务器请在安全组放行 $http_port 和 $ssh_port 端口] \n\033[0m"
}

function start_mariadb() {
    echo -ne "MySQL   start \t........................ "
    if [ ! "$(systemctl status mariadb | grep Active | grep running)" ]; then
        systemctl start mariadb
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function start_redis() {
    echo -ne "Redis   Start \t........................ "
    if [ ! "$(systemctl status redis | grep Active | grep running)" ]; then
        systemctl start redis
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function start_docker() {
    echo -ne "Docke.  Start \t........................ "
    if [ ! "$(systemctl status docker | grep Active | grep running)" ]; then
        systemctl start docker
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function start_core() {
    echo -ne "Core    Start \t........................ "
    if [ ! "$(systemctl status jms_core | grep Active | grep running)" ]; then
        systemctl start jms_core
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function start_koko(){
    echo -ne "Koko    Start \t........................ "
    bash $BASE_DIR/install_koko.sh >/dev/null 2>&1
    if [ ! "$(docker ps | grep jms_koko)" ]; then
        systemctl restart docker
        docker start jms_koko
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function start_guacamole() {
    echo -ne "Guaca.  Start \t........................ "
    bash $BASE_DIR/install_guacamole.sh >/dev/null 2>&1
    if [ ! "$(docker ps | grep jms_guacamole)" ]; then
        docker start jms_guacamole
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function start_nginx() {
    echo -ne "Nginx   Start \t........................ "
    if [ ! "$(systemctl status nginx | grep Active | grep running)" ]; then
        systemctl start nginx
        if [ $? -ne 0 ]; then
            echo -e "[\033[31m ERROR \033[0m]"
        else
            echo -e "[\033[32m OK \033[0m]"
        fi
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function main() {
    if [ $DB_HOST == 127.0.0.1 ]; then
        start_mariadb
    fi
    if [ $REDIS_HOST == 127.0.0.1 ]; then
        start_redis
    fi
    start_docker
    start_core
    start_koko
    start_guacamole
    start_nginx
    echo ""
    bash $BASE_DIR/install_status.sh
    if [[ $? != 0 ]]; then
        exit 1
    fi
    success
}

main
