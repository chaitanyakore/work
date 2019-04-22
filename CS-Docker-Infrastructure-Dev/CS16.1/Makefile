default: build-all

build-all: build-ubuntu build-mariadb

build-ubuntu:
	docker build --force-rm -t docker.contentserv.com/cs-dev/ubuntu-apache-php:CS16.1 Ubuntu-Apache-PHP/

build-mariadb:
	docker build --force-rm -t docker.contentserv.com/cs-dev/mariadb:CS16.1 MariaDB/

push-all: push-ubuntu push-mariadb

push-ubuntu:
	docker push docker.contentserv.com/cs-dev/ubuntu-apache-php:CS16.1

push-mariadb:
	docker push docker.contentserv.com/cs-dev/mariadb:CS16.1
