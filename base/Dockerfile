# Docker container for AsterixDB (http://asterixdb.ics.uci.edu/).

# See https://github.com/ceejatec/naked-docker/ for details about the
# construction of the base image.

FROM stephenreed/jenkins-java8-maven-git
USER root

# Create "asterix" user with password-less sudo privs.
RUN useradd asterix -G sudo -m -s /bin/bash && \
    echo 'asterix:asterix' | chpasswd && \
    sed -ri 's/ALL\) ALL/ALL) NOPASSWD:ALL/' /etc/sudoers

ENV TERM dumb
# Copy Asterix application.
COPY build /asterix/


