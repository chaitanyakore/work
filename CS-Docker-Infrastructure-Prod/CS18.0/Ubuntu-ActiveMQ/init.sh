#!/bin/bash

if [ "$enableZabbixMonitoring" == "yes" ]; then
/etc/init.d/zabbix-agent start
fi
#/opt/activemq/bin/activemq console
/opt/cs/activemq/activemq/bin/activemq console
