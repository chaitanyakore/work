FROM ubuntu:xenial
RUN apt-get -y update && apt-get install -y \
    curl \
    firefox \
    python-pip \
    wget \
    xvfb \
    zip

# Selenium, Robot Framework and other PIP packages
RUN pip install selenium robotframework robotframework-selenium2library crudini

# Gecko Webdriver for Mozilla
COPY geckodriver /usr/local/bin/geckodriver
RUN chmod 755 /usr/local/bin/geckodriver
