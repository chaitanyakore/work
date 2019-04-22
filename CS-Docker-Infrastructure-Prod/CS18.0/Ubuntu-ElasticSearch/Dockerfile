# References:
# https://contentserv.atlassian.net/wiki/spaces/KB/pages/758185985/CS+Installation+Guide+CS18.0+Linux+PHP7.1
# Build: 
FROM 	ubuntu:18.04

ENV 	DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Berlin \
	ES_PKG_NAME=elasticsearch-6.3.2 \
        SSHuser=root \
        SSHpass=root

RUN 	groupadd -g 1000 elastic && useradd elastic -u 1000 -g 1000 -s /bin/bash
RUN 	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
	export LANG=C.UTF-8 && \
	apt-get update -y && \
	apt-get install -y software-properties-common && \
	apt-get install -y apt-utils && \
	apt-get update -y && \
	apt-get install -y openjdk-8-jdk && \
	apt-get install -y  wget \
		vim \
		unzip \
		zip \
		openssh-server \
		openssl \
		net-tools \
		sudo && \
	apt-get install apt-transport-https

RUN     apt-get update && apt-get install zabbix-agent -y

RUN     mkdir /var/run/sshd && \
        echo $SSHuser:$SSHpass | chpasswd && \
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
        echo "export VISIBLE=now" >> /etc/profile

RUN \
  	mkdir -p /opt/cs/elastic && \
	cd /opt/cs/elastic && \
	wget https://artifacts.elastic.co/downloads/elasticsearch/$ES_PKG_NAME.tar.gz && \
  	tar -xvzf $ES_PKG_NAME.tar.gz && \
	rm -f $ES_PKG_NAME.tar.gz && \
  	mv $ES_PKG_NAME /opt/cs/elastic/elasticsearch

COPY 	config/elasticsearch.yml /opt/cs/elastic/elasticsearch/config/elasticsearch.yml
COPY    config/docker-entrypoint.sh /usr/local/bin/
COPY	init.sh /init.sh
COPY    config/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf

RUN 	mkdir /opt/cs/elastic/elasticsearch/data && \
	chown -R elastic:elastic /opt/cs/elastic && \
	chmod 777 /init.sh
	
WORKDIR /opt/cs/elastic/elasticsearch/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["/init.sh"]

EXPOSE 	9200
EXPOSE 	9300
