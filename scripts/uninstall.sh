#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

echo -e "\033[31m 准备从系统中卸载 jumpserver \033[0m"

if [ "$(systemctl status nginx | grep Active | grep running)" ]; then
    systemctl stop nginx
fi
rm -rf /etc/nginx/conf.d/jumpserver.conf

if [ "$(systemctl status docker | grep Active | grep running)" ]; then
    docker stop jms_koko jms_guacamole
    docker rm jms_koko jms_guacamole
    docker rmi jumpserver/jms_koko:$Version jumpserver/jms_guacamole:$Version
    systemctl stop docker
fi

if [ "$(systemctl status jms_core | grep Active | grep running)" ]; then
    systemctl stop jms_core
fi
rm -rf /usr/lib/systemd/system/jms_core.service
rm -rf $install_dir/py3
rm -rf $install_dir/luna
rm -rf $install_dir/jumpserver

if [ $REDIS_HOST == 127.0.0.1 ]; then
    if [ "$(systemctl status redis | grep Active | grep running)" ]; then
        if [ ! "$REDIS_PASSWORD" ]; then
            redis-cli -h $REDIS_HOST -p $REDIS_PORT flushall
        else
            redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD flushall
        fi
        systemctl stop redis
    fi
fi
if [ $DB_HOST == 127.0.0.1 ]; then
    if [ "$(systemctl status mariadb | grep Active | grep running)" ]; then
        mysql -uroot -e"drop user '$DB_USER'@'$DB_HOST';drop database $DB_NAME;flush privileges;"
        systemctl stop mariadb
    fi
fi

if [ "$(systemctl status firewalld | grep Active | grep running)" ]; then
    if [ "$(firewall-cmd --list-all | grep $http_port)" ]; then
        firewall-cmd --zone=public --remove-port=$http_port/tcp --permanent
        firewall-cmd --reload
    fi
    if [ "$(firewall-cmd --list-all | grep $ssh_port)" ]; then
        firewall-cmd --zone=public --remove-port=$ssh_port/tcp --permanent
        firewall-cmd --reload
    fi
    if [ "$(firewall-cmd --list-all | grep 8080)" ]; then
        if [ "$Docker_IP" ]; then
            firewall-cmd --permanent --remove-rich-rule="rule family="ipv4" source address="$Docker_IP" port protocol="tcp" port="8080" accept"
            firewall-cmd --reload
        fi
    fi
fi

if [ "$(getenforce)" != "Disabled" ]; then
    if [ "$http_port" != "80" ]; then
        semanage port -d -t http_port_t -p tcp $http_port || true
    fi
    if [ "$(semanage fcontext -l | grep $install_dir/luna)" ]; then
        semanage fcontext -d -t httpd_sys_content_t "$install_dir/luna(/.*)?"
    fi
    if [ "$(semanage fcontext -l | grep $install_dir/jumpserver/data)" ]; then
        semanage fcontext -d -t httpd_sys_content_t "$install_dir/jumpserver/data(/.*)?"
    fi
fi

echo -e "\033[31m 已经成功清理 jumpserver 相关文件 \033[0m"
echo -e "\033[31m 请自行卸载 docker nginx redis mariadb 服务 \033[0m"
echo -e "\033[31m yum remove -y docker-ce docker-ce-cli nginx redis mariadb-server mariadb-devel mariadb-libs mariadb \033[0m"
echo -e "\033[31m 卸载完成后请重启服务器清空路由表 \033[0m"
