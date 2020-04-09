#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function install_redis() {
    echo ">> Install redis"
    yum install -y redis
}

function start_redis {
    systemctl start redis
    systemctl enable redis
}

function config_passwd() {
    REDIS_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24`
    sed -i "0,/REDIS_PASSWORD=/s//REDIS_PASSWORD=$REDIS_PASSWORD/" $PROJECT_DIR/config.conf
}

function config_redis() {
    if [ ! "$(cat /etc/redis.conf | grep -v ^\# | grep requirepass | awk '{print $2}')" ]; then
        sed -i "481i requirepass $REDIS_PASSWORD" /etc/redis.conf
    else
        sed -i "s/requirepass .*/requirepass $REDIS_PASSWORD/g" /etc/redis.conf
    fi
    systemctl restart redis
}

function main {
    if [ ! "$(rpm -qa | grep redis)" ]; then
        install_redis
    fi
    if [ ! "$REDIS_PASSWORD" ]; then
        config_passwd
    fi
    if [ ! "$(systemctl status redis | grep Active | grep running)" ]; then
        start_redis
    fi
    redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD info >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        config_redis
    fi
}

main
