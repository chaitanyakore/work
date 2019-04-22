#!/bin/bash

/usr/sbin/sshd
ldconfig /usr/local/lib

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
