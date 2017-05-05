# Docker container for AsterixDB (http://asterixdb.ics.uci.edu/).

# See https://github.com/ceejatec/naked-docker/ for details about the
# construction of the base image.

FROM centos 
USER root

# Create "asterix" user with password-less sudo privs.
#RUN useradd asterix -G sudo -m -s /bin/bash && \
#    echo 'asterix:asterix' | chpasswd && \
#    sed -ri 's/ALL\) ALL/ALL) NOPASSWD:ALL/' /etc/sudoers
ENV ADB_VERSION="0.9.2-SNAPSHOT"

RUN echo 'LANG="en_US.UTF-8"' > /etc/sysconfig/i18n ;echo 'ZONE="America/Los_Angeles"' > /etc/sysconfig/clock ;cp -a /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
RUN echo "include_only=.us" >> /etc/yum/pluginconf.d/fastestmirror.conf
RUN yum install -y unzip openssh-server openssh-clients python-setuptools wget curl net-tools
RUN yum remove -y java-1.6.0-openjdk
RUN wget --no-cookies \
    --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    "http://download.oracle.com/otn-pub/java/jdk/8-b132/jdk-8-linux-x64.rpm" \
    -O jdk-8-linux-x64.rpm
RUN rpm -Uvh jdk-8-linux-x64.rpm
RUN alternatives --install /usr/bin/java java /usr/java/jdk1.8.0/jre/bin/java 20000
RUN alternatives --install /usr/bin/jar jar /usr/java/jdk1.8.0/bin/jar 20000
RUN alternatives --install /usr/bin/javac javac /usr/java/jdk1.8.0/bin/javac 20000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/jdk1.8.0/jre/bin/javaws 20000
RUN alternatives --set java /usr/java/jdk1.8.0/jre/bin/java
RUN alternatives --set javaws /usr/java/jdk1.8.0/jre/bin/javaws
RUN alternatives --set javac /usr/java/jdk1.8.0/bin/javac
RUN alternatives --set jar /usr/java/jdk1.8.0/bin/jar
ENV TERM dumb

# Copy Asterix application.
#RUN wget -P /asterix/ https://asterix-jenkins.ics.uci.edu/job/asterix-integration-tests/lastSuccessfulBuild/org.apache.asterix\$asterix-server/artifact/org.apache.asterix/asterix-server/${ADB_VERSION}/asterix-server-${ADB_VERSION}-binary-assembly.zip   
COPY ./asterix-server-0.9.2-SNAPSHOT-binary-assembly.zip /asterix/
#ENV LC_CTYPE="en_US.UTF-8"
#ENV LANG en_US.UTF-8  
#ENV LANGUAGE en_US:en  
#ENV LC_ALL en_US.UTF-8  
#RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8

ENV JAVA_HOME /usr/java/jdk1.8.0
ENV PATH="$PATH:$JAVA_HOME/bin"
RUN unzip /asterix/*.zip -d /asterix/

ADD ./asterix-startup.sh /asterix/

#Add UDF stuff
COPY ./libs/*.jar /asterix/repo/
#Add 
RUN mkdir -p /asterix/lib/udfs/twitter/snlp
COPY ./libs/asterix-snlp-udf-0.1-SNAPSHOT/* /asterix/lib/udfs/twitter/snlp/



WORKDIR /home/asterix

ENTRYPOINT ["/asterix/asterix-startup.sh"]

#For CC
EXPOSE 19000-19010

#For NC
EXPOSE 5000-8000
#For NC's feed
EXPOSE 10000-11000

