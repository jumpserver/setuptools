#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function prepare_set() {
    cp $BASE_DIR/nginx/nginx.repo /etc/yum.repos.d/nginx.repo
}

function install_nginx() {
    echo ">> Install Nginx"
    yum localinstall -y $BASE_DIR/nginx/nginx-1.16.1-1.el7.ngx.x86_64.rpm
}

function download_luna() {
    if [ ! -f "$PROJECT_DIR/$Version/luna.tar.gz" ]; then
        wget -O $PROJECT_DIR/$Version/luna.tar.gz http://demo.jumpserver.org/download/luna/$Version/luna.tar.gz
    fi
    tar xf $PROJECT_DIR/$Version/luna.tar.gz -C $install_dir/
}

function start_nginx() {
    systemctl start nginx
    systemctl enable nginx
}

function config_nginx() {
    echo > /etc/nginx/conf.d/default.conf
    cp $BASE_DIR/nginx/jumpserver.conf /etc/nginx/conf.d/jumpserver.conf
    if [ "$http_port" != "80" ]; then
        sed -i "s@listen 80;@listen $http_port;@g" /etc/nginx/conf.d/jumpserver.conf
    fi
    if [ $install_dir != "/opt" ]; then
        sed -i "s@/opt@$install_dir@g" /etc/nginx/conf.d/jumpserver.conf
    fi
}

function main {
    if [ ! -f "/etc/yum.repos.d/nginx.repo" ]; then
        prepare_set
    fi
    which nginx >/dev/null 2>&1
    if [ $? -ne 0 ];then
        install_nginx
    fi
    if [ ! -f /etc/nginx/conf.d/jumpserver.conf ];then
        config_nginx
    fi
    if [ ! "$(systemctl status nginx | grep running)" ]; then
        start_nginx
    fi
    if [ ! -d "$install_dir/luna" ]; then
        download_luna
    fi
}

main
