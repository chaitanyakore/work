# References:
#	- https://contentserv.atlassian.net/wiki/spaces/KB/pages/197728628/CS+Installation+Guide+CS16.1+Linux+PHP7

# Build: 
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Berlin \
	LANG=C.UTF-8 \
	PHPv=7.0 \
	IMv=6.9.4-10 

COPY config/sources.list /etc/apt/sources.list

# System update + Apache layer
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
	apt-get update -y && \
	apt-get install -y  software-properties-common \
						apt-utils \
						apache2 \
						libapache2-mod-fcgid \
						libapache2-mod-gnutls \
#						libapache2-mpm-itk \
						openjdk-8-jdk \
						aspell \
						aspell-af aspell-am aspell-ar aspell-ar-large aspell-bg \
						aspell-bn aspell-br aspell-ca aspell-cs aspell-cy aspell-da \
						aspell-de aspell-de aspell-doc aspell-doc aspell-el aspell-en \
						aspell-eo aspell-es aspell-et aspell-eu aspell-fa aspell-fo \
						aspell-fr aspell-ga aspell-gu aspell-he aspell-hi aspell-hr \
						aspell-hsb aspell-hu aspell-hy aspell-id aspell-is aspell-it \
						aspell-kk aspell-kn aspell-ku aspell-lt aspell-lv aspell-ml \
						aspell-mr aspell-nl aspell-no aspell-nr aspell-ns aspell-or \
						aspell-pa aspell-pl aspell-pt aspell-ro aspell-ru aspell-sk \
						aspell-sl aspell-st aspell-sv aspell-ta aspell-te aspell-tl \
						aspell-tn aspell-ts aspell-uk aspell-uz aspell-xh aspell-zu \
						wget \
						vim \
						barcode \
						catdoc \
						ffmpeg \
						fonts-dejavu-core \
						fonts-dejavu-extra \
						fonts-liberation \
						fonts-lmodern \
						fonts-ubuntu-font-family-console \
						gettext \
						ghostscript \
						intltool-debian \
						javascript-common \
						libimage-exiftool-perl \
						libwmf-bin \
						memcached \
						poppler-utils \
						qrencode \
						redis-server \
						smbclient \
						spellutils \
						subversion-tools \
						tk \
						unzip \
						wngerman \
						xpdf \
						zip \
						net-tools

# PHP layer
RUN add-apt-repository -y -u ppa:ondrej/php && \
	apt-get install -y  php$PHPv \
						php$PHPv-bcmath \
						php$PHPv-bz2 \
						php$PHPv-cgi \
						php$PHPv-common \
						php$PHPv-curl \
						php$PHPv-dev \
						php$PHPv-fpm \
						php$PHPv-gd \
						php$PHPv-gmp \
						php$PHPv-imap \
						php$PHPv-intl \
						php$PHPv-json \
						php$PHPv-ldap \
						php$PHPv-mbstring \
						php$PHPv-mcrypt \
						php$PHPv-mysql \
						php$PHPv-recode \
						php$PHPv-soap \
						php$PHPv-xml \
						php$PHPv-xsl \
						php$PHPv-zip \
						php-http \
						php-imagick \
						php-memcache \
						libapache2-mod-php$PHPv

# ImageMagick layer					
RUN apt-get install -y  build-essential \
						checkinstall \
						libx11-dev \
						libxext-dev \
						zlib1g-dev \
						libpng12-dev \
						libjpeg-dev \
						libfreetype6-dev \
						libxml2-dev && \
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 7EA0A9C3F273FCD8 && \
	apt-get update -y && \
	apt-get build-dep -y imagemagick && \
	cd /opt && \
	wget http://www.imagemagick.org/download/releases/ImageMagick-$IMv.tar.xz && \
	tar -xf ImageMagick-$IMv.tar.xz && \
	chmod -R 777 ImageMagick-$IMv && \
	cd ImageMagick-$IMv && \
	./configure && \
	make && \
	make install

# Cassandra layer
RUN apt-get install -y  libgmp-dev \
						openssl \
						libssl-dev && \
	cd /opt && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.11.0/libuv_1.11.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.11.0/libuv-dev_1.11.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.6.0/cassandra-cpp-driver_2.6.0-1_amd64.deb && \
	wget http://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.6.0/cassandra-cpp-driver-dev_2.6.0-1_amd64.deb && \
	dpkg -i libuv_1.11.0-1_amd64.deb && \
	dpkg -i libuv-dev_1.11.0-1_amd64.deb && \
	dpkg -i cassandra-cpp-driver_2.6.0-1_amd64.deb && \
	dpkg -i cassandra-cpp-driver-dev_2.6.0-1_amd64.deb && \
	pecl install cassandra-1.3.0
COPY config/cassandra.ini /etc/php/$PHPv/mods-available/

# Configure Apache and PHP
COPY config/000-default.conf /etc/apache2/sites-available/
COPY config/90-contentserv.ini /etc/php/$PHPv/apache2/conf.d/
RUN	a2enmod rewrite && \
	a2enmod expires && \
	a2enmod deflate && \
	a2enmod filter && \
	a2enmod status && \
	phpenmod cassandra && \
	phpenmod mcrypt && \ 
	# Register a servername to remove the message "apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.0.2. Set the 'ServerName' directive globally to suppress this message"
	echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf && \
	a2enconf servername && \
	echo 'export PHP_INI_SCAN_DIR=/etc/php/$PHPv/apache2/conf.d:/usr/local/etc/php/conf.d' >> /etc/apache2/envvars

# TODO: checkout from CS SVN admin/ and admin.local/ into /var/www/

COPY init.sh /init.sh

RUN chmod 755 /*.sh && \
	/bin/bash /etc/apache2/envvars && \ 
	chmod +x /etc/apache2/envvars && \
	## Cleanups
	rm -Rf /opt/* && \
	apt-get clean

EXPOSE 80

CMD ["/init.sh"]
