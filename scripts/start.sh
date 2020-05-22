#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

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
    docker start jms_koko jms_guacamole
fi

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
