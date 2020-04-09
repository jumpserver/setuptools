#!/usr/bin/env bash
#

BASE_DIR=$(cd "$(dirname "$0")";pwd)
PROJECT_DIR=${BASE_DIR}
SCRIPT_DIR=${BASE_DIR}/scripts
action=$1

if [ ! -f "$PROJECT_DIR/config.conf" ]; then
    echo -e "Error: No config file found."
    echo -e "You can run 'cp config_example.conf config.conf', and edit it."
    exit 1
fi

source ${PROJECT_DIR}/config.conf

function usage() {
   echo "JumpServer 部署安装脚本"
   echo
   echo "Usage: "
   echo "  jmsctl [COMMAND] ..."
   echo "  jmsctl -h --help"
   echo
   echo "Commands: "
   echo "  install   安装 JumpServer"
   echo "  start     启动 JumpServer"
   echo "  stop      停止 JumpServer"
   echo "  restart   重启 JumpServer"
   echo "  status    检查 JumpServer"
   echo "  uninstall 卸载 JumpServer"
   echo "  upgrade   升级 JumpServer"
}

function main() {
   case "${action}" in
      install)
         bash ${SCRIPT_DIR}/install.sh
         ;;
      uninstall)
         bash ${SCRIPT_DIR}/uninstall.sh
         ;;
      upgrade)
         bash ${SCRIPT_DIR}/upgrade.sh
         ;;
      start)
         bash ${SCRIPT_DIR}/start.sh
         ;;
      stop)
         bash ${SCRIPT_DIR}/stop.sh
         ;;
      restart)
         bash ${SCRIPT_DIR}/stop.sh
         bash ${SCRIPT_DIR}/start.sh
         ;;
      status)
         bash ${SCRIPT_DIR}/install_status.sh
         ;;
      --help)
         usage
         ;;
      -h)
         usage
         ;;
      *)
         echo -e "jmsctl: unknown option: '$action'"
         echo -e "See 'jmsctl --help' \n"
         usage
    esac
}

main
