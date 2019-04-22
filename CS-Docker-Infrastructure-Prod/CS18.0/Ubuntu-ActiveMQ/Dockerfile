FROM    ubuntu:18.04

ENV     DEBIAN_FRONTEND=noninteractive \
        TZ=Europe/Berlin \
        SSHuser=root \
        SSHpass=root \
        ACTIVEMQ_VERSION=5.15.4 \
#        ACTIVEMQ="apache-activemq-$ACTIVEMQ_VERSION" \
        ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161 \
#        SHA512_VAL=26d8154fcfe17ab90508b3b9d46b40815404fa3886cfdc4eae4b06086332203bd2455475b9309ccabd76d0c9b65f523f9d3911d315c17bf4b48bd22395ea8ead \
        ACTIVEMQ_HOME=/opt/cs/activemq/activemq

RUN     ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
        export LANG=C.UTF-8 && \
        apt-get update -y && \
        apt-get install -y software-properties-common && \
        apt-get install -y apt-utils && \
        apt-get update -y && \
	apt-get install -y openjdk-8-jdk && \
        apt-get install -y  wget \
                vim \
                zip \
		wget \
		openssh-server \
                net-tools \
		openssl \
                sudo  

RUN     apt-get update && apt-get install zabbix-agent -y

RUN     mkdir /var/run/sshd && \
        echo $SSHuser:$SSHpass | chpasswd && \
        sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
        sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
        echo "export VISIBLE=now" >> /etc/profile

RUN 	mkdir -p /opt/cs/activemq
RUN     wget "https://archive.apache.org/dist/activemq/5.15.4/apache-activemq-5.15.4-bin.zip" -O /opt/cs/activemq/apache-activemq-5.15.4-bin.zip
#	     "https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz"
# Validate checksum
#RUN     if [ "$SHA512_VAL" != "$(sha512sum $ACTIVEMQ-bin.tar.gz | awk '{print($1)}')" ];\
#        then \
#            echo "sha512 values doesn't match! exiting."  && \
#            exit 1; \
#        fi;
COPY    zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf
RUN     unzip /opt/cs/activemq/apache-activemq-5.15.4-bin.zip && \ 
        mv /apache-activemq-5.15.4 /opt/cs/activemq/activemq  && \
#        ln -s /opt/apache-activemq-5.15.4 /opt/activemq && \
#        useradd -r -M -d /bin/bash activemq && \
#        chown -R activemq:activemq  /opt/activemq && \
        chmod -R 755 /opt/cs/activemq/activemq && \
        rm /opt/cs/activemq/apache-activemq-5.15.4-bin.zip
COPY    conf/docker-entrypoint.sh /usr/local/bin/
COPY    init.sh	/init.sh
COPY	conf/activemq.xml /opt/cs/activemq/activemq/conf/activemq.xml
COPY	conf/credentials.properties /opt/cs/activemq/activemq/conf/credentials.properties
#USER    activemq

WORKDIR $ACTIVEMQ_HOME
EXPOSE  $ACTIVEMQ_TCP $ACTIVEMQ_AMQP $ACTIVEMQ_STOMP $ACTIVEMQ_MQTT $ACTIVEMQ_WS $ACTIVEMQ_UI
#CMD     [ "/opt/cs/activemq/activemq/bin/activemq", "console"]

#CMD     ["/bin/sh", "-c", "bin/activemq console"]
ENTRYPOINT ["docker-entrypoint.sh"]
CMD     ["/init.sh"]
