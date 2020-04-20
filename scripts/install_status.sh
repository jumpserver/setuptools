#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

flag=1

function check_mysql() {
    echo -ne "MySQL Server  Check \t........................ "
    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD -e "use $DB_NAME;" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=0
        return ${flag}
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_redis() {
    echo -ne "Redis Server  Check \t........................ "
    if [ ! "$REDIS_PASSWORD" ]; then
        redis-cli -h $REDIS_HOST -p $REDIS_PORT info >/dev/null 2>&1
    else
        redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD info >/dev/null 2>&1
    fi
    if [ $? -ne 0 ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=0
        return ${flag}
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_py3() {
    echo -ne "Python3 venv  Check \t........................ "
    if [ ! -d "$install_dir/py3" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=0
        return ${flag}
    else
        if [ -f "$PROJECT_DIR/$Version/core_flag" ]; then
            echo -e "[\033[31m ERROR \033[0m]"
            flag=0
            return ${flag}
        fi
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_core() {
    echo -ne "Jms_core      Check \t........................ "
    if [ ! "$(systemctl status jms_core | grep Active | grep running)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=0
        return ${flag}
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_nginx() {
    echo -ne "Nginx Server  Check \t........................ "
    if [ ! "$(systemctl status nginx | grep Active | grep running)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=0
        return ${flag}
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_koko() {
    echo -ne "Jms_koko      Check \t........................ "
    if [ ! "$(docker ps | grep jms_koko)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_guacamole() {
    echo -ne "Jms_guacamole Check \t........................ "
    if [ ! "$(docker ps | grep jms_guacamole)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_gunicorn() {
    echo -ne "Gunicorn Port Check \t........................ "
    if [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://127.0.0.1:8080)" != "302" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_web() {
    echo -ne "Nginx Port    Check \t........................ "
    if [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://127.0.0.1:$http_port)" == "302" ]; then
        echo -e "[\033[32m OK \033[0m]"
    elif [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://127.0.0.1:$http_port)" == "301" ]; then
        echo -e "[\033[33m WARN \033[0m]"
    else
        echo -e "[\033[31m ERROR \033[0m]"
    fi
}

function main() {
    check_mysql
    check_redis
    check_py3
    check_core
    check_koko
    check_guacamole
    check_nginx
    check_gunicorn
    check_web
    if [ $flag -eq 0 ]; then
      echo -e "[\033[31m ERROR \033[0m] 部分组件安装失败，请查阅上述检测结果"
      echo -e "[ Tip ] 你可以执行 uninstall 卸载后根据提示重新开始部署 \n"
      exit 1
    else
      echo -e "[\033[33m WARN \033[0m] 部分组件安装失败, 但是核心功能已经安装成功"
      echo -e "[ Tip ] 你可以在稍后重新执行 install 命令来安装部署失败的组件 \n"
    fi
}

main
