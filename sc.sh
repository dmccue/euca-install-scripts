tuned-adm profile enterprise-storage
yum install -y eucalyptus-sc
export JVM_MEM_MIN=$(echo "$(grep MemTotal /proc/meminfo | sed -e 's/.* \([0-9]*\) .*/\1/') / 1000000 / 4" | bc)
export JVM_MEM_MAX=$(echo "${JVM_MEM_MIN} * 3" | bc)
export INTERNAL_IP=$(hostname -I | cut -d' ' -f1)
sed -i "s/^\(CLOUD_OPTS\).*/\1=\"--bind-addr=${INTERNAL_IP} -Xms${JVM_MEM_MIN}G -Xmx${JVM_MEM_MAX}G -XX:MaxPermSize=2G -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintPromotionFailure -Xloggc:/var/log/eucalyptus/jvm.log -Xmixed Dcom.sun.management.jmxremote-Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -XX:ReservedCodeCacheSize=512M\"/" /etc/eucalyptus/eucalyptus.conf
# Modify --bind-addr using vi /etc/eucalyptus/eucalyptus.conf
chkconfig eucalyptus-cloud on; service eucalyptus-cloud restart
while [ ! nc -zw1 localhost 8774 ] ; do
  sleep 1
done
