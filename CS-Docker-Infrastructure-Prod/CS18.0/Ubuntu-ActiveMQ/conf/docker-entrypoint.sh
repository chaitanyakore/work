#!/bin/bash
set -e
		sed -i "s/Server=172.17.0.5/Server=${zabbixServer}/g" /etc/zabbix/zabbix_agentd.conf
		sed -i "s/ServerActive=172.17.0.5:10051/ServerActive=${zabbixServer}:10051/g" /etc/zabbix/zabbix_agentd.conf
exec "$@"

