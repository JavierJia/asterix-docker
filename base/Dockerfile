# Docker container for AsterixDB (http://asterixdb.ics.uci.edu/).

# See https://github.com/ceejatec/naked-docker/ for details about the
# construction of the base image.

FROM jianfeng/asterixbuilder
USER root

# Create "asterix" user with password-less sudo privs.
#RUN useradd asterix -G sudo -m -s /bin/bash && \
#    echo 'asterix:asterix' | chpasswd && \
#    sed -ri 's/ALL\) ALL/ALL) NOPASSWD:ALL/' /etc/sudoers

RUN apt-get install -y unzip

ENV TERM dumb
# Copy Asterix application.
ADD asterix-server-0.8.8-SNAPSHOT-binary-assembly.zip /asterix/

RUN unzip /asterix/*.zip -d /asterix/

COPY ./asterix-startup.sh /asterix/
COPY ./asterix-properties.xml /asterix/



