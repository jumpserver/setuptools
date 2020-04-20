#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

flag=0

function check_mysql() {
    echo -ne "MySQL  Check \t........................ "
    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD -e "use $DB_NAME;" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=1
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_redis() {
    echo -ne "Redis  Check \t........................ "
    if [ ! "$REDIS_PASSWORD" ]; then
        redis-cli -h $REDIS_HOST -p $REDIS_PORT info >/dev/null 2>&1
    else
        redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD info >/dev/null 2>&1
    fi
    if [ $? -ne 0 ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=1
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_py3() {
    echo -ne "Py3    Check \t........................ "
    if [ ! -d "$install_dir/py3" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=1
    else
        if [ -f "$PROJECT_DIR/$Version/core_flag" ]; then
            echo -e "[\033[31m ERROR \033[0m]"
            flag=1
        fi
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_core() {
    echo -ne "Core   Check \t........................ "
    if [ ! "$(systemctl status jms_core | grep Active | grep running)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=1
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_nginx() {
    echo -ne "Ninx   Check \t........................ "
    if [ ! "$(systemctl status nginx | grep Active | grep running)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
        flag=1
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_koko() {
    echo -ne "Koko   Check \t........................ "
    if [ ! "$(docker ps | grep jms_koko)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_guacamole() {
    echo -ne "Guaca. Check \t........................ "
    if [ ! "$(docker ps | grep jms_guacamole)" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_8080() {
    echo -ne "8080   Check \t........................ "
    if [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://127.0.0.1:8080)" != "302" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_5000() {
    echo -ne "5000   Check \t........................ "
    if [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://127.0.0.1:5000)" != "404" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_8081() {
    echo -ne "8081   Check \t........................ "
    if [ "$(curl -I -m 10 -o /dev/null -s -w %{http_code} http://127.0.0.1:5000)" != "404" ]; then
        echo -e "[\033[31m ERROR \033[0m]"
    else
        echo -e "[\033[32m OK \033[0m]"
    fi
}

function check_80() {
    echo -ne "80     Check \t........................ "
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
    check_nginx
    check_py3
    check_core
    check_koko
    check_guacamole
    check_8080
    check_5000
    check_8081
    check_80

    if [ $flag -eq 1 ]; then
      echo -e "[\033[31m ERROR \033[0m] 部分组件安装失败，请查阅上述检测结果"
      echo -e "[ Tip ] 你可以尝试重新执行 ./jmsctl.sh install 来继续尝试 \n"
      exit 1
    fi
}

main
