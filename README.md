# JumpServer 安装脚本

安装文档 https://docs.jumpserver.org/zh/master/install/setup_by_fast/

- 全新安装的 Centos7 (7.x)
- 需要连接 互联网
- 使用 root 用户执行

注: 脚本包含 selinux 和 firewalld 处理功能, 可以在 selinux 和 firewalld 开启的情况下正常使用

Use:

```
cd /opt
yum -y install wget git
git clone --depth=1 https://github.com/jumpserver/setuptools.git
cd setuptools
cp config_example.conf config.conf
vi config.conf
./jmsctl.sh -h
```

Install 安装
```
./jmsctl.sh install
```

Uninstall 卸载
```
./jmsctl.sh uninstall
```

Help 帮助
```
./jmsctl.sh -h
```
