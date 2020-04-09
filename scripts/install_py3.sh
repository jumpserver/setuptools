#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function install_python() {
    echo ">> Install Python3.6"
    yum install -y python36 python36-devel
}

function config_py3() {
    python3.6 -m venv $install_dir/py3
    if [ ! -f "~/.pydistutils.cfg" ]; then
        cp $BASE_DIR/pypi/.pydistutils.cfg ~/.pydistutils.cfg
    fi
    if [ ! -f "~/.pip/pip.conf" ]; then
        mkdir -p ~/.pip
        cp $BASE_DIR/pypi/pip.conf ~/.pip/pip.conf
    fi
}

function main() {
    which python3.6 >/dev/null 2>&1
    if [ $? -ne 0 ];then
        install_python
    fi
    if [ ! -d "$install_dir/py3" ]; then
        config_py3
    fi
}

main
