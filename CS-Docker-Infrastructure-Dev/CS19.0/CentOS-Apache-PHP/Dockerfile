# References:
#	- https://contentserv.atlassian.net/wiki/spaces/KB/pages/861634811/CS+Installation+Guide+CS17.0+CentOS+PHP7

# Build: 
FROM centos:7

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Berlin \
	PHPv=7.2 \
	IMv=6.9.7-10 \
	SSHuser=root \
	SSHpass=root

RUN yum -y update

EXPOSE 80 22

CMD ["/init.sh"]
