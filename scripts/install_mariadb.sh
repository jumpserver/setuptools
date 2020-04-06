#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function install_mariadb() {
    echo ">> Install Mariadb"
    yum install -y mariadb mariadb-devel mariadb-server
}

function start_mariadb() {
    systemctl start mariadb
    systemctl enable mariadb
}

function config_mariadb() {
    if [ ! "$DB_PASSWORD" ]; then
        DB_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24`
        sed -i "0,/DB_PASSWORD=/s//DB_PASSWORD=$DB_PASSWORD/" $PROJECT_DIR/config.conf
    fi
    mysql -uroot -e "create database $DB_NAME default charset 'utf8';grant all on $DB_NAME.* to '$DB_USER'@'$DB_HOST' identified by '$DB_PASSWORD';flush privileges;"
}

function main() {
    if [ ! "$(rpm -qa | grep mariadb-server)" ]; then
        install_mariadb
    fi
    if [ ! "$(systemctl status mariadb | grep running)" ]; then
        start_mariadb
    fi
    if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
        config_mariadb
    fi
}

main
