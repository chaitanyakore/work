FROM ubuntu:xenial
RUN echo 'mysql-server mysql-server/root_password password sqlr00t' | debconf-set-selections
RUN echo 'mysql-server mysql-server/root_password_again password sqlr00t' | debconf-set-selections
RUN echo "deb http://apt.contentserv.intern/ xenial cs-main cs-3rdparty cs-backports" >/etc/apt/sources.list.d/contentserv.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1D6B9779
RUN apt-get -y update && apt-get install -y \
    apache2 \
    barcode \
    cassandra-cpp-driver-dev \
    curl \
    exiftool \
    ffmpeg \
    firefox \
    firefox-locale-de \
    imagemagick \
    libapache2-mod-php \
    libgmp-dev \
    libuv-dev \
    mysql-client \
    mysql-server \
    oracle-java8-jdk \
    php \
    php-bcmath \
    php-bz2 \
    php-cgi \
    php-curl \
    php-dev \
    php-fpm \
    php-gd \
    php-gmp \
    php-http \
    php-intl \
    php-imap \
    php-json \
    php-ldap \
    php-mbstring \
    php-mcrypt \
    php-memcache \
    php-memcached \
    php-mysqlnd \
    php-opcache \
    php-pear \
    php-recode \
    php-soap \
    php-xdebug \
    php-xml \
    php-xsl \
    php-zip \
    poppler-utils \
    python-pip \
    unzip \
    wget \
    xvfb \
    zip

# Some apache tweaks and modules
RUN a2enmod rewrite
RUN a2enmod expires
RUN a2enmod deflate
RUN a2enmod filter
RUN a2enmod status

# Selenium, Robot Framework and other PIP packages
RUN pip install selenium robotframework robotframework-selenium2library crudini

# Install Cassandra via PEAR/PECL
RUN pecl install cassandra

# Enable Cassandra PHP extension
#
RUN printf "; configuration for php common module\n; priority=30\nextension=cassandra.so\n" >/etc/php/7.0/mods-available/cassandra.ini
RUN phpenmod -s ALL cassandra

# Gecko Webdriver for Mozilla
COPY geckodriver /usr/local/bin/geckodriver
RUN chmod 755 /usr/local/bin/geckodriver

# Tweak mysql settings using crudini utility
RUN crudini --set /etc/mysql/mysql.conf.d/mysqld.cnf mysqld lower_case_table_names 1
RUN crudini --set /etc/mysql/mysql.conf.d/mysqld.cnf mysqld query_cache_size 64M

