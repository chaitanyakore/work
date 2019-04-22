default: build-all

build-all: build-ubuntu build-mariadb build-cassandra

build-ubuntu:
	docker build --force-rm -t docker.contentserv.com/cs-dev/ubuntu-apache-php:CS17.0 Ubuntu-Apache-PHP/

build-mariadb:
	docker build --force-rm -t docker.contentserv.com/cs-dev/mariadb:CS17.0 MariaDB/

build-cassandra:
	docker build --force-rm -t docker.contentserv.com/cs-dev/cassandra:CS17.0 Cassandra/

push-all: push-ubuntu push-mariadb push-cassandra

push-ubuntu:
	docker push docker.contentserv.com/cs-dev/ubuntu-apache-php:CS17.0

push-mariadb:
	docker push docker.contentserv.com/cs-dev/mariadb:CS17.0

push-cassandra:
	docker push docker.contentserv.com/cs-dev/cassandra:CS17.0
