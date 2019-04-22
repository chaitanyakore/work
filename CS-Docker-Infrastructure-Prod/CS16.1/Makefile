default: build-all

build-all: build-ubuntu build-centos

build-ubuntu:
	docker build --force-rm -t docker.contentserv.com/cs-dev/ubuntu-apache-php:CS16.1 Ubuntu-Apache-PHP/

push-all: push-ubuntu

push-ubuntu:
	docker push docker.contentserv.com/cs-prod/ubuntu-apache-php:CS16.1