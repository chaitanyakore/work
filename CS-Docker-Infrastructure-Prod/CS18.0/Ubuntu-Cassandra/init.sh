#!/bin/bash
if [ "$enableZabbixMonitoring" == "yes" ]; then
/etc/init.d/zabbix-agent restart
fi
su - cassandra -s /bin/bash -c "/opt/cs/cassandra/cassandra/bin/cassandra -f"

