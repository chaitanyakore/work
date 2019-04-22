default: build-all

build-all: build-ubuntu build-mariadb build-mysql build-cassandra build-elasticsearch build-pdfreactor

build-ubuntu:
	docker build --force-rm -t docker.contentserv.com/cs-dev/ubuntu-apache-php:CS19.0 Ubuntu-Apache-PHP/

build-mariadb:
	docker build --force-rm -t docker.contentserv.com/cs-dev/mariadb:CS19.0 MariaDB/

build-mysql:
	docker build --force-rm -t docker.contentserv.com/cs-dev/mysql:CS19.0 MySQL/

build-cassandra:
	docker build --force-rm -t docker.contentserv.com/cs-dev/cassandra:CS19.0 Cassandra/

build-elasticsearch:
	docker build --force-rm -t docker.contentserv.com/cs-dev/elasticsearch:CS19.0 ElasticSearch/

build-pdfreactor:
	docker build --force-rm -t docker.contentserv.com/cs-dev/pdfreactor:CS19.0 PDFReactor/

push-all: push-ubuntu push-mariadb push-mysql push-cassandra push-elasticsearch push-pdfreactor

push-ubuntu:
	docker push docker.contentserv.com/cs-dev/ubuntu-apache-php:CS19.0

push-mariadb:
	docker push docker.contentserv.com/cs-dev/mariadb:CS19.0

push-mysql:
	docker push docker.contentserv.com/cs-dev/mysql:CS19.0

push-cassandra:
	docker push docker.contentserv.com/cs-dev/cassandra:CS19.0

push-elasticsearch:
	docker push docker.contentserv.com/cs-dev/elasticsearch:CS19.0

push-pdfreactor:
	docker push docker.contentserv.com/cs-dev/pdfreactor:CS19.0
