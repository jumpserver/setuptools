#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function prepare_set() {
    yum -y localinstall http://mirrors.ustc.edu.cn/mysql-repo/mysql57-community-release-el7.rpm
}

function install_mysql() {
    echo ">> Install MySQL"
    yum install -y mysql-community-server mysql-community-devel
}

function start_mysql() {
    systemctl start mysqld
    systemctl enable mysqld
}

function config_database() {
    mysql -uroot -e "create database $DB_NAME default charset 'utf8' collate 'utf8_bin';"
}

function config_user() {
    mysql -uroot -e "drop user '$DB_USER'@'$DB_HOST';" >/dev/null 2>&1
    mysql -uroot -e "set global validate_password_policy=LOW;grant all on $DB_NAME.* to '$DB_USER'@'$DB_HOST' identified by '$DB_PASSWORD';flush privileges;"
}

function config_passwd() {
    DB_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24`
    sed -i "0,/DB_PASSWORD=/s//DB_PASSWORD=$DB_PASSWORD/" $PROJECT_DIR/config.conf
}

function main() {
    if [ ! -f "/etc/yum.repos.d/mysql-community.repo" ]; then
        prepare_set
    fi
    if [ ! "$(rpm -qa | grep mysql-community-server)" ]; then
        install_mysql
    fi
    if [ ! "$(cat /usr/bin/mysqld_pre_systemd | grep -v ^\# | grep initialize-insecure )" ]; then
        sed -i "s@--initialize @--initialize-insecure @g" /usr/bin/mysqld_pre_systemd
    fi
    if [ ! "$(systemctl status mysqld | grep Active | grep running)" ]; then
        start_mysql
    fi
    if [ ! "$DB_PASSWORD" ]; then
        config_passwd
    fi
    if [ ! -d "/var/lib/mysql/$DB_NAME" ]; then
        config_database
    fi
    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD -e "use $DB_NAME;" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        config_user
    fi
}

main
