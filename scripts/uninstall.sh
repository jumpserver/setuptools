#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

echo -e "\033[31m 准备从系统中卸载 jumpserver \033[0m"

if [ "$(systemctl status nginx | grep running)" ]; then
    systemctl stop nginx
fi
rm -rf /etc/nginx/conf.d/jumpserver.conf

if [ "$(systemctl status docker | grep running)" ]; then
    docker stop jms_koko jms_guacamole
    docker rm jms_koko jms_guacamole
    docker rmi jumpserver/jms_koko:$Version jumpserver/jms_guacamole:$Version
    systemctl stop docker
fi

if [ "$(systemctl status jms_core | grep running)" ]; then
    systemctl stop jms_core
fi
rm -rf /usr/lib/systemd/system/jms_core.service
rm -rf $install_dir/py3
rm -rf $install_dir/luna
rm -rf $install_dir/jumpserver

if [ $REDIS_HOST == 127.0.0.1 ]; then
    if [ "$(systemctl status redis | grep running)" ]; then
        redis-cli flushall
        systemctl stop redis
    fi
fi
if [ $DB_HOST == 127.0.0.1 ]; then
    if [ "$(systemctl status mariadb | grep running)" ]; then
        mysql -uroot -e"drop user '$DB_USER'@'$DB_HOST';drop database $DB_NAME;flush privileges;"
        systemctl stop mariadb
    fi
fi

if [ "$(systemctl status firewalld | grep running)" ]; then
    if [ "$(firewall-cmd --list-all | grep $http_port)" ]; then
        firewall-cmd --zone=public --remove-port=$http_port/tcp --permanent
        firewall-cmd --reload
    fi
    if [ "$(firewall-cmd --list-all | grep $ssh_port)" ]; then
        firewall-cmd --zone=public --remove-port=$ssh_port/tcp --permanent
        firewall-cmd --reload
    fi
    if [ "$(firewall-cmd --list-all | grep 8080)" ]; then
        firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="172.17.0.0/16" port protocol="tcp" port="8080" accept"
        firewall-cmd --reload
    fi
fi

if [ "$(getenforce)" != "Disabled" ]; then
    if [ "$http_port" != "80" ]; then
        semanage port -d -t http_port_t -p tcp $http_port || true
    fi
fi

echo -e "\033[31m 已经成功清理 jumpserver 相关文件 \033[0m"
echo -e "\033[31m 请自行卸载 docker nginx redis mariadb 服务 \033[0m"
echo -e "\033[31m yum remove -y docker-ce docker-ce-cli nginx redis mariadb-server mariadb-devel mariadb-libs mariadb \033[0m"
