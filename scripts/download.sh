#!/bin/bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function download_core() {
    echo ">> Download Core"
    timeout 60s wget -qO $PROJECT_DIR/$Version/jumpserver-$Version.tar.gz https://github.com/jumpserver/jumpserver/releases/download/$Version/jumpserver-$Version.tar.gz || {
        rm -f $PROJECT_DIR/$Version/jumpserver-$Version.tar.gz
        wget -qO $PROJECT_DIR/$Version/jumpserver-$Version.tar.gz http://demo.jumpserver.org/download/jumpserver/$Version/jumpserver-$Version.tar.gz || {
            rm -f $PROJECT_DIR/$Version/jumpserver-$Version.tar.gz
            echo "[ERROR] 下载 Core 失败"
            exit 1
        }
    }
}

function download_lina() {
    echo ">> Download Lina"
    timeout 60s wget -qO $PROJECT_DIR/$Version/lina-$Version.tar.gz https://github.com/jumpserver/lina/releases/download/$Version/lina-$Version.tar.gz || {
        rm -f $PROJECT_DIR/$Version/lina-$Version.tar.gz
        wget -qO $PROJECT_DIR/$Version/lina-$Version.tar.gz http://demo.jumpserver.org/download/lina/$Version/lina-$Version.tar.gz || {
            rm -f $PROJECT_DIR/$Version/lina-$Version.tar.gz
            echo "[ERROR] 下载 Lina 失败"
            exit 1
        }
    }
}

function download_luna() {
    echo ">> Download Luna"
    timeout 60s wget -qO $PROJECT_DIR/$Version/luna-$Version.tar.gz https://github.com/jumpserver/luna/releases/download/$Version/luna-$Version.tar.gz || {
        rm -f $PROJECT_DIR/$Version/luna-$Version.tar.gz
        wget -qO $PROJECT_DIR/$Version/luna-$Version.tar.gz http://demo.jumpserver.org/download/luna/$Version/luna-$Version.tar.gz || {
            rm -f $PROJECT_DIR/$Version/luna-$Version.tar.gz
            echo "[ERROR] 下载 Luna 失败"
            exit 1
        }
    }
}

function download_koko(){
    echo ">> Download KoKo"
    docker pull jumpserver/jms_koko:$Version || {
        echo "[ERROR] 下载 KoKo 失败"
        exit 1
    }
}

function download_guacamole() {
    echo ">> Download Guacamole"
    docker pull jumpserver/jms_guacamole:$Version || {
        echo "[ERROR] 下载 Guacamole 失败"
        exit 1
    }
}

function main() {
    if [ ! -f "$PROJECT_DIR/$Version/jumpserver-$Version.tar.gz" ]; then
        download_core
    fi
    if [ ! -f "$PROJECT_DIR/$Version/lina-$Version.tar.gz" ]; then
        download_lina
    fi
    if [ ! -f "$PROJECT_DIR/$Version/luna-$Version.tar.gz" ]; then
        download_luna
    fi
    if [ ! "$(docker images | grep jms_koko | grep $Version)" ]; then
        download_koko
    fi
    if [ ! "$(docker images | grep jms_guacamole | grep $Version)" ]; then
        download_guacamole
    fi
}

main
