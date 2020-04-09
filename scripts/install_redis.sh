#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function install_redis() {
    yum install -y redis
}

function start_redis {
    echo ">> Install redis"
    systemctl start redis
    systemctl enable redis
}

function config_redis() {
    if [ ! $REDIS_PASSWORD ]; then
        if [ ! "$(cat /etc/redis.conf | grep -v ^\# | grep requirepass | awk '{print $2}')" ]; then
            REDIS_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24`
            sed -i "481i requirepass $REDIS_PASSWORD" /etc/redis.conf
            sed -i "0,/REDIS_PASSWORD=/s//REDIS_PASSWORD=$REDIS_PASSWORD/" $PROJECT_DIR/config.conf
        else
            REDIS_PASSWORD=`cat /etc/redis.conf | grep -v ^\# | grep requirepass | awk '{print $2}'`
            sed -i "0,/REDIS_PASSWORD=/s//REDIS_PASSWORD=$REDIS_PASSWORD/" $PROJECT_DIR/config.conf
        fi
    else
        if [ ! "$(cat /etc/redis.conf | grep -v ^\# | grep requirepass | awk '{print $2}')" ]; then
            sed -i "481i requirepass $REDIS_PASSWORD" /etc/redis.conf
        else
            sed -i "s/requirepass .*/requirepass $REDIS_PASSWORD/g" /etc/redis.conf
        fi
    fi
}

function main {
    if [ ! "$(rpm -qa | grep redis)" ]; then
        install_redis
        config_redis
    fi
    if [ ! "$(systemctl status redis | grep running)" ]; then
        start_redis
    fi
}

main
