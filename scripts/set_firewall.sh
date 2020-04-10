#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

function set_firewall() {
    if [ ! "$(firewall-cmd --list-all | grep $http_port)" ]; then
        firewall-cmd --zone=public --add-port=$http_port/tcp --permanent
        firewall-cmd --reload
    fi
    if [ ! "$(firewall-cmd --list-all | grep $ssh_port)" ]; then
        firewall-cmd --zone=public --add-port=$ssh_port/tcp --permanent
        firewall-cmd --reload
    fi
}

function set_selinux() {
    if [ ! "$(rpm -qa | grep policycoreutils-python)" ]; then
          yum install -y policycoreutils-python
    fi
    setsebool -P httpd_can_network_connect 1
    if [ "$http_port" != "80" ]; then
        semanage port -m -t http_port_t -p tcp $http_port || true
    fi
}

function main() {
    if [ "$(systemctl status firewalld | grep Active | grep running)" ]; then
        set_firewall
    fi
    if [ "$(getenforce)" != "Disabled" ]; then
        set_selinux
    fi
}

main
