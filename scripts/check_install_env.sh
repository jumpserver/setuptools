#!/usr/bin/env bash
#

flag=1

echo -ne "root用户检测 \t\t........................ "
isRoot=`id -u -n | grep root | wc -l`
if [ "x$isRoot" == "x1" ];then
  echo "[OK]"
else
  echo "[ERROR] 请用 root 用户执行安装脚本"
  flag=0
fi

#操作系统检测
echo -ne "操作系统检测 \t\t........................ "
if [ -f /etc/redhat-release ];then
  osVersion=`cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'`
  majorVersion=`echo $osVersion | awk -F. '{print $1}'`
  if [ "x$majorVersion" == "x" ];then
    echo "[ERROR] 操作系统类型版本不符合要求，请使用 CentOS 7 64 位版本"
    flag=0
  else
    if [[ $majorVersion == 7 ]];then
      is64bitArch=`uname -m`
      if [ "x$is64bitArch" == "xx86_64" ];then
         echo "[OK]"
      else
         echo "[ERROR] 操作系统必须是 64 位的，32 位的不支持"
         flag=0
      fi
    else
      echo "[ERROR] 操作系统类型版本不符合要求，请使用 CentOS 7"
      flag=0
    fi
  fi
else
    echo "[ERROR] 操作系统类型版本不符合要求，请使用 CentOS 7"
    flag=0
fi

#CPU检测
echo -ne "CPU检测 \t\t........................ "
processor=`cat /proc/cpuinfo| grep "processor"| wc -l`
if [ $processor -lt 2 ];then
  echo "[ERROR] CPU 小于 2核，JumpServer 所在机器的 CPU 需要至少 2核"
  flag=0
else
  echo "[OK]"
fi

#内存检测
echo -ne "内存检测 \t\t........................ "
memTotal=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
if [ $memTotal -lt 3750000 ];then
  echo "[ERROR] 内存小于 4G，JumpServer 所在机器的内存需要至少 4G"
  flag=0
else
  echo "[OK]"
fi

if [ $flag -eq 0 ]; then
  echo "安装环境检测未通过，请查阅上述环境检测结果"
  exit 1
fi
