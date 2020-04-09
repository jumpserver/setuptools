# jms_install
Jumpserver 安装脚本

官方安装文档 http://docs.jumpserver.org

Use:

```
cd /opt
git clone --depth=1 https://github.com/jumpserver/setuptools.git
cd jms_install
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
