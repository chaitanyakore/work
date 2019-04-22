#!/bin/bash
#exec /opt/cs/elastic/elasticsearch/bin/elasticsearch -Des.insecure.allow.root=true -d  -D FOREGROUND
#source /etc/apache2/envvars
if [ "$enableZabbixMonitoring" == "yes" ]; then
/etc/init.d/zabbix-agent restart
fi
#exec apache2 -D FOREGROUND
#exec /opt/cs/elastic/elasticsearch/bin/elasticsearch -Des.insecure.allow.root=true -d  -D FOREGROUND
su - elastic -s /bin/bash -c " cd /opt/cs/elastic/elasticsearch/bin/ && ./elasticsearch"
