# Docker container for AsterixDB (http://asterixdb.ics.uci.edu/).

# See https://github.com/ceejatec/naked-docker/ for details about the
# construction of the base image.

# FROM ceejatec/naked-ubuntu:12.04
FROM stephenreed/jenkins-java8-maven-git
USER root

# JDK.
#RUN apt-get update && \
#    apt-get install -y openjdk-7-jre-headless && \
#    rm -f /var/cache/apt/archives/*.deb

#RUN apt-get install software-properties-common

#RUN \
#  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
#    add-apt-repository -y ppa:webupd8team/java && \
#      apt-get update && \
#        apt-get install -y oracle-java8-installer && \
#          rm -rf /var/lib/apt/lists/* && \
#            rm -rf /var/cache/oracle-jdk8-installer
#
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
#
# Create "asterix" user with password-less sudo privs.
RUN useradd asterix -G sudo -m -s /bin/bash && \
    echo 'asterix:asterix' | chpasswd && \
    sed -ri 's/ALL\) ALL/ALL) NOPASSWD:ALL/' /etc/sudoers

# Copy Asterix application.
COPY build /asterix/

