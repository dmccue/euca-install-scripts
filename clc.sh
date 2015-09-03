tuned-adm profile latency-performance
yum install -y eucalyptus-cloud nc eucaconsole unzip
export JVM_MEM_MIN=$(echo "$(grep MemTotal /proc/meminfo | sed -e 's/.* \([0-9]*\) .*/\1/') / 1000000 / 4" | bc)
export JVM_MEM_MAX=$(echo "${JVM_MEM_MIN} * 3" | bc)
export INTERNAL_IP=$(hostname -I | cut -d' ' -f1)
sed -i "s/^\(CLOUD_OPTS\).*/\1=\"--bind-addr=${INTERNAL_IP} -Xms${JVM_MEM_MIN}G -Xmx${JVM_MEM_MAX}G -XX:MaxPermSize=2G -XX:+PrintGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintPromotionFailure -Xloggc:/var/log/eucalyptus/jvm.log -Xmixed Dcom.sun.management.jmxremote-Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -XX:ReservedCodeCacheSize=512M\"/" /etc/eucalyptus/eucalyptus.conf
# Modify --bind-addr using vi /etc/eucalyptus/eucalyptus.conf
service eucalyptus-cloud stop; euca_conf --setup; euca_conf --initialize; ls -al /var/lib/eucalyptus/db
chkconfig eucalyptus-cloud on; chkconfig eucaconsole on
service eucalyptus-cloud restart; service eucaconsole restart
ls /var/lib/eucalyptus/keys
