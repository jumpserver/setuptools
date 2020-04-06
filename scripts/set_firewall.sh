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
    if [ ! "$(firewall-cmd --list-all | grep 8080)" ]; then
        firewall-cmd --permanent --add-rich-rule="rule family="ipv4" source address="172.17.0.0/16" port protocol="tcp" port="8080" accept"
        firewall-cmd --reload
    fi
}

function set_selinux() {
    if [ ! "$(rpm -qa | grep policycoreutils-python)" ]; then
          yum -y install policycoreutils-python
    fi
    setsebool -P httpd_can_network_connect 1
    if [ "$http_port" != "80" ]; then
        semanage port -m -t http_port_t -p tcp $http_port || true
    fi
}

function main() {
    if [ "$(systemctl status firewalld | grep running)" ]; then
        set_firewall
    fi
    if [ "$(getenforce)" != "Disabled" ]; then
        set_selinux
    fi
}

main
