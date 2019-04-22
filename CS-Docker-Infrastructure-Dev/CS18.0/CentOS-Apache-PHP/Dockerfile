# References:
#	- https://contentserv.atlassian.net/wiki/spaces/KB/pages/861634811/CS+Installation+Guide+CS17.0+CentOS+PHP7

# Build: 
FROM centos:7

ENV DEBIAN_FRONTEND=noninteractive \
	TZ=Europe/Berlin \
	PHPv=7.1 \
	IMv=6.9.7-10 \
	SSHuser=root \
	SSHpass=root

RUN yum -y update
	yum -y install  yum-utils \
					gcc \
					gcc-c++ \
					subversion \
					git \
					iptables-services \
					httpd
COPY config/selinux /etc/sysconfig/selinux
COPY config/httpd.conf /etc/httpd/conf/httpd.conf
COPY config/90-contentserv.ini /etc/php/$PHPv/apache2/conf.d/

# ImageMagick layer	
RUN yum -y install  bzip2-devel \
					freetype-devel \
					libjpeg-devel \
					libpng-devel \
					libtiff-devel \
					giflib-devel \
					zlib-devel \
					djvulibre-devel \
					libwmf-devel \
					jasper-devel \
					libtool-ltdl-devel \
					libX11-devel \
					libXext-devel \
					libXt-devel \
					lcms-devel \
					libxml2-devel \
					OpenEXR-devel \
					automake \
					cmake \
					libtool \
					openssl-devel \
					gmp \
					gmp-devel \
					boost \
					pcre-devel && \
	cd /opt/ && \
	wget http://www.imagemagick.org/download/releases/ImageMagick-$IMv.tar.xz && \
	tar -xf ImageMagick-$IMv.tar.xz && \
	chmod -R 777 ImageMagick-$IMv && \
	cd ImageMagick-$IMv && \
	./configure && \
	make && \
	make install

# Cassandra layer
RUN yum -y install  automake \
					cmake \
					libtool \
					openssl-devel wget gmp gmp-devel boost php-devel pcre-devel

	cd /opt/

EXPOSE 80 22

CMD ["/init.sh"]
