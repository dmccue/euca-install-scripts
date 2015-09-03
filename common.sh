yum clean all
yum install -y libselinux-python tuned ntp epel-release http://downloads.eucalyptus.com/software/eucalyptus/4.1/centos/6/x86_64/eucalyptus-release-4.1.el6.noarch.rpm http://downloads.eucalyptus.com/software/euca2ools/3.2/centos/6/x86_64/euca2ools-release-3.2.el6.noarch.rpm
yum -y update
service iptables stop; chkconfig iptables off
grep CentOS.*6.4 /etc/redhat-release && yum install -y http://mirror.centos.org/centos/6.4/updates/x86_64/Packages/java-1.7.0-openjdk-1.7.0.25-2.3.10.4.el6_4.x86_64.rpm
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
setenforce 0
service ntpd stop 2>/dev/null; ntpdate pool.ntp.org; chkconfig ntpd on; service ntpd restart; sleep 2; ntpq -p; hwclock --systohc
echo "Ansible run: $(date)" > /tmp/ansible.txt
exit 0
