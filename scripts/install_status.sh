BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function check_mysql() {
    echo -ne "\033[35m MySQL 账户检测 \t........................ \033[0m"
    mysql -h$DB_HOST -P$DB_PORT -u$DB_USER -p$DB_PASSWORD -e "use $DB_NAME;" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR]"
    else
        echo "[OK]"
    fi
}

function check_redis() {
    echo -ne "\033[35m Redis 账户检测 \t........................ \033[0m"
    if [ ! "$REDIS_PASSWORD" ]; then
        redis-cli -h $REDIS_HOST -p $REDIS_PORT info >/dev/null 2>&1
    else
        redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD info >/dev/null 2>&1
    fi
    if [ $? -ne 0 ]; then
        echo "[ERROR]"
    else
        echo "[OK]"
    fi
}

function check_py3() {
    echo -ne "\033[35m Python3 环境检测 \t........................ \033[0m"
    if [ ! -d "$install_dir/py3" ]; then
        echo "[ERROR]"
        bash $BASE_DIR/install_py3.sh >/dev/null 2>&1
    else
        echo "[OK]"
    fi
}


function check_core() {
    echo -ne "\033[35m Jms_core 启动检测 \t........................ \033[0m"
    if [ ! "$(systemctl status jms_core | grep running)" ]; then
        echo "[ERROR]"
        echo > $PROJECT_DIR/$Version/core_flag
        bash $BASE_DIR/install_core.sh >/dev/null 2>&1
    else
        echo "[OK]"
    fi
}

function check_koko() {
    echo -ne "\033[35m Jms_koko 启动检测 \t........................ \033[0m"
    if [ "$(docker ps | grep jms_koko)" ]; then
        echo "[ERROR]"
        bash $BASE_DIR/install_koko.sh >/dev/null 2>&1
    else
        echo "[OK]"
    fi
}

function check_guacamole() {
    echo -ne "\033[35m Jms_guacamole 检测 \t........................ \033[0m"
    if [ "$(docker ps | grep jms_guacamole)" ]; then
        echo "[ERROR]"
        bash $BASE_DIR/install_guacamole.sh >/dev/null 2>&1
    else
        echo "[OK]"
    fi
}

function check_nginx() {
    echo -ne "\033[35m Nginx 启动检测 \t\t........................ \033[0m"
    if [ ! "$(systemctl status nginx | grep running)" ]; then
        echo "[ERROR]"
        bash $BASE_DIR/install_nginx.sh >/dev/null 2>&1
        systemctl restart nginx
    else
        echo "[OK]"
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
}

main
