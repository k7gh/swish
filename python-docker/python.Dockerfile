# use Ubuntu 20.04 base image
FROM ubuntu:20.04

###############################################################################
#                      Global
###############################################################################

# run as root user
USER root
ENV DEBIAN_FRONTEND noninteractive

# Configure environment
ENV SHELL=/bin/bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

###############################################################################
#                      System
###############################################################################

# Install OS packages
# r-cran-nloptr is installed here because it is required for R package ez but will not install via R command line
RUN apt-get update && apt-get install -y \
    apt-utils \
    wget \
    ca-certificates \
    locales \
    fonts-liberation \
    libzmq3-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    virtualenv \
    r-cran-nloptr \
    curl \
    libio-socket-ssl-perl \
    libnet-ssleay-perl

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

###############################################################################
#                      Python 3 packages
###############################################################################

# Install pip package manager
RUN apt-get update \
    && apt-get install -y python3-pip python3-dev python-setuptools libsndfile-dev


COPY requirements.txt /tmp/

RUN pip3 install --requirement /tmp/requirements.txt

###############################################################################
#                      R packages
###############################################################################

# Install R
RUN apt-get install r-base-dev \
	&& apt-get clean \
	&& apt-get remove \
	&& rm -rf /var/lib/apt/lists/*
