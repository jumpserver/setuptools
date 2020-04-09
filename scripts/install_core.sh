#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function download_core() {
    if [ ! -f "$PROJECT_DIR/$Version/jumpserver.tar.gz" ]; then
        wget -qO $PROJECT_DIR/$Version/jumpserver.tar.gz http://demo.jumpserver.org/download/jumpserver/$Version/jumpserver.tar.gz
    fi
    tar xf $PROJECT_DIR/$Version/jumpserver.tar.gz -C $install_dir/  || {
        rm -rf $PROJECT_DIR/$Version/jumpserver.tar.gz
        rm -rf $install_dir/jumpserver
        echo "[ERROR] 下载 jumpserver 失败"
    }

}

function prepare_install() {
    yum install -y $(cat $install_dir/jumpserver/requirements/rpm_requirements.txt) || {
        echo > $PROJECT_DIR/$Version/core_flag
    }
    source $install_dir/py3/bin/activate
    pip install wheel
    pip install --upgrade pip setuptools
    pip install -r $install_dir/jumpserver/requirements/requirements.txt
    if [ $? -ne 0 ];then
        echo > $PROJECT_DIR/$Version/core_flag
        echo "[ERROR] python 依赖安装失败"
    else
        rm -rf $PROJECT_DIR/$Version/core_flag
        deactivate
    fi
}

function config_core() {
    if [ ! "$SECRET_KEY" ]; then
        SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`
        sed -i "0,/SECRET_KEY=/s//SECRET_KEY=$SECRET_KEY/" $PROJECT_DIR/config.conf
    fi
    if [ ! "$BOOTSTRAP_TOKEN" ]; then
        BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`
        sed -i "0,/BOOTSTRAP_TOKEN=/s//BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN/" $PROJECT_DIR/config.conf
    fi
    if [ ! "$Server_IP" ]; then
        Server_IP=`ip addr | grep 'state UP' -A2 | grep inet | egrep -v '(127.0.0.1|inet6|docker)' | awk '{print $2}' | tr -d "addr:" | head -n 1 | cut -d / -f1`
    fi
    cp $install_dir/jumpserver/config_example.yml $install_dir/jumpserver/config.yml
    sed -i "s/SECRET_KEY:/SECRET_KEY: $SECRET_KEY/g" $install_dir/jumpserver/config.yml
    sed -i "s/BOOTSTRAP_TOKEN:/BOOTSTRAP_TOKEN: $BOOTSTRAP_TOKEN/g" $install_dir/jumpserver/config.yml
    sed -i "s/# DEBUG: true/DEBUG: false/g" $install_dir/jumpserver/config.yml
    sed -i "s/# LOG_LEVEL: DEBUG/LOG_LEVEL: ERROR/g" $install_dir/jumpserver/config.yml
    sed -i "s/# SESSION_EXPIRE_AT_BROWSER_CLOSE: false/SESSION_EXPIRE_AT_BROWSER_CLOSE: true/g" $install_dir/jumpserver/config.yml
    sed -i "s/DB_HOST: 127.0.0.1/DB_HOST: $DB_HOST/g" $install_dir/jumpserver/config.yml
    sed -i "s/DB_PORT: 3306/DB_PORT: $DB_PORT/g" $install_dir/jumpserver/config.yml
    sed -i "s/DB_USER: jumpserver/DB_USER: $DB_USER/g" $install_dir/jumpserver/config.yml
    sed -i "s/DB_PASSWORD: /DB_PASSWORD: $DB_PASSWORD/g" $install_dir/jumpserver/config.yml
    sed -i "s/DB_NAME: jumpserver/DB_NAME: $DB_NAME/g" $install_dir/jumpserver/config.yml
    sed -i "s/REDIS_HOST: 127.0.0.1/REDIS_HOST: $REDIS_HOST/g" $install_dir/jumpserver/config.yml
    sed -i "s/REDIS_PORT: 6379/REDIS_PORT: $REDIS_PORT/g" $install_dir/jumpserver/config.yml
    sed -i "s/# REDIS_PASSWORD: /REDIS_PASSWORD: $REDIS_PASSWORD/g" $install_dir/jumpserver/config.yml
    sed -i "s/# WINDOWS_SKIP_ALL_MANUAL_PASSWORD: False/WINDOWS_SKIP_ALL_MANUAL_PASSWORD: True/g" $install_dir/jumpserver/config.yml
}

function config_systemd() {
    cp $BASE_DIR/service/jms_core.service /usr/lib/systemd/system/
    if [ $install_dir != "/opt" ]; then
        sed -i "s@/opt@$install_dir@g" /usr/lib/systemd/system/jms_core.service
    fi
    if [ $DB_HOST != 127.0.0.1 ]; then
        sed -i "s/mariadb.service //g" /usr/lib/systemd/system/jms_core.service
    fi
    if [ $REDIS_HOST != 127.0.0.1 ]; then
        sed -i "s/redis.service //g" /usr/lib/systemd/system/jms_core.service
    fi
    systemctl daemon-reload
}

function start_core() {
    systemctl enable jms_core
    systemctl start jms_core
}

function install_core() {
    echo ">> Install Jms_core"
    download_core
    prepare_install
}

function main() {
    if [ ! -d "$install_dir/jumpserver" ]; then
        install_core
    fi
    if [ ! -f "$install_dir/jumpserver/config.yml" ]; then
        config_core
    fi
    if [ -f "$PROJECT_DIR/$Version/core_flag" ]; then
        prepare_install
    fi
    if [ ! -f "/usr/lib/systemd/system/jms_core.service" ]; then
        config_systemd
    fi
    if [ ! "$(systemctl status jms_core | grep running)" ]; then
        start_core
    fi
}

main
