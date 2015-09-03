#!/bin/bash

tuned-adm profile latency-performance
yum install -y eucalyptus-cc eucanetd
sed -i 's/^net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/sysctl.conf
sysctl -p
sed -i 's/^\(VNET_MODE\).*/\1="EDGE"/' /etc/eucalyptus/eucalyptus.conf
chkconfig iptables on; service iptables start
pkill dnsmasq; chkconfig eucanetd on; chkconfig eucalyptus-cc on
service eucanetd restart; service eucalyptus-cc restart
