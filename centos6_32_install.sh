#!/bin/bash

echo "begin to install VPN services";
#check wether vps suppot ppp and tun

yum remove -y pptpd ppp
iptables --flush POSTROUTING --table nat
iptables --flush FORWARD
rm -rf /etc/pptpd.conf
rm -rf /etc/ppp

arch=`uname -m`

yum -y install wget make libpcap iptables gcc-c++ logrotate tar cpio perl pam tcp_wrappers

wget http://www.hi-vps.com/downloads/dkms-2.0.17.5-1.noarch.rpm
wget http://www.hi-vps.com/downloads/kernel_ppp_mppe-1.0.2-3dkms.noarch.rpm
wget http://www.hi-vps.com/downloads/pptpd-1.3.4-2.el6.$arch.rpm
wget http://www.hi-vps.com/downloads/ppp-2.4.5-17.0.rhel6.$arch.rpm

rpm -ivh dkms-2.0.17.5-1.noarch.rpm
rpm -ivh kernel_ppp_mppe-1.0.2-3dkms.noarch.rpm
rpm -qa kernel_ppp_mppe
rpm -Uvh ppp-2.4.5-17.0.rhel6.$arch.rpm	
rpm -ivh pptpd-1.3.4-2.el6.$arch.rpm

mknod /dev/ppp c 108 0 
echo 1 > /proc/sys/net/ipv4/ip_forward 
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
echo "echo 1 > /proc/sys/net/ipv4/ip_forward" >> /etc/rc.local
echo "localip 172.16.36.1" >> /etc/pptpd.conf
echo "remoteip 172.16.36.2-254" >> /etc/pptpd.conf
echo "ms-dns 8.8.8.8" >> /etc/ppp/options.pptpd
echo "ms-dns 8.8.4.4" >> /etc/ppp/options.pptpd

echo "vpn pptpd 123456 *" >> /etc/ppp/chap-secrets

iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source `ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk 'NR==1 { print $1}'`
iptables -A FORWARD -p tcp --syn -s 172.16.36.0/24 -j TCPMSS --set-mss 1356
service iptables save

chkconfig iptables on
chkconfig pptpd on

service iptables start
service pptpd start

echo "VPN service is installed, your VPN username is vpn, VPN password is 123456"
	
