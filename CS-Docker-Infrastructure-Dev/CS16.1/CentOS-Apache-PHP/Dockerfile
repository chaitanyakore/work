# References:
#	- https://contentserv.atlassian.net/wiki/spaces/KB/pages/861602082/CS+Installation+Guide+CS16.1+CentOS+RHEL7.X+PHP7

# Build: 
FROM centos:7

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Berlin \
	PHPv=7.1 \
	IMv=6.9.7-10 \
	SSHuser=root \
	SSHpass=root

RUN yum -y update

EXPOSE 80 22

CMD ["/init.sh"]
