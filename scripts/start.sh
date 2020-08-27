#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function success() {
    echo -e "JumpServer 启动成功! "
    echo -ne "Web 登陆信息: "
    echo -e "\033[32mhttp://$Server_IP:$http_port\033[0m"
    echo -ne "SSH 登录信息: "
    echo -e "\033[32mssh admin@$Server_IP -p$ssh_port\033[0m"
    echo -ne "初始用户名密码: "
    echo -e "\033[32madmin admin \033[0m\n"
    echo -e "\033[33m[如果你是云服务器请在安全组放行 $http_port 和 $ssh_port 端口] \n\033[0m"
}

if [ $DB_HOST == 127.0.0.1 ]; then
    if [ ! "$(systemctl status mariadb | grep Active | grep running)" ]; then
        systemctl start mariadb
    fi
fi

if [ $REDIS_HOST == 127.0.0.1 ]; then
    if [ ! "$(systemctl status redis | grep Active | grep running)" ]; then
        systemctl start redis
    fi
fi

if [ ! "$(systemctl status jms_core | grep Active | grep running)" ]; then
    systemctl start jms_core
fi

if [ ! "$(systemctl status docker | grep Active | grep running)" ]; then
    systemctl start docker
fi

bash $BASE_DIR/install_koko.sh
bash $BASE_DIR/install_guacamole.sh

if [ ! "$(docker ps | grep jms_koko)" ]; then
    systemctl restart docker
    docker start jms_koko
fi
if [ ! "$(docker ps | grep jms_guacamole)" ]; then
    docker start jms_guacamole
fi

if [ ! "$(systemctl status nginx | grep Active | grep running)" ]; then
    systemctl start nginx
fi

bash $BASE_DIR/install_status.sh
if [[ $? != 0 ]]; then
    exit 1
fi

echo ""
success
