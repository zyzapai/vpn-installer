#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cur_dir=`pwd`

yum remove -y pptpd ppp
iptables --flush POSTROUTING --table nat
iptables --flush FORWARD
rm -f /etc/pptpd.conf
rm -rf /etc/ppp
arch=`uname -m`

if [ -s pptpd-1.3.4-2.el6.$arch.rpm ]; then
  echo "pptpd-1.3.4-2.el6.$arch.rpm [found]"
else
  echo "pptpd-1.3.4-2.el6.$arch.rpm not found!!!download now......"
  if ! wget http://lamp.teddysun.com/files/pptpd-1.3.4-2.el6.$arch.rpm;then
    echo "Failed to download pptpd-1.3.4-2.el6.$arch.rpm,please download it to $cur_dir directory manually and rerun the install script."
    exit 1
  fi
fi

yum -y install net-tools make libpcap iptables gcc-c++ logrotate tar cpio perl pam tcp_wrappers dkms ppp
rpm -ivh pptpd-1.3.4-2.el6.$arch.rpm

rm -f /dev/ppp
mknod /dev/ppp c 108 0
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
echo "localip 192.168.8.1" >> /etc/pptpd.conf
echo "remoteip 192.168.8.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd

echo "vpn pptpd 123456 *" >> /etc/ppp/chap-secrets

iptables -t nat -A POSTROUTING -s 192.168.8.0/24 -j SNAT --to-source `ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
iptables -A FORWARD -p tcp --syn -s 192.168.8.0/24 -j TCPMSS --set-mss 1356
service iptables save
chkconfig --add pptpd
chkconfig pptpd on
service iptables restart
service pptpd start

echo "VPN service is installed, your VPN username is vpn, VPN password is 123456"

exit 0
