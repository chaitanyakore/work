#!/bin/bash
set -e
_ip_address() {
	ip address | awk '
		$1 == "inet" && $NF != "lo" {
			gsub(/\/.+$/, "", $2)
			print $2
			exit
		}
	'
}
		CASSANDRA_LISTEN_ADDRESS="$(_ip_address)"
                sed -i "s/localhost/${CASSANDRA_LISTEN_ADDRESS}/g" /opt/cs/cassandra/cassandra/conf/cassandra.yaml
                sed -i "s/127.0.0.1/${CASSANDRA_LISTEN_ADDRESS}/g" /opt/cs/cassandra/cassandra/conf/cassandra.yaml

		sed -i "s/Server=172.17.0.5/Server=${zabbixServer}/g" /etc/zabbix/zabbix_agentd.conf
		sed -i "s/ServerActive=172.17.0.5:10051/ServerActive=${zabbixServer}:10051/g" /etc/zabbix/zabbix_agentd.conf
exec "$@"

