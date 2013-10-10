一键安装VPN
=============
###安装
```
yum -y install git
cd vpn-installer
sh centos6_32_install.sh
```

###增加账号和密码
```
vi /etc/ppp/chap-secrets
```
修改完重启
```
service pptpd restart
```

