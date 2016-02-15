# Docker container for AsterixDB (http://asterixdb.ics.uci.edu/).

# See https://github.com/ceejatec/naked-docker/ for details about the
# construction of the base image.

FROM centos 
USER root

# Create "asterix" user with password-less sudo privs.
#RUN useradd asterix -G sudo -m -s /bin/bash && \
#    echo 'asterix:asterix' | chpasswd && \
#    sed -ri 's/ALL\) ALL/ALL) NOPASSWD:ALL/' /etc/sudoers

RUN yum install -y unzip java-1.8.0-openjdk openssh-server openssh-clients python-setuptools wget curl net-tools
ENV TERM dumb

# Copy Asterix application.
ADD asterix-server-0.8.8-SNAPSHOT-binary-assembly.zip /asterix/

ENV LC_CTYPE="en_US.UTF-8"
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  
RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8

#RUN locale-gen en_US.UTF-8  

ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0
RUN unzip /asterix/*.zip -d /asterix/

COPY ./asterix-startup.sh /asterix/
COPY ./asterix-properties.xml /asterix/



