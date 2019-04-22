FROM 	ubuntu:18.04

ENV 	DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Berlin \
        SSHuser=root \
        SSHpass=root

RUN 	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
	export LANG=C.UTF-8 && \
	apt-get update -y && \
	apt-get install -y software-properties-common && \
	apt-get install -y apt-utils && \
	apt-get update -y && \
	apt-get install -y  wget \
		vim \
		unzip \
		zip \
		openssh-server \
		openssl \
		sudo \
		libgmp-dev \
		libssl-dev \
		expect \
		php-pear

RUN     apt-get update && apt-get install zabbix-agent -y

RUN     mkdir /var/run/sshd && \
        echo $SSHuser:$SSHpass | chpasswd && \
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
        echo "export VISIBLE=now" >> /etc/profile

RUN \
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 && \
	add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://ftp.utexas.edu/mariadb/repo/10.3/ubuntu bionic main' && \
	apt update && \
#	apt install mysql-server -y
	apt install mariadb-server -y
#RUN     service mysql start

COPY    init.sh /init.sh 
COPY    config/docker-entrypoint.sh /usr/local/bin/
COPY 	config/setpass.sh /setpass.sh 
COPY 	config/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
COPY 	config/my.cnf /etc/mysql/my.cnf

RUN     chmod 777 /init.sh  && \
	chmod 777 /setpass.sh

RUN     /etc/init.d/mysql start && \
        sh /setpass.sh
#CMD ["/init.sh"]

EXPOSE 	3306
#CMD	["mysqld"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD    ["/init.sh"]

