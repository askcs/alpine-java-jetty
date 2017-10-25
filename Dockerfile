# This Dockerfile is a combination of previous Docker images that build on top of each other:
# askcs/ubuntu > askcs/java > askcs/jetty
#
# Now, we want to base on the Alpine project, but (probably?) still need the configuration of the previous Docker fiels

FROM openjdk:7-jre-alpine

#
# From askcs/ubuntu
#

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# 
# From askcs/java
#

# Define working directory.
WORKDIR /data

# JAVA_HOME was always set in in askcs/java (https://github.com/askcs/java-docker/blob/master/Dockerfile#L13),
# but is now already set by the 'openjdk:7-jre-alpine' image (https://github.com/docker-library/openjdk/blob/master/7-jre/alpine/Dockerfile#L31)

# Define default command.
CMD ["bash"]

#
# From askcs/jetty
#

# Install packages
RUN apt-get update && \ 
    apt-get update --fix-missing && \ 
    apt-get install -y wget

# Download and install jetty
ENV JETTY_VERSION 9.2.7
ENV RELEASE_DATE v20150116
RUN wget http://archive.eclipse.org/jetty/${JETTY_VERSION}.${RELEASE_DATE}/dist/jetty-distribution-${JETTY_VERSION}.${RELEASE_DATE}.tar.gz && \
    tar -xzvf jetty-distribution-${JETTY_VERSION}.${RELEASE_DATE}.tar.gz && \
    rm -rf jetty-distribution-${JETTY_VERSION}.${RELEASE_DATE}.tar.gz && \
    mv jetty-distribution-${JETTY_VERSION}.${RELEASE_DATE}/ /opt/jetty

# Configure Jetty user and clean up install
RUN useradd jetty && \
    chown -R jetty:jetty /opt/jetty && \
    rm -rf /opt/jetty/webapps.demo

RUN cp /opt/jetty/bin/jetty.sh /etc/init.d/jetty

COPY jetty.xml /opt/jetty/etc/jetty.xml

RUN echo "NO_START=0 # Start on boot\nJETTY_HOST=0.0.0.0 # Listen to all hosts\nJETTY_ARGS=jetty.port=8080\nJETTY_USER=jetty # Run as this user\n JETTY_HOME=/opt/jetty" >> /etc/default/jetty
