#!/bin/bash

VHOST=/etc/apache2/sites-enabled/default.conf
APACHE_LOG_DIR=${WORKSPACE}/apache-logs

echo "Using ${WORKSPACE}/www/ as DocumentRoot for the vhost..."

echo "Setting permissions"

if ! (chown -R www-data:www-data "${WORKSPACE}/www/") ;
then
    echo "Unable to change the directory owner"
    exit 1
fi

echo "Overwriting Apache default vhost file..."

if ! (rm -f /etc/apache2/sites-enabled/*.conf) ;
then
    echo "Unable to remove default vhost(s) file/symlink"
    exit 1
fi

VHOSTCONF="<VirtualHost *:80>
    DocumentRoot \"${WORKSPACE}/www/\"
    ErrorLog \"${APACHE_LOG_DIR}/cs-error.log\"
    CustomLog \"${APACHE_LOG_DIR}/cs-access.log\" combined
    <Directory \"${WORKSPACE}/www/\">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>"

printf "Writing configuration: \n $VHOSTCONF"

if ! (printf "$VHOSTCONF\n" >$VHOST) ;
then
    echo "Unable to write the vhost file for Apache"
    exit 1
fi

