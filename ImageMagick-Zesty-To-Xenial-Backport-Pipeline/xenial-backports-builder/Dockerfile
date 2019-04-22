FROM ubuntu:xenial

# Overwrite default /etc/apt/sources.list with correct one
COPY sources.list /etc/apt/sources.list

RUN apt-get -y update && apt-get install -y \
  build-essential \
  fakeroot \
  devscripts \
  git \
  subversion \
  equivs \
  dh-exec \
  libjs-bootstrap \
  libtool-bin

# this build machine is dedicated for imagemagick 
RUN apt-get -y build-dep imagemagick

# debhelper >= 10
RUN apt-get -y install -t xenial-backports debhelper

# Build process should not be be started under root user, so using jenkins (UID 5000) instead
RUN useradd -c "Mr. Jenkins" -u 5000 -s /bin/bash -d /home/jenkins jenkins
RUN mkdir /home/jenkins
RUN chown jenkins:jenkins /home/jenkins

USER jenkins
