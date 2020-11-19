#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

flag=0

function install_redis() {
    echo ">> Install redis"
    yum install -y redis
    sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" /etc/redis.conf
    sed -i "561i maxmemory-policy allkeys-lru" /etc/redis.conf
}

function start_redis {
    systemctl start redis
    systemctl enable redis
}

function config_redis() {
    if [ $REDIS_PORT != 6379 ]; then
        sed -i "s/port 6379/port $REDIS_PORT/g" /etc/redis.conf
        flag=1
    fi
    if [ ! "$(cat /etc/redis.conf | grep -v ^\# | grep requirepass)" ]; then
        sed -i "481i requirepass $REDIS_PASSWORD" /etc/redis.conf
        flag=1
    else
        sed -i "s/requirepass .*/requirepass $REDIS_PASSWORD/g" /etc/redis.conf
        flag=1
    fi
    if [ $flag == 1 ]; then
        systemctl restart redis
    fi
}

function config_passwd() {
    REDIS_PASSWORD=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24`
    sed -i "0,/REDIS_PASSWORD=/s//REDIS_PASSWORD=$REDIS_PASSWORD/" $PROJECT_DIR/config.conf
    config_redis
}

function main {
    if [ ! "$(rpm -qa | grep redis)" ]; then
        install_redis
    fi
    if [ ! "$REDIS_PASSWORD" ]; then
        config_passwd
    else
        config_redis
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
