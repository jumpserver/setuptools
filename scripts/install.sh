#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function success() {
    echo -e "\033[31m Jumpserver 安装成功!\n 默认登陆信息: \033[0m"
    echo -e "\033[32m username: admin \033[0m"
    echo -e "\033[32m password: admin \033[0m"
    echo -e "\033[33m [请在防火墙和安全组放行 $http_port 和 $ssh_port 端口] \033[0m"
}

function prepare_install() {
    which wget >/dev/null 2>&1
    if [ $? -ne 0 ];then
        yum install -y wget
    fi
    if [ ! "$(rpm -qa | grep epel-release)" ]; then
        yum install -y epel-release
    fi
    if grep -q 'mirrors.aliyun.com' /etc/yum.repos.d/CentOS-Base.repo; then
        true
    else
        wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
        sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
    fi
    which git >/dev/null 2>&1
    if [ $? -ne 0 ];then
        yum install -y git
    fi
    which gcc >/dev/null 2>&1
    if [ $? -ne 0 ];then
        yum install -y gcc
    fi
    yum update -y
    if [ ! -d "$PROJECT_DIR/$Version" ]; then
        mkdir -p $PROJECT_DIR/$Version
    fi
}

function main() {
    bash $BASE_DIR/check_install_env.sh
    if [[ $? != 0 ]]; then
        exit 1
    fi
    prepare_install
    bash $BASE_DIR/set_firewall.sh
    bash $BASE_DIR/install_docker.sh
    if [ $DB_HOST == 127.0.0.1 ]; then
        bash $BASE_DIR/install_mariadb.sh
    fi
    if [ $REDIS_HOST == 127.0.0.1 ]; then
        bash $BASE_DIR/install_redis.sh
    fi
    bash $BASE_DIR/install_nginx.sh
    bash $BASE_DIR/install_core.sh
    bash $BASE_DIR/install_koko.sh
    bash $BASE_DIR/install_guacamole.sh
    success
}

main
