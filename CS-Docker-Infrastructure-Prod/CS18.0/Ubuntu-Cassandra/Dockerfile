FROM 	ubuntu:18.04

ENV     DEBIAN_FRONTEND=noninteractive \
        TZ=Europe/Berlin \
        CASSANDRA_PKG_NAME=apache-cassandra-3.11.4 \
        SSHuser=root \
        SSHpass=root

RUN 	groupadd -g 1000 cassandra && useradd cassandra -u 1000 -g 1000 -s /bin/bash -m -d /home/cassandra

RUN 	apt-get update && apt-get upgrade -y && \
	apt-get install -y software-properties-common && \
        apt-get install -y apt-utils && \
        apt-get install -y  wget \
                vim \
                unzip \
                zip \
                openssh-server \
                openssl \
                net-tools \
                sudo && \
        apt-get install apt-transport-https && \
	apt-get install openjdk-8-jdk -y && \
	apt-get install python -y && \
	apt-get install net-tools -y \
		iproute2 -y

RUN     apt-get update && apt-get install zabbix-agent -y

RUN     mkdir /var/run/sshd && \
        echo $SSHuser:$SSHpass | chpasswd && \
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
        echo "export VISIBLE=now" >> /etc/profile

RUN    	mkdir -p /opt/cs/cassandra && \
        cd /opt/cs/cassandra && \
        wget http://apache.claz.org/cassandra/3.11.4/$CASSANDRA_PKG_NAME-bin.tar.gz && \
        tar -xzvf $CASSANDRA_PKG_NAME-bin.tar.gz && \
        mv $CASSANDRA_PKG_NAME cassandra && \
	rm /opt/cs/cassandra/$CASSANDRA_PKG_NAME-bin.tar.gz && \
	mkdir /opt/cs/cassandra/cassandra/logs && \
	mkdir /var/lib/cassandra && \
	mkdir /var/log/cassandra 

COPY 	config/docker-entrypoint.sh /usr/local/bin/
COPY    init.sh /init.sh
COPY    config/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
RUN 	ln -s usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh # backwards compat

RUN  	chown -R cassandra:cassandra /opt/cs/cassandra && \
	chmod 777 /init.sh

RUN 	export CASSANDRA_HOME=~/cassandra && \
	export PATH=$PATH:$CASSANDRA_HOME/bin

WORKDIR /opt/cs/cassandra/cassandra/bin

ENTRYPOINT ["docker-entrypoint.sh"]
CMD 	["/init.sh"]
EXPOSE 	7000 7001 7199 9042 9160
