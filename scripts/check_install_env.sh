#!/usr/bin/env bash
#

BASE_DIR=$(dirname "$0")
PROJECT_DIR=$(dirname $(cd $(dirname "$0");pwd))
source ${PROJECT_DIR}/config.conf

flag=0

echo -ne "User    Check \t........................ "
isRoot=`id -u -n | grep root | wc -l`
if [ "x$isRoot" == "x1" ]; then
    echo -e "[\033[32m OK \033[0m]"
else
    echo -e "[\033[31m ERROR \033[0m] 请用 root 用户执行安装脚本"
    flag=1
fi

echo -ne "OS      Check \t........................ "
if [ -f /etc/redhat-release ]; then
    osVersion=`cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'`
    majorVersion=`echo $osVersion | awk -F. '{print $1}'`
    if [ "x$majorVersion" == "x" ]; then
        echo -e "[\033[31m ERROR \033[0m] 操作系统类型版本不符合要求，请使用 CentOS 7 64 位版本"
        flag=1
    else
        if [[ $majorVersion == 7 ]]; then
            is64bitArch=`uname -m`
            if [ "x$is64bitArch" == "xx86_64" ]; then
            echo -e "[\033[32m OK \033[0m]"
            else
                echo -e "[\033[31m ERROR \033[0m] 操作系统必须是 64 位的，32 位的不支持"
                flag=1
            fi
        else
            echo -e "[\033[31m ERROR \033[0m] 操作系统类型版本不符合要求，请使用 CentOS 7"
            flag=1
        fi
    fi
else
    echo -e "[\033[31m ERROR \033[0m] 操作系统类型版本不符合要求，请使用 CentOS 7"
    flag=1
fi

echo -ne "CPU     Check \t........................ "
processor=`cat /proc/cpuinfo| grep "processor"| wc -l`
if [ $processor -lt 2 ]; then
    echo -e "[\033[31m ERROR \033[0m] CPU 小于 2核，JumpServer 所在机器的 CPU 需要至少 2核"
    flag=1
else
    echo -e "[\033[32m OK \033[0m]"
fi

echo -ne "Memory  Check \t........................ "
memTotal=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
if [ $memTotal -lt 3750000 ]; then
    echo -e "[\033[31m ERROR \033[0m] 内存小于 4G，JumpServer 所在机器的内存需要至少 4G"
    flag=1
else
    echo -e "[\033[32m OK \033[0m]"
fi

echo -ne "Version Check \t........................ "
if [ "${Version:0:1}" -lt "2" ]; then
    echo -e "[\033[31m ERROR \033[0m] 请安装 JumpServer 2.0.0 以上版本, 不支持旧版本安装"
    flag=1
else
    echo -e "[\033[32m OK \033[0m]"
fi

if [ $flag -eq 1 ]; then
    echo "安装环境检测未通过，请查阅上述环境检测结果"
    exit 1
fi
