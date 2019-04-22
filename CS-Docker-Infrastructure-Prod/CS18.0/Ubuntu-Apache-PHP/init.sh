#!/bin/bash

source /etc/apache2/envvars
if [ "$enableZabbixMonitoring" == "yes" ]; then
/etc/init.d/zabbix-agent restart
fi
exec apache2 -D FOREGROUND
