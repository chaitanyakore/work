#!/bin/bash

/usr/sbin/sshd

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
