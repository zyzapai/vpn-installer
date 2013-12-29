一键安装VPN
=============
#选择Centos 32位 VPS
  https://cloud.digitalocean.com/ 最便宜的5美元/月,512M内存,20G SSD硬盘,流量1G/月

#安装
```
yum -y install git
git clone https://github.com/zyzapai/vpn-installer.git
cd vpn-installer
sh centos6_32_install.sh
```

#增加账号和密码
```
vi /etc/ppp/chap-secrets
```

#修改完重启
```
service pptpd restart
```

