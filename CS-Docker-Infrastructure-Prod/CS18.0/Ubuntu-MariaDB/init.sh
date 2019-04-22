#!/bin/bash
if [ "$enableZabbixMonitoring" == "yes" ]; then
/etc/init.d/zabbix-agent restart
fi
mysqld
