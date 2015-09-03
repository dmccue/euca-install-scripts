export EXTERNALNIC=em1
export INTERNALNIC=em2
export BRIDGENIC=br0
export INTERNALIP=10.112.26.207
export INTERNALMASK=255.255.255.192
tuned-adm profile enterprise-storage
yum install -y eucalyptus-nc eucanetd bridge-utils
modprobe bridge && echo modprobe bridge >> /etc/rc.modules && chmod +x /etc/rc.modules
sed -i 's/^\(net.ipv4.ip_forward\).*/\1 = 1/' /etc/sysctl.conf
sed -i '/^net.bridge.bridge-nf-call-iptables.*/d' /etc/sysctl.conf; echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
sysctl -p | grep 'net.ipv4.ip_forward\|net.bridge.bridge-nf-call-iptables'
  
mkdir -p /tmp/netcfg; cp /etc/sysconfig/network-scripts/ifcfg-* /tmp/netcfg
 
echo "DEVICE=$INTERNALNIC
ONBOOT=yes
BRIDGE=${BRIDGENIC}
NOZEROCONF=true
NM_CONTROLLED=no
BONDING_OPTS=\"mode=4 miimon=100 downdelay=0 updelay=0 lacp_rate=fast xmit_hash_policy=1\"
" > /etc/sysconfig/network-scripts/ifcfg-${INTERNALNIC}
 
echo "DEVICE=${BRIDGENIC}
TYPE=Bridge
BOOTPROTO=static
HWADDR=$(cat /sys/class/net/${INTERNALNIC}/address)
IPADDR=${INTERNALIP}
NETMASK=${INTERNALMASK}
NOZEROCONF=true
ONBOOT=yes
NM_CONTROLLED=no
DELAY=0
" > /etc/sysconfig/network-scripts/ifcfg-${BRIDGENIC}
grep ^.* /etc/sysconfig/network-scripts/ifcfg-*
service network restart

grep 'VNET_MODE=\|VNET_PUBINTERFACE=\|VNET_PRIVINTERFACE=\|VNET_BRIDGE=' /etc/eucalyptus/eucalyptus.conf
sed -i "s/^\(VNET_MODE=\).*/\1EDGE/" /etc/eucalyptus/eucalyptus.conf
sed -i "s/^\(VNET_PUBINTERFACE=\).*/\1${EXTERNALNIC}/" /etc/eucalyptus/eucalyptus.conf
sed -i "s/^\(VNET_PRIVINTERFACE=\).*/\1${INTERNALNIC}/" /etc/eucalyptus/eucalyptus.conf
sed -i "s/^\(VNET_BRIDGE=\).*/\1${BRIDGENIC}/" /etc/eucalyptus/eucalyptus.conf
echo "METADATA_USE_VM_PRIVATE=\"Y\"" >> /etc/eucalyptus/eucalyptus.conf
echo "#METADATA_IP=\"10.112.26.221\"" >> /etc/eucalyptus/eucalyptus.conf
modprobe kvm_intel || echo ERROR: KVM unable to load
chkconfig dnsmasq off; pkill dnsmasq; chkconfig eucanetd on; chkconfig eucalyptus-nc on
service eucanetd restart; service eucalyptus-nc restart
while [ ! nc -z localhost 8775 ]; do
  sleep 1
done
