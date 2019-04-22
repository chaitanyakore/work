default: build-all

build-all: build-ubuntu build-mariadb build-mysql build-cassandra build-elasticsearch build-pdfreactor build-latest

build-ubuntu:
	docker build --force-rm -t docker.contentserv.com/cs-dev/ubuntu-apache-php:CS18.0 Ubuntu-Apache-PHP/

build-mariadb:
	docker build --force-rm -t docker.contentserv.com/cs-dev/mariadb:CS18.0 MariaDB/

build-mysql:
	docker build --force-rm -t docker.contentserv.com/cs-dev/mysql:CS18.0 MySQL/

build-cassandra:
	docker build --force-rm -t docker.contentserv.com/cs-dev/cassandra:CS18.0 Cassandra/

build-elasticsearch:
	docker build --force-rm -t docker.contentserv.com/cs-dev/elasticsearch:CS18.0 ElasticSearch/

build-pdfreactor:
	docker build --force-rm -t docker.contentserv.com/cs-dev/pdfreactor:CS18.0 PDFReactor/

build-latest:
	docker tag docker.contentserv.com/cs-dev/ubuntu-apache-php:CS18.0 docker.contentserv.com/cs-dev/ubuntu-apache-php:latest
	docker tag docker.contentserv.com/cs-dev/mariadb:CS18.0 docker.contentserv.com/cs-dev/mariadb:latest
	docker tag docker.contentserv.com/cs-dev/mysql:CS18.0 docker.contentserv.com/cs-dev/mysql:latest

push-all: push-ubuntu push-mariadb push-mysql push-cassandra push-elasticsearch push-pdfreactor push-latest

push-ubuntu:
	docker push docker.contentserv.com/cs-dev/ubuntu-apache-php:CS18.0

push-mariadb:
	docker push docker.contentserv.com/cs-dev/mariadb:CS18.0

push-mysql:
	docker push docker.contentserv.com/cs-dev/mysql:CS18.0

push-cassandra:
	docker push docker.contentserv.com/cs-dev/cassandra:CS18.0

push-elasticsearch:
	docker push docker.contentserv.com/cs-dev/elasticsearch:CS18.0

push-pdfreactor:
	docker push docker.contentserv.com/cs-dev/pdfreactor:CS18.0

push-latest:
	docker push docker.contentserv.com/cs-dev/ubuntu-apache-php:latest
	docker push docker.contentserv.com/cs-dev/mariadb:latest
	docker push docker.contentserv.com/cs-dev/mysql:latest
