#### GeoServer Installation Demo
#### Author: Mike Zhou
#### Email: youz@ualberta.ca
#### Date: Nov 4, 2022

### Introduction
##  This file demonstrates how to install GeoServer in a Linux Docker container.
##  The container can then be deployed to AWS ECS to run dynamic number of
##  instances.
##
##  Here are a few assumptions:
##
##  1. This code uses ubuntu 18.04 as the base image, because 18.04 is a stable
##  linux OS and is widely used.
##  2. For efficiency and clarity reasons this file only installs the minimal
##  dependencies that GeoServer requires. Additional dependencies can be easily
##  installed through the apt-get commands. (Sorry I'm not very familiar with
##  GeoServer's dependencies)
##  3. For clarity I only installed one extension (i.e. MySQL), because
##  GeoServer has too many extensions. The other extensions should be installed
##  in a similar manner
##  4. The code is learnt from GeoServer's official site at:
##  https://docs.geoserver.org/latest/en/user/installation/linux.html



###################################
## Main Docker Code Begins Here ###
###################################

## step 1: download the ubuntu 18.04 base image

FROM ubuntu:18.04

## step 2: setup environmental and configuration variables

# NOTE: we can modify installation configurations here

# this is where the server executables will be installed and invoked
ENV SERVER_ROOT /var/www/geoserver

# this is where the GeoServer executable can be downloaded.
# please note: I found some of the official download links were broken, so I
# decided to store a local copy in a S3 bucket in case it won't build when you
# test
ENV GEOSERVER_EXEC_URL https://geoserver-demo.s3.us-west-2.amazonaws.com/geoserver-2.21.2-bin.zip
ENV MYSQL_EXT_URL https://build.geoserver.org/geoserver/main/ext-latest/geoserver-2.23-SNAPSHOT-mysql-plugin.zip

# this image attached label is used to find the original author to contact
# if someone needs to do so but can't find this Dockerfile
LABEL maintainer="youz@ualberta.ca"

## step 3: update OS and install dependencies

RUN apt-get update && apt-get upgrade -y
RUN apt-get install wget unzip curl default-jre  -y

RUN mkdir -p /mnt/efs_data
# root is the default user
# RUN chown -R app_user:app_user /mnt/efs_data
VOLUME /mnt/efs_data

## step 4: download and install GeoServer

RUN mkdir -p $SERVER_ROOT
WORKDIR $SERVER_ROOT
RUN wget $GEOSERVER_EXEC_URL -O geoserver.zip
RUN unzip geoserver.zip
RUN rm geoserver.zip

## step 4.1 install MySQL adaptor as an example of package installation
RUN wget $MYSQL_EXT_URL -O mysql_ext.zip
RUN unzip mysql_ext.zip -d ./mysql_ext
RUN cp mysql_ext/*.jar webapps/geoserver/WEB-INF/lib/.
RUN rm -rf mysql_ext mysql_ext.zip

## step 5: expose Docker port and entry point
EXPOSE 80 8080
ENTRYPOINT ["/var/www/geoserver/bin/startup.sh"]


### END OF THE FILE ###
